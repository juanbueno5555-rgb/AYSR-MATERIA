#!/bin/sh
# Lab 8, parte 3: agente SNMP en NetBSD (la guia pide NetBSD para el segundo integrante del grupo).
# SIN PROBAR: no hay VM de NetBSD en este laboratorio. Verificar rutas y nombres de paquete en la maquina.
# Uso (como root):  sh netbsd-agente-snmp.sh
set -e

COMUNIDAD=lab07mon
RED=192.168.82.0/24        # red desde la que se permite consultar (la del servidor de monitoreo en Slackware)

# 1. Instalar net-snmp con pkgin (si pkgin no existe: pkg_add net-snmp)
if command -v pkgin >/dev/null 2>&1; then pkgin -y install net-snmp; else pkg_add net-snmp; fi

# 2. Configuracion del agente
mkdir -p /usr/pkg/etc/snmp
cat > /usr/pkg/etc/snmp/snmpd.conf <<EOF
agentAddress udp:161
rocommunity $COMUNIDAD $RED
rocommunity $COMUNIDAD 127.0.0.1
sysLocation Lab 8 - VirtualBox
sysContact camilo@lab08
sysName netbsd-lab08
includeAllDisks 10%
load 4 4 4
EOF

# 3. Arranque automatico: el paquete deja un script de ejemplo que se copia a /etc/rc.d
cp /usr/pkg/share/examples/rc.d/snmpd /etc/rc.d/snmpd
grep -q '^snmpd=' /etc/rc.conf || echo 'snmpd=YES' >> /etc/rc.conf
/etc/rc.d/snmpd restart

# 4. Comprobar
sockstat -4 -l | grep ':161' || netstat -an | grep '\.161 '
/usr/pkg/bin/snmpget -v2c -c "$COMUNIDAD" 127.0.0.1 1.3.6.1.2.1.1.5.0

# Despues, en el servidor de monitoreo (Slackware) agregar la IP de esta maquina a "targets" de
# /opt/monitoreo/prometheus/prometheus.yml y reiniciar Prometheus.
