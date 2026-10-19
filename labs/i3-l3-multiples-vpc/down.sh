#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 3 · Lab 3"
borrar gcloud compute instances delete "${P}-mynet-us-vm" "${P}-managementnet-us-vm" "${P}-privatenet-us-vm" "${P}-vm-appliance" --zone "$ZONA"
borrar gcloud compute instances delete "${P}-mynet-notus-vm" --zone "$ZONA2"
for N in "${P}-managementnet" "${P}-privatenet"; do borrar gcloud compute firewall-rules delete "${N}-allow-icmp-ssh-rdp"; done
borrar gcloud compute networks subnets delete "${P}-managementnet-sub-us" "${P}-privatenet-sub-us" --region "$REGION"
borrar gcloud compute networks subnets delete "${P}-privatenet-sub-notus" --region "$REGION2"
borrar gcloud compute networks delete "${P}-managementnet" "${P}-privatenet"
fin_limpieza
