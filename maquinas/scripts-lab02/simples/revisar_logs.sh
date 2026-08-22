#!/bin/bash
# revisar_logs.sh - Muestra las ultimas lineas de los logs del sistema (version simple)

# 1. Preguntamos cuantas lineas quiere ver
echo "Cuantas lineas de cada log queres ver?"
read lineas

# 2. Mostramos las ultimas lineas de cada log
echo "===== syslog ====="
tail -n "$lineas" /var/log/syslog

echo "===== messages ====="
tail -n "$lineas" /var/log/messages

# secure no siempre existe: si no esta, avisamos y seguimos
echo "===== secure ====="
tail -n "$lineas" /var/log/secure 2>/dev/null || echo "(el log secure no existe)"
