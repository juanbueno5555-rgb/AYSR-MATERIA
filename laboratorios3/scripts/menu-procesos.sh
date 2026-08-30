#!/bin/sh
# menu-procesos.sh
# Menu de administracion de procesos: listar, buscar, matar, reiniciar y salir.
while true; do
    echo ""
    echo "===== ADMINISTRACION DE PROCESOS ====="
    echo "1) Listar procesos (nombre, PID, %mem, %cpu)"
    echo "2) Buscar proceso por nombre"
    echo "3) Matar proceso"
    echo "4) Reiniciar proceso"
    echo "5) Salir"
    echo -n "Opcion: "
    read OPC
    case "$OPC" in
        1)
            ps -eo comm,pid,%mem,%cpu --sort=-%mem | head -n 20
            ;;
        2)
            echo -n "Nombre del proceso: "
            read NOMBRE
            ps -eo pid,comm,%mem,%cpu,args | grep -i "$NOMBRE" | grep -v grep
            ;;
        3)
            echo -n "PID a matar: "
            read PID
            kill "$PID" && echo "Proceso $PID terminado." || echo "No se pudo terminar $PID."
            ;;
        4)
            echo -n "Nombre del proceso a reiniciar: "
            read NOMBRE
            PID=$(pgrep -x "$NOMBRE" | head -n 1)
            if [ -z "$PID" ]; then
                echo "Proceso '$NOMBRE' no esta en ejecucion."
            else
                CMD=$(ps -p "$PID" -o args=)
                kill "$PID" && echo "Proceso $PID terminado."
                sleep 1
                # Las tareas corriendo como root no se relanzan igual desde el menu
                if [ "$(whoami)" = "root" ]; then
                    case "$CMD" in
                        *" "* | *"/"*) sh -c "$CMD" >/dev/null 2>&1 & echo "Reiniciado: $CMD" ;;
                        *) "$CMD" >/dev/null 2>&1 & echo "Reiniciado: $CMD" ;;
                    esac
                else
                    echo "Reinicio manual (requiere privilegios): service $NOMBRE restart"
                fi
            fi
            ;;
        5)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opcion invalida."
            ;;
    esac
done