#!/usr/bin/env bash
# Insignia 3 - Lab 3: Redes VPC múltiples
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 3 · Lab 3 · Redes VPC múltiples"
habilitar_apis compute.googleapis.com iap.googleapis.com
MGMT="${P}-managementnet"; PRIV="${P}-privatenet"

paso "1) Red VPC (subredes en modo manual) $MGMT con la subred ${MGMT}-sub-us (10.130.0.0/20)"
existe gcloud compute networks describe "$MGMT" || cmd gcloud compute networks create "$MGMT" --subnet-mode custom \
  --description "VPC de administración - lab i3-l3 de $NOMBRE"
existe gcloud compute networks subnets describe "${MGMT}-sub-us" --region "$REGION" || \
  cmd gcloud compute networks subnets create "${MGMT}-sub-us" --network "$MGMT" --region "$REGION" --range 10.130.0.0/20

paso "2) Red VPC (subredes en modo manual) $PRIV con 2 subredes (172.16.0.0/24 en $REGION y 172.20.0.0/20 en $REGION2)"
existe gcloud compute networks describe "$PRIV" || cmd gcloud compute networks create "$PRIV" --subnet-mode custom \
  --description "VPC privada - lab i3-l3 de $NOMBRE"
existe gcloud compute networks subnets describe "${PRIV}-sub-us" --region "$REGION" || \
  cmd gcloud compute networks subnets create "${PRIV}-sub-us" --network "$PRIV" --region "$REGION" --range 172.16.0.0/24
existe gcloud compute networks subnets describe "${PRIV}-sub-notus" --region "$REGION2" || \
  cmd gcloud compute networks subnets create "${PRIV}-sub-notus" --network "$PRIV" --region "$REGION2" --range 172.20.0.0/20
cmd gcloud compute networks list --filter="name~^$P OR name=default"
cmd gcloud compute networks subnets list --filter="network~$P" --sort-by NETWORK --format='table(name,region.basename(),network.basename(),ipCidrRange)'

paso "3) Reglas de firewall: ICMP, SSH y RDP en ambas redes"
for N in "$MGMT" "$PRIV"; do
  existe gcloud compute firewall-rules describe "${N}-allow-icmp-ssh-rdp" || \
    cmd gcloud compute firewall-rules create "${N}-allow-icmp-ssh-rdp" --network "$N" --direction INGRESS \
      --action ALLOW --rules icmp,tcp:22,tcp:3389 --source-ranges 0.0.0.0/0
done
cmd gcloud compute firewall-rules list --filter="network~$P" --sort-by NETWORK --format='table(name,network.basename(),sourceRanges.list(),allowed[].map().firewall_rule().list())'

paso "4) Creando 5 VMs (e2-micro) en las distintas redes"
crear_vm() { # nombre zona red/subred...
  local n="$1" z="$2"; shift 2
  existe gcloud compute instances describe "$n" --zone "$z" || \
    cmd gcloud compute instances create "$n" --zone "$z" --machine-type e2-micro --image-family debian-12 \
      --image-project debian-cloud --boot-disk-size 10GB --labels "$ETIQUETAS" "$@" --async
}
crear_vm "${P}-mynet-us-vm" "$ZONA" --network default
crear_vm "${P}-mynet-notus-vm" "$ZONA2" --network default
crear_vm "${P}-managementnet-us-vm" "$ZONA" --subnet "${MGMT}-sub-us"
crear_vm "${P}-privatenet-us-vm" "$ZONA" --subnet "${PRIV}-sub-us"
# VM con 2 interfaces de red (una e2-micro admite hasta 2 NIC). Va SIN IP externa porque la
# prueba gratuita solo permite 4 IPs externas por región; se entra por SSH a través de IAP.
crear_vm "${P}-vm-appliance" "$ZONA" \
  --network-interface "subnet=${PRIV}-sub-us,no-address" --network-interface "subnet=${MGMT}-sub-us,no-address"
sleep 45
gcloud compute instances list --filter="labels.alumno=$P AND labels.lab=$LAB_CORTO" --sort-by ZONE \
  --format='table(name,zone.basename(),networkInterfaces[].network.basename().list():label=REDES,networkInterfaces[].networkIP.list():label=IP_INTERNAS,networkInterfaces[0].accessConfigs[0].natIP:label=IP_EXTERNA)'

ipint() { gcloud compute instances describe "$1" --zone "${2:-$ZONA}" --format="value(networkInterfaces[${3:-0}].networkIP)"; }
ipext() { gcloud compute instances describe "$1" --zone "${2:-$ZONA}" --format='value(networkInterfaces[0].accessConfigs[0].natIP)'; }
NOTUS_INT="$(ipint "${P}-mynet-notus-vm" "$ZONA2")"; NOTUS_EXT="$(ipext "${P}-mynet-notus-vm" "$ZONA2")"
MGMT_INT="$(ipint "${P}-managementnet-us-vm")";      MGMT_EXT="$(ipext "${P}-managementnet-us-vm")"
PRIV_INT="$(ipint "${P}-privatenet-us-vm")";         PRIV_EXT="$(ipext "${P}-privatenet-us-vm")"

paso "5) Pruebas de conectividad desde ${P}-mynet-us-vm (red default)"
sleep 20
gcloud compute ssh "${P}-mynet-us-vm" --zone "$ZONA" --quiet --strict-host-key-checking=no --command "
echo '== Alumno: $NOMBRE - Sección $SECCION =='
p(){ if ping -c 2 -W 2 \$2 >/dev/null 2>&1; then echo \"[OK]    \$1 (\$2)\"; else echo \"[FALLA] \$1 (\$2)\"; fi; }
echo '--- IPs EXTERNAS (deben responder todas) ---'
p mynet-notus-vm $NOTUS_EXT; p managementnet-us-vm $MGMT_EXT; p privatenet-us-vm $PRIV_EXT
echo '--- IPs INTERNAS ---'
p 'mynet-notus-vm  (misma VPC, otra región -> OK)' $NOTUS_INT
p 'managementnet-us-vm (otra VPC -> FALLA)' $MGMT_INT
p 'privatenet-us-vm    (otra VPC -> FALLA)' $PRIV_INT
" || true

paso "6) Desde la VM appliance (2 interfaces) sí se llega a ambas VPC por IP interna"
gcloud compute ssh "${P}-vm-appliance" --zone "$ZONA" --tunnel-through-iap --quiet --strict-host-key-checking=no --command "
ip -br addr | grep -v '^lo'
p(){ if ping -c 2 -W 2 \$2 >/dev/null 2>&1; then echo \"[OK]    \$1 (\$2)\"; else echo \"[FALLA] \$1 (\$2)\"; fi; }
p 'privatenet-us-vm (nic0)' $PRIV_INT
p 'managementnet-us-vm (nic1, sin ruta por defecto)' $MGMT_INT
echo 'Tabla de rutas:'; ip route
" || true
fin_lab
