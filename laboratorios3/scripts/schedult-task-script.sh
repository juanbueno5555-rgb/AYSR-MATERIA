#!/bin/bash
# Uso: ./schedult-task-script.sh * * * * * echo "Hola"
# O con intervalos: ./schedult-task-script.sh 0 5 * * * /ruta/script.sh

# Validar que al menos existan 5 campos de tiempo + 1 comando (mínimo 6 argumentos)
if [ "$#" -lt 6 ]; then
    echo "Error: Faltan argumentos."
    echo "Uso: $0 min hora dia mes dia_sem comando [argumentos_comando...]"
    exit 1
fi

# Los primeros 5 argumentos forman la frecuencia de cron
FREQUENCY="$1 $2 $3 $4 $5"

# Shift desplaza los argumentos 5 posiciones a la izquierda, 
# dejando en $@ todo lo que sobre, que es estrictamente el comando y sus flags
shift 5
TASK="$*"

# Agregar la tarea al crontab del usuario actual
(crontab -l 2>/dev/null; echo "$FREQUENCY $TASK") | crontab -

echo "Tarea programada con éxito:"
echo "Frecuencia: $FREQUENCY"
echo "Comando:    $TASK"