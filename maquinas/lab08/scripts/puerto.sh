#!/bin/sh
# Lab 8, parte 2.b: dice SI/NO si un puerto TCP esta abierto y que servicio corre en el.
# Uso: sh puerto.sh PUERTO [HOST]        (HOST por defecto: 127.0.0.1)
# Ejemplo: sh puerto.sh 80    |    sh puerto.sh 22 10.2.78.74

PUERTO="$1"
HOST="${2:-127.0.0.1}"

case "$PUERTO" in
  ''|*[!0-9]*) echo "Uso: $0 PUERTO [HOST]   (PUERTO debe ser un numero de 1 a 65535)"; exit 2 ;;
esac
if [ "$PUERTO" -lt 1 ] || [ "$PUERTO" -gt 65535 ]; then echo "Puerto fuera de rango (1-65535)."; exit 2; fi

# 1) Prueba de conexion: nc si existe, si no el /dev/tcp de bash
if command -v nc >/dev/null 2>&1; then
  nc -z -w 2 "$HOST" "$PUERTO" >/dev/null 2>&1 && ABIERTO=1 || ABIERTO=0
elif command -v bash >/dev/null 2>&1; then
  bash -c "exec 3<>/dev/tcp/$HOST/$PUERTO" >/dev/null 2>&1 && ABIERTO=1 || ABIERTO=0
else
  echo "Se necesita nc o bash para probar el puerto."; exit 3
fi

# 2) Nombre del servicio segun /etc/services
SERV=$(getent services "$PUERTO/tcp" 2>/dev/null | awk '{print $1; exit}')   # Solaris no siempre tiene /etc/services completo
[ -n "$SERV" ] || SERV=$(awk -v p="$PUERTO/tcp" '$2==p {print $1; exit}' /etc/services 2>/dev/null)
[ -n "$SERV" ] || SERV="desconocido"

if [ "$ABIERTO" -eq 1 ]; then
  echo "Puerto $PUERTO en $HOST: SI esta abierto"
  echo "Servicio segun /etc/services: $SERV"
  # 3) Si es esta misma maquina, que programa lo tiene abierto
  if [ "$HOST" = "127.0.0.1" ] || [ "$HOST" = "localhost" ]; then
    if command -v ss >/dev/null 2>&1; then ss -ltnp 2>/dev/null | grep ":$PUERTO " | sed 's/^/Escuchando: /'
    elif [ "$(uname -s)" = "SunOS" ]; then netstat -an -f inet | grep "\.$PUERTO " | grep LISTEN | sed 's/^/Escuchando: /'
    else netstat -ltn 2>/dev/null | grep ":$PUERTO " | sed 's/^/Escuchando: /'; fi
  fi
  exit 0
else
  echo "Puerto $PUERTO en $HOST: NO esta abierto (servicio habitual: $SERV)"
  exit 1
fi
