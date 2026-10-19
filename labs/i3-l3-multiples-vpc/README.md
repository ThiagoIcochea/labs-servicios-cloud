# Insignia 3 · Lab 3 — Redes VPC múltiples

**Equivale a:** *Multiple VPC Networks*.

## Qué hace
1. Crea 2 VPC personalizadas: `<prefijo>-managementnet` (1 subred) y `<prefijo>-privatenet` (2 subredes en 2 regiones).
2. Crea reglas de firewall ICMP/SSH/RDP en cada una.
3. Crea 5 VMs: dos en la red `default` (en 2 regiones), una en cada VPC nueva y una **appliance con 2 interfaces de red** (una en cada VPC).
4. Prueba la conectividad con `ping`:
   - Por **IP externa** todas responden.
   - Por **IP interna** solo responde la VM de la **misma VPC**, aunque esté en otra región.
   - La appliance llega a ambas VPC por IP interna porque tiene una NIC en cada una.

> El lab original usa una `vm-appliance` e2-standard-4 con 3 NIC. Aquí se usa e2-micro con 2 NIC para respetar la cuota de la prueba gratuita (8 vCPU); el concepto es el mismo.

## Ejecutar
```bash
./lab <alumno> i3-l3 up      # ~5 min
./lab <alumno> i3-l3 down
```

## Evidencias que debes capturar
- [ ] **Red de VPC → Redes de VPC** con tus 2 redes y subredes.
- [ ] **Firewall** con tus reglas.
- [ ] **Instancias de VM** mostrando las 5 VMs y la appliance con 2 IPs internas.
- [ ] En Cloud Shell los resultados `[OK]` / `[FALLA]` de los ping.

## Costo aproximado
5 × e2-micro ~15 min ≈ **US$ 0.02**.
