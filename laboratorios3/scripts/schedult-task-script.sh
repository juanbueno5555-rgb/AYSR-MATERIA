#!/bin/sh
# schedult-task-script.sh [frecuencia] [tarea]
# Programa una tarea para ejecucion periodica en cron.
# Todo via linea de comandos, SIN prompts interactivos.
#
# Ejemplos:
#   ./schedult-task-script.sh "*/1 * * * *" "/usr/bin/date >> /tmp/fecha.log"
#   ./schedult-task-script.sh "* * * * *"

FREC="${1:-* * * * *}"
TAREA="${2:-/bin/date >> /tmp/schedult-task.log}"

# Validacion basica: la frecuencia debe tener exactamente 5 campos
CAMPOS=$(echo "$FREC" | awk '{print NF}')
if [ "$CAMPOS" -ne 5 ]; then
    echo "Frecuencia invalida: '$FREC' (se esperan 5 campos: min hora dia mes semana)"
    exit 1
fi

# Agrega la tarea al crontab del usuario (sin duplicados) y conserva lo existente
( crontab -l 2>/dev/null | grep -v -F "$TAREA"; echo "$FREC $TAREA" ) | crontab -

echo "Tarea programada:"
echo "  $FREC $TAREA"
echo ""
echo "Crontab actual:"
crontab -l