#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Uso: files-script.sh [no_files] [max_size]"
    echo "Ejemplo: files-script.sh 10 1GB"
    echo "Unidades: B, KB, MB, GB"
    exit 1
fi

noFiles="$1"
maxSize="$2"

n=${maxSize%%[A-Za-z]*}
sufijo=${maxSize##*[0-9]}

case "$sufijo" in
    GB) u=1073741824 ;;
    MB) u=1048576 ;;
    KB) u=1024 ;;
    *)  u=1 ;;
esac

maxBytes=$(( n * u ))

echo ""
echo "Buscando los $noFiles archivos más pequeños (máximo $maxSize = $maxBytes bytes)..."
echo "--------------------------------------------------------"
printf "TAMAÑO\tRUTA COMPLETA\n"
echo "--------------------------------------------------------"

find . -type f -size -"${maxBytes}"c -exec wc -c {} + 2>/dev/null \
    | sort -n \
    | head -n "$noFiles" \
    | awk '{print $1"\t"$2}'
