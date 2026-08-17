#!/bin/bash
# ============================================================
# buscar.sh — Laboratorio 02, ejercicio 1.2
# Busqueda de archivos y de palabras dentro de archivos,
# con menu interactivo que se mantiene hasta salir.
# Uso: ./buscar.sh
# ============================================================

while true; do
    clear
    echo "======================================"
    echo "  MENU — Busqueda y visualizacion"
    echo "======================================"
    echo "1) Buscar archivo (o parte del nombre) en un directorio"
    echo "2) Buscar palabra (o parte) dentro de un archivo"
    echo "3) Buscar archivos y buscar una palabra dentro de ellos"
    echo "4) Contar lineas de un archivo"
    echo "5) Mostrar las primeras n lineas"
    echo "6) Mostrar las ultimas n lineas"
    echo "0) Salir"
    echo "======================================"
    read -p "Opcion: " op

    case $op in
        1)  # Buscar archivo por nombre parcial en un directorio
            read -p "Directorio: " dir
            read -p "Nombre (o parte): " patron
            echo "--- Resultados:"
            find "$dir" -name "*$patron*" 2>/dev/null
            echo "--- Total de ocurrencias:"
            find "$dir" -name "*$patron*" 2>/dev/null | wc -l
            read -p "Enter para continuar..." ;;
        2)  # Buscar palabra dentro de un archivo
            read -p "Archivo: " archivo
            read -p "Palabra (o parte): " palabra
            echo "--- Coincidencias (linea: contenido):"
            grep -n "$palabra" "$archivo" 2>/dev/null
            echo "--- Total de ocurrencias:"
            grep -c "$palabra" "$archivo" 2>/dev/null
            read -p "Enter para continuar..." ;;
        3)  # Buscar archivos por nombre y luego una palabra dentro de cada uno
            read -p "Directorio: " dir
            read -p "Nombre de archivo (o parte): " patron_archivo
            read -p "Palabra a buscar dentro: " palabra
            for f in $(find "$dir" -name "*$patron_archivo*" 2>/dev/null); do
                echo "== $f =="
                grep -n "$palabra" "$f" 2>/dev/null
                echo "   Total: $(grep -c "$palabra" "$f" 2>/dev/null)"
            done
            read -p "Enter para continuar..." ;;
        4)  # Contar lineas
            read -p "Archivo: " archivo
            wc -l "$archivo"
            read -p "Enter para continuar..." ;;
        5)  # Primeras n lineas
            read -p "Archivo: " archivo
            read -p "Numero de lineas (n): " n
            head -n "$n" "$archivo"
            read -p "Enter para continuar..." ;;
        6)  # Ultimas n lineas
            read -p "Archivo: " archivo
            read -p "Numero de lineas (n): " n
            tail -n "$n" "$archivo"
            read -p "Enter para continuar..." ;;
        0)
            echo "Chau!"
            exit 0 ;;
        *)
            echo "Opcion invalida" ;;
    esac
done
