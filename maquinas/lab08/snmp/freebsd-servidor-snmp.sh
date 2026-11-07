#!/bin/sh
# Servidor de monitoreo SNMP en FreeBSD (Lab 7, punto 2).
# Agente: net-snmp. Recolector: snmp_exporter + Prometheus. Pantalla en tiempo real: Grafana.
# Uso (como root): sh freebsd-servidor-snmp.sh
set -e

COMUNIDAD=lab07mon
OBJETIVOS='"192.168.82.14","192.168.82.10","192.168.82.11","192.168.82.13"'   # FreeBSD, Slackware, Solaris y Windows

# 1. Agente SNMP en esta maquina
cat > /usr/local/share/snmp/snmpd.conf <<EOF
agentAddress udp:161
rocommunity $COMUNIDAD 192.168.82.0/24
rocommunity $COMUNIDAD 127.0.0.1
sysLocation Lab 7 - VirtualBox
sysContact camilo@lab07
sysName freebsd-lab07
load 4 4 4
EOF
sysrc snmpd_enable=YES snmpd_flags="-a"

# 2. snmp_exporter usa nuestra comunidad (por defecto trae "public")
sed -i '' "10s/community: public/community: $COMUNIDAD/" /usr/local/etc/snmp_exporter/snmp.yml
sysrc snmp_exporter_enable=YES

# 3. Prometheus consulta a cada maquina a traves de snmp_exporter cada 15 s
cat > /usr/local/etc/prometheus.yml <<EOF
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: snmp
    metrics_path: /snmp
    params:
      auth: [public_v2]
      module: [if_mib, system, ucd_la_table, ucd_memory, ucd_system_stats]
    static_configs:
      - targets: [$OBJETIVOS]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9116
EOF
sysrc prometheus_enable=YES

# 4. Grafana (puerto 3000)
sysrc grafana_enable=YES

service snmpd restart
service snmp_exporter restart
service prometheus restart
service grafana restart
