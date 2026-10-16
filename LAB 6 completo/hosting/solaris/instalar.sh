#!/bin/sh
# Lab 6, 2.2: hosting virtual en Apache de Solaris. Ejecutar como root dentro de la VM Solaris 11.4.
# VERIFICAR en la VM los nombres de paquete, servicio y rutas antes de dar por buena cada orden (no se pudo probar sin la VM).
set -e

pkg install -r web/server/apache-24 2>/dev/null || pkg list web/server/apache-24      # Apache 2.4 de Solaris 11.4
svcs -a | grep -i apache                                                              # nombre del servicio (svc:/network/http:apache24)

CONF=/etc/apache2/2.4/httpd.conf
ROOT=/var/apache2/2.4/htdocs

mkdir -p "$ROOT/network" "$ROOT/security" /etc/apache2/2.4/extra   # en Solaris no existe extra/
for s in network security; do
cat > "$ROOT/$s/index.html" <<HTML
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Sitio $s</title></head>
<body><h1>Sitio $s</h1><p>Hosting virtual en Solaris. Laboratorio 6 de AYSR.</p></body></html>
HTML
done

# Hosts virtuales por nombre: tres URLs distintas llegan al mismo servidor y cada una muestra su pagina
# (el tercer sitio del enunciado, systems.<nombre3>.com.cl, queda pendiente para un grupo de 2: ver LEEME-LAB6.md)
cat > /etc/apache2/2.4/extra/lab06-vhosts.conf <<'VH'
<VirtualHost *:80>
    ServerName network.juan.com.co
    DocumentRoot /var/apache2/2.4/htdocs/network
    <Directory /var/apache2/2.4/htdocs/network>
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost *:80>
    ServerName security.camilo.org.jp
    DocumentRoot /var/apache2/2.4/htdocs/security
    <Directory /var/apache2/2.4/htdocs/security>
        Require all granted
    </Directory>
</VirtualHost>
VH
grep -q 'lab06-vhosts.conf' "$CONF" || echo 'Include /etc/apache2/2.4/extra/lab06-vhosts.conf' >> "$CONF"

/usr/apache2/2.4/bin/apachectl configtest        # debe decir "Syntax OK"
svcadm enable -s apache24                        # enable -s deja el servicio habilitado tambien tras reiniciar (arranque automatico)
svcs apache24
