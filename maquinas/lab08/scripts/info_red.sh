#!/bin/sh
# Lab 8, parte 2.a: menu de comandos de red para Slackware (Linux) y Solaris.
# Uso: sh info_red.sh
# Cada opcion ejecuta el comando que corresponde al sistema y explica en una linea que se esta viendo.

SO=$(uname -s)

hay() { command -v "$1" >/dev/null 2>&1; }

pausa() { printf '\nPresione Enter para volver al menu... '; read _x; }

titulo() { printf '\n=== %s ===\n%s\n\n' "$1" "$2"; }

interfaces() {
  titulo "Interfaces e IP" "Muestra cada tarjeta de red con su IP, mascara, MAC y si esta activa (UP)."
  if [ "$SO" = "SunOS" ]; then ifconfig -a; elif hay ifconfig; then ifconfig -a; else ip addr; fi
}

rutas() {
  titulo "Tabla de rutas" "Dice por que interfaz y por que gateway sale cada destino. La linea 'default' o '0.0.0.0' es la puerta de enlace."
  if hay route && [ "$SO" != "SunOS" ]; then route -n; else netstat -rn; fi
}

escuchando() {
  titulo "Puertos en escucha" "Servicios esperando conexiones: la columna de direccion termina en :PUERTO (80=web, 53=DNS, 161=SNMP)."
  if [ "$SO" = "SunOS" ]; then netstat -an -f inet | grep LISTEN
  else netstat -tuln 2>/dev/null || ss -tuln; fi
}

conexiones() {
  titulo "Conexiones activas" "Conexiones TCP establecidas ahora mismo entre esta maquina y otras (estado ESTABLISHED)."
  if [ "$SO" = "SunOS" ]; then netstat -an -f inet | grep ESTABLISHED
  else netstat -tn 2>/dev/null | grep -E 'Proto|ESTABLISHED' || ss -tn; fi
}

estadisticas() {
  titulo "Paquetes por interfaz" "Paquetes recibidos y enviados por cada interfaz, con errores y descartados. Muchos errores indican cable o duplex malos."
  netstat -i
}

enlace() {
  titulo "Velocidad y estado del enlace" "Velocidad (10/100/1000 Mb/s), duplex y si hay cable conectado."
  if [ "$SO" = "SunOS" ]; then
    dladm show-link 2>/dev/null; dladm show-phys 2>/dev/null
  elif hay ethtool; then
    for i in $(ls /sys/class/net 2>/dev/null | grep -v '^lo$'); do echo "--- $i"; ethtool "$i" 2>/dev/null | grep -E 'Speed|Duplex|Link detected'; done
  else
    echo "ethtool no esta instalado en este sistema."
  fi
}

trafico() {
  titulo "Trafico acumulado" "Datos totales recibidos y enviados, por dia o mes (vnstat). Si no esta instalado se usa netstat."
  if hay vnstat; then vnstat; else echo "vnstat no esta instalado; bytes por interfaz con netstat:"; netstat -ib 2>/dev/null || netstat -i; fi
}

while :; do
  clear 2>/dev/null
  cat <<MENU
=========== Informacion de red ($SO) ===========
 1) Interfaces e IP              (ifconfig)
 2) Tabla de rutas               (route / netstat -r)
 3) Puertos en escucha           (netstat -l)
 4) Conexiones activas           (netstat -t)
 5) Paquetes por interfaz        (netstat -i)
 6) Velocidad y estado del enlace (ethtool / dladm)
 7) Trafico acumulado            (vnstat)
 0) Salir
MENU
  printf 'Opcion: '; read op
  case "$op" in
    1) interfaces ;; 2) rutas ;; 3) escuchando ;; 4) conexiones ;;
    5) estadisticas ;; 6) enlace ;; 7) trafico ;;
    0) exit 0 ;;
    *) echo "Opcion no valida." ;;
  esac
  pausa
done
