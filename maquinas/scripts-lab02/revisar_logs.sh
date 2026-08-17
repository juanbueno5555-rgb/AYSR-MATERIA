#!/bin/bash
# ============================================================
# revisar_logs.sh — Laboratorio 02, ejercicio 1.3
# Muestra las ultimas 15 lineas de 3 archivos de log de
# actividad general del sistema, con opcion de filtrar
# por una palabra. Limpia la pantalla antes de mostrar.
# Uso: ./revisar_logs.sh
# ============================================================

# Archivos de log de actividad general en Slackware
LOG1="/var/log/syslog"
LOG2="/var/log/messages"
LOG3="/var/log/secure"

while true; do
    clear
    echo "======================================"
    echo "  MENU — Revision de logs"
    echo "======================================"
    echo "1) Mostrar las ultimas 15 lineas de los 3 logs"
    echo "2) Filtrar esas lineas por una palabra"
    echo "0) Salir"
    echo "======================================"
    read -p "Opcion: " op

    case $op in
        1)  # Ultimas 15 lineas de cada log
            for log in "$LOG1" "$LOG2" "$LOG3"; do
                echo "===== $log ====="
                tail -n 15 "$log" 2>/dev/null || echo "(no existe o sin permisos)"
                echo
            done
            read -p "Enter para continuar..." ;;
        2)  # Filtrar las ultimas 15 lineas por palabra
            read -p "Palabra a filtrar: " palabra
            for log in "$LOG1" "$LOG2" "$LOG3"; do
                echo "===== $log (filtro: $palabra) ====="
                tail -n 15 "$log" 2>/dev/null | grep "$palabra" || echo "(sin coincidencias)"
                echo
            done
            read -p "Enter para continuar..." ;;
        0)
            echo "Chau!"
            exit 0 ;;
        *)
            echo "Opcion invalida" ;;
    esac
done
