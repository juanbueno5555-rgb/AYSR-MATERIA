#!/bin/bash
# ============================================================
# mi_ls.sh — Laboratorio 02, ejercicio 1.1
# Lista los archivos de un directorio (incluidos ocultos) con
# opciones de ordenamiento, conteo por grupos y filtros.
# Uso: ./mi_ls.sh
# ============================================================

clear
read -p "Directorio a analizar: " dir

# Validar que el directorio exista
if [ ! -d "$dir" ]; then
    echo "ERROR: '$dir' no es un directorio válido."
    exit 1
fi

while true; do
    clear
    echo "======================================"
    echo "  MENU — Listar archivos de: $dir"
    echo "======================================"
    echo "1) Mas recientes (conteo por fecha)"
    echo "2) Mas antiguos (conteo por fecha)"
    echo "3) Mayor tamano (conteo por tamano)"
    echo "4) Menor tamano (conteo por tamano)"
    echo "5) Por tipo (archivo/directorio)"
    echo "6) Filtro: empieza con..."
    echo "7) Filtro: termina con..."
    echo "8) Filtro: contiene..."
    echo "9) Incluir subdirectorios (recursivo)"
    echo "0) Salir"
    echo "======================================"
    read -p "Opcion: " op

    case $op in
        1)  # Mas recientes: lista por fecha (nuevos arriba) y cuenta los que comparten fecha
            ls -lat "$dir" | awk '{print $6, $7}' | sort | uniq -c | less ;;
        2)  # Mas antiguos: lista por fecha invertida (viejos arriba) y cuenta por fecha
            ls -latr "$dir" | awk '{print $6, $7}' | sort | uniq -c | less ;;
        3)  # Mayor tamano: lista de grande a chico y cuenta los que comparten tamano
            ls -laS "$dir" | awk '{print $5}' | sort -rn | uniq -c | less ;;
        4)  # Menor tamano: lista de chico a grande y cuenta por tamano
            ls -laSr "$dir" | awk '{print $5}' | sort -n | uniq -c | less ;;
        5)  # Tipo: cuenta cuantos directorios y cuantos archivos
            echo "Directorio: $dir"
            echo "--- Directorios (con ocultos):"
            ls -la "$dir" | grep "^d" | wc -l
            echo "--- Archivos (con ocultos):"
            ls -la "$dir" | grep -v "^d" | wc -l
            read -p "Enter para continuar..." ;;
        6)  # Filtro: empieza con una cadena (solo el directorio)
            read -p "Cadena inicial: " patron
            find "$dir" -maxdepth 1 -name "$patron*" | less ;;
        7)  # Filtro: termina con una cadena
            read -p "Cadena final: " patron
            find "$dir" -maxdepth 1 -name "*$patron" | less ;;
        8)  # Filtro: contiene una cadena
            read -p "Cadena contenida: " patron
            find "$dir" -maxdepth 1 -name "*$patron*" | less ;;
        9)  # Recursivo: mismo filtro pero incluyendo subdirectorios
            read -p "Cadena a buscar (Enter = todos): " patron
            if [ -z "$patron" ]; then
                find "$dir" | less
            else
                find "$dir" -name "*$patron*" | less
            fi ;;
        0)
            echo "Chau!"
            exit 0 ;;
        *)
            echo "Opcion invalida" ;;
    esac
done
