#!/bin/sh
# Lab 6, 2.1.b: Nginx en Slackware 15.0. Ejecutar como root dentro de la VM Slackware.
# Slackware no trae un paquete nginx oficial en el medio de instalacion que usamos: se compila desde el codigo fuente,
# igual que se hizo con PostgreSQL en el Lab 5. Version a verificar en https://nginx.org/en/download.html
set -e
NGINX_VER="${NGINX_VER:-1.26.3}"

if ! command -v nginx >/dev/null 2>&1 && [ ! -x /usr/local/nginx/sbin/nginx ]; then
  cd /usr/local/src
  [ -f "nginx-$NGINX_VER.tar.gz" ] || wget "https://nginx.org/download/nginx-$NGINX_VER.tar.gz"
  tar xzf "nginx-$NGINX_VER.tar.gz"
  cd "nginx-$NGINX_VER"
  ./configure --prefix=/usr/local/nginx   # necesita gcc, make, pcre, zlib y openssl (incluidos en Slackware completo)
  make
  make install
fi
NGINX=/usr/local/nginx/sbin/nginx

mkdir -p /srv/lab06/nginx
cat > /srv/lab06/nginx/index.html <<'HTML'
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Nginx en Slackware</title></head>
<body><h1>Nginx en Slackware</h1><p>Laboratorio 6 de AYSR: Camilo Aguirre y Juan David Rangel.</p></body></html>
HTML

cat > /usr/local/nginx/conf/nginx.conf <<'CONF'
worker_processes 1;
events { worker_connections 256; }
http {
    include       mime.types;
    default_type  text/html;
    server {
        listen 80;
        server_name nginx.camilo.org.uk;
        root /srv/lab06/nginx;
        index index.html;
    }
}
CONF

# Si el Apache incluido en Slackware ocupa el puerto 80, se detiene (en Slackware solo corre si rc.httpd es ejecutable)
[ -x /etc/rc.d/rc.httpd ] && /etc/rc.d/rc.httpd stop || true

# 2.1.e: arranque automatico, con el mismo mecanismo del Lab 5 (rc.local ejecuta un script rc.*)
cat > /etc/rc.d/rc.nginx <<'RC'
#!/bin/sh
NGINX=/usr/local/nginx/sbin/nginx
case "$1" in
  start)   $NGINX ;;
  stop)    $NGINX -s stop ;;
  restart) $NGINX -s stop; sleep 1; $NGINX ;;
  status)  pgrep -l nginx ;;
  *) echo "Uso: $0 start|stop|restart|status"; exit 1 ;;
esac
RC
chmod 755 /etc/rc.d/rc.nginx
grep -q 'rc.nginx' /etc/rc.d/rc.local || printf '\n# Lab 6: Nginx\n[ -x /etc/rc.d/rc.nginx ] && /etc/rc.d/rc.nginx start\n' >> /etc/rc.d/rc.local

$NGINX -t                       # debe decir "syntax is ok"
/etc/rc.d/rc.nginx restart
/etc/rc.d/rc.nginx status
ss -ltn | grep ':80 ' || netstat -ltn | grep ':80 '
