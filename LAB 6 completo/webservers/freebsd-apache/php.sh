#!/bin/sh
# Lab 6, punto 3 (parte servidor): hacer que el Apache de FreeBSD interprete PHP y pueda hablar con PostgreSQL.
# Ejecutar como root en la VM FreeBSD, despues de instalar-apache.sh.
set -e

pkg install -y php83 mod_php83 php83-pdo php83-pdo_pgsql php83-mbstring php83-session
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini

HTTPD=/usr/local/etc/apache24/httpd.conf
# mod_php necesita el MPM "prefork": se desactiva "event" y se activa "prefork"
sed -i '' 's/^LoadModule mpm_event_module/#LoadModule mpm_event_module/; s/^#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/' "$HTTPD"
grep -q 'libphp' "$HTTPD" /usr/local/etc/apache24/modules.d/*.conf 2>/dev/null || echo 'LoadModule php_module libexec/apache24/libphp.so' >> "$HTTPD"

cat > /usr/local/etc/apache24/modules.d/001_php.conf <<'CONF'
<IfModule dir_module>
    DirectoryIndex index.php index.html
</IfModule>
<FilesMatch "\.php$">
    SetHandler application/x-httpd-php
</FilesMatch>
CONF
grep -q 'modules.d/\[0-9\]' "$HTTPD" || echo 'Include etc/apache24/modules.d/[0-9][0-9][0-9]_*.conf' >> "$HTTPD"

apachectl configtest
service apache24 restart
php -v | head -1
php -m | grep -E 'pdo_pgsql|mbstring'
