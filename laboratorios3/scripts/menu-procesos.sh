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

    # Guardar el comando ANTES de matar (si no, se pierde)
    CMD=$(ps -p "$pid_restart" -o args=)

    if kill -15 "$pid_restart"; then
        echo "Proceso detenido. Reiniciando..."

        # Volver a lanzar el COMANDO en segundo plano (&) para que no congele el menú
        nohup $CMD >/dev/null 2>&1 &

        echo "¡Proceso $pid_restart reiniciado!"
    else
        echo "Error: No se pudo detener el proceso."
    fi
}

mostrar_menu() {
    echo "=============================="
    echo "      MENÚ DE GESTIÓN         "
    echo "=============================="
    echo "1. Mostrar procesos en ejecución"
    echo "2. Buscar proceso por nombre"
    echo "3. Matar un proceso"
    echo "4. Reiniciar un proceso"
    echo "5. Salir"
}

opcion=0

while [ "$opcion" -ne 5 ]; do
    mostrar_menu
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1) mostrar_procesos ;;
        2) buscar_proceso ;;
        3) matar_proceso ;;
        4) reiniciar_proceso ;;
        5) echo "Saliendo del sistema..." ;;
        *) echo "Opción inválida. Intente de nuevo." ;;
    esac
    
    if [ "$opcion" -ne 5 ]; then
        echo ""
        read -p "Presione [Enter] para continuar..."
    fi
done