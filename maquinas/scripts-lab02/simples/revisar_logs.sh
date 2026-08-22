#!/bin/bash
# Muestra las ultimas 15 lineas de los 3 logs del sistema

tail -15 /var/log/syslog
echo "-----"
tail -15 /var/log/messages
echo "-----"
tail -15 /var/log/secure 2>/dev/null || echo "(no hay log secure)"
