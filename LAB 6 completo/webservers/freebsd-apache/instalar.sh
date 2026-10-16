#!/bin/sh
# Lab 6, 2.1.a: Apache en la VM FreeBSD. Ejecutar como root dentro de la VM FreeBSD.
set -e

pkg install -y apache24                 # instala Apache 2.4 desde el repositorio de paquetes
sysrc apache24_enable="YES"             # 2.1.e: arranque automatico al iniciar el sistema (escribe /etc/rc.conf)

cat > /usr/local/www/apache24/data/index.html <<'HTML'
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Apache en FreeBSD</title></head>
<body><h1>Apache en FreeBSD</h1><p>Laboratorio 6 de AYSR: Camilo Aguirre y Juan David Rangel.</p></body></html>
HTML

echo 'ServerName apache.camilo.org.uk' >> /usr/local/etc/apache24/httpd.conf   # evita el aviso de nombre de servidor
apachectl configtest                    # debe decir "Syntax OK"
service apache24 start
service apache24 status
sockstat -4 -l | grep ':80'             # confirma que escucha en el puerto 80
