#!/bin/bash
# uni.sh — Solaris 11.4: IP estática 10.2.78.65 para la red de la universidad
# Ejecutar como root despues de que el host corra uni.cmd (bridge)

echo "=== Uni: configurando IP estatica 10.2.78.65 ==="

# Quitar DHCP si existe
ipadm delete-addr net0/v4 2>/dev/null

# IP principal (uni)
ipadm create-addr -T static -a local=10.2.78.65/16 net0/v4

# Ruta default
route -p add default 10.2.65.1

# DNS
echo "nameserver 10.2.65.1" > /etc/resolv.conf

# Hostname
hostname solaris

ipadm show-addr
echo "=== Uni: listo (10.2.78.65/16, GW 10.2.65.1) ==="
