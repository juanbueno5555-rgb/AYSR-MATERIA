#!/bin/bash

mostrar_procesos() {
    echo "PID | %MEM | %CPU | COMANDO"
    # Formato portable Solaris + Linux: pmem/pcpu funcionan en ambos ps;
    # el --sort de GNU no existe en Solaris, se ordena con sort.
    ps -eo pid,pmem,pcpu,comm | sort -k2 -nr
}

buscar_proceso() {
    read -p "Ingrese el nombre del proceso a buscar: " proc_name
    ps -ef | grep "$proc_name" | grep -v grep
}

matar_proceso() {
    read -p "Ingrese el PID del proceso a matar: " pid_kill
    kill -9 "$pid_kill" && echo "Proceso $pid_kill terminado."
}

reiniciar_proceso() {
    read -p "Ingrese el PID del proceso a reiniciar: " pid_restart
    CMD=$(ps -p "$pid_restart" -o args=) || { echo "PID no encontrado."; return; }
    kill -15 "$pid_restart"; sleep 1; nohup $CMD &>/dev/null &
    echo "Reiniciado: $CMD"
}

mostrar_menu() {
    echo "=============================="
    echo "      MENU DE GESTION         "
    echo "=============================="
    echo "1. Mostrar procesos en ejecucion"
    echo "2. Buscar proceso por nombre"
    echo "3. Matar un proceso"
    echo "4. Reiniciar un proceso"
    echo "5. Salir"
}

opcion=0

while [ "$opcion" -ne 5 ]; do
    mostrar_menu
    read -p "Seleccione una opcion: " opcion

    case $opcion in
        1) mostrar_procesos ;;
        2) buscar_proceso ;;
        3) matar_proceso ;;
        4) reiniciar_proceso ;;
        5) echo "Saliendo del sistema..." ;;
        *) echo "Opcion invalida. Intente de nuevo." ;;
    esac

    if [ "$opcion" -ne 5 ]; then
        echo ""
        read -p "Presione [Enter] para continuar..."
    fi
done
