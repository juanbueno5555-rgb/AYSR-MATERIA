#!/bin/sh
# files-script.sh [no_files] [max_size] [dir]
# Muestra los N archivos mas pequenos menores a max_size recorriendo el arbol
# Ej: ./files-script.sh 10 1GB
NUM="${1:-10}"; MAX="$2"; DIR="${3:-.}"

[ -z "$MAX" ] && { echo "Uso: $0 [no_files] [max_size] [dir] (ej: $0 10 1GB)"; exit 1; }

# Convierte 1GB/100MB/50KB a bytes (1 linea en vez de un case por sufijo)
UNI=1; case "$MAX" in *GB) UNI=1073741824;; *MB) UNI=1048576;; *KB) UNI=1024;; esac
MAXB=$(( ${MAX%[GMK]B} * UNI ))

echo "Los $NUM archivos mas pequenos (< $MAX) en $DIR:"
find "$DIR" -type f -size -"$MAXB"c -printf '%s %p\n' 2>/dev/null \
 | sort -n | head -n "$NUM" \
 | awk '{ n=$2; sub(/.*\//,"",n); d=$2; sub(/\/[^/]*$/,"",d); print n" -> "d" ("$1" bytes)" }'