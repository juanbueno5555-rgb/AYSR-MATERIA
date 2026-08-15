#!/bin/bash
# casa.sh — Solaris 11.4: DHCP + alias NAT 10.0.2.15 para acceso remoto en casa
# Ejecutar como root despues de que el host corra casa.cmd (NAT)

echo "=== Casa: configurando DHCP + alias NAT ==="

# Quitar estatica si existe
ipadm delete-addr net0/v4 2>/dev/null
ipadm delete-addr net0/v4nat 2>/dev/null

# DHCP (NAT de VirtualBox usa 10.0.2.0/24 con GW .2 y DNS .3)
ipadm create-addr -T dhcp net0/v4

# Alias NAT estatico para SSH (el port-forwarding del host mapea 2223 -> 10.0.2.15:22)
ipadm create-addr -T static -a local=10.0.2.15/24 net0/v4nat

ipadm show-addr
echo "=== Casa: listo (DHCP + alias 10.0.2.15) ==="
