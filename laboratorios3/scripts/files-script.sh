#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 [no_files] [max_size]"
    echo "Ejemplo: $0 10 1GB"
    exit 1
fi

no_files="$1"
max_size="$2"
dir_inicio="."

# Convertir la unidad (GB/MB/KB/B) a bytes: 1GB -> 1 * 1073741824
UNI="1"
case "$max_size" in
    *GB) UNI="1073741824" ;;
    *MB) UNI="1048576" ;;
    *KB) UNI="1024" ;;
    *B)  UNI="1" ;;
esac
NUMERO=$(echo "$max_size" | sed 's/[GMK]B$//' | sed 's/B$//')
max_bytes=$(( NUMERO * UNI ))

echo ""
echo "Buscando los $no_files archivos más pequeños (máximo $max_size) desde el directorio actual..."
echo "--------------------------------------------------------"
printf "TAMAÑO\tRUTA COMPLETA\n"
echo "--------------------------------------------------------"

# wc -c existe en Solaris Y Slackware (portable, reemplaza a stat -c)
find "$dir_inicio" -type f -size -"$max_bytes"c -exec wc -c {} + 2>/dev/null \
    | sort -n \
    | head -n "$no_files" \
    | awk '{print $1"\t"$2}'