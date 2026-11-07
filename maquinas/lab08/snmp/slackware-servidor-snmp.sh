#!/bin/sh
# Servidor de monitoreo SNMP en Slackware (Lab 7, punto 2).
# Agente: net-snmp (ya instalado). Recolector: snmp_exporter + Prometheus. Pantalla en tiempo real: interfaz web de Prometheus (puerto 9090); Grafana no tiene version de 32 bits.
# Uso (como root):
#   sh slackware-servidor-snmp.sh
set -e

COMUNIDAD=lab07mon
OBJETIVOS='"192.168.82.10","192.168.82.14","192.168.82.11","192.168.82.13"'   # Slackware, FreeBSD, Solaris y Windows
BASE=/opt/monitoreo
PROM=2.55.1; SNMPX=0.29.0   # Slackware es de 32 bits (i686): binarios linux-386

mkdir -p $BASE && cd $BASE
[ -d prometheus ]    || { curl -sSLO https://github.com/prometheus/prometheus/releases/download/v$PROM/prometheus-$PROM.linux-386.tar.gz && tar xzf prometheus-$PROM.linux-386.tar.gz && mv prometheus-$PROM.linux-386 prometheus; }
[ -d snmp_exporter ] || { curl -sSLO https://github.com/prometheus/snmp_exporter/releases/download/v$SNMPX/snmp_exporter-$SNMPX.linux-386.tar.gz && tar xzf snmp_exporter-$SNMPX.linux-386.tar.gz && mv snmp_exporter-$SNMPX.linux-386 snmp_exporter; }

# snmp_exporter usa nuestra comunidad (por defecto trae "public")
sed -i "10s/community: public/community: $COMUNIDAD/" snmp_exporter/snmp.yml

cat > prometheus/prometheus.yml <<EOF
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


# Arranque ahora y en cada reinicio (rc.local)
cat > $BASE/iniciar.sh <<EOF
#!/bin/sh
cd $BASE/snmp_exporter && nohup ./snmp_exporter --config.file=snmp.yml >/var/log/snmp_exporter.log 2>&1 &
cd $BASE/prometheus   && nohup ./prometheus --config.file=prometheus.yml --storage.tsdb.path=$BASE/prometheus/data >/var/log/prometheus.log 2>&1 &
EOF
chmod +x $BASE/iniciar.sh
grep -q monitoreo/iniciar.sh /etc/rc.d/rc.local || echo "$BASE/iniciar.sh" >> /etc/rc.d/rc.local
pkill -f snmp_exporter || true; pkill -f "prometheus --config" || true
$BASE/iniciar.sh
