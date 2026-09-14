#!/bin/bash
# Uso: ./schedult-task-script.sh min hora dia mes dia_sem comando...
# Ejemplo: ./schedult-task-script.sh "* * * * *" "/bin/date >> /tmp/fecha.log"

if [ "$#" -lt 6 ]; then
    echo "Uso: $0 min hora dia mes dia_sem comando [args...]"
    exit 1
fi

FREQ="$1 $2 $3 $4 $5"
shift 5
TASK="$*"

# Agrega al crontab sin duplicados (portable Solaris + Linux)
TMP=$(mktemp /tmp/crontab.XXXXXX)
crontab -l 2>/dev/null | grep -v -F "$TASK" > "$TMP"
echo "$FREQ $TASK" >> "$TMP"
crontab "$TMP"
rm -f "$TMP"

echo "Tarea agregada:"
echo "  $FREQ $TASK"
echo ""
echo "Crontab actual:"
crontab -l
