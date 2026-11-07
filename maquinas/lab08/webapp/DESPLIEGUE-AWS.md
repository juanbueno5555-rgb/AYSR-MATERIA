# Calculadora de notas en AWS (Lab 8, parte 2, punto 1)

La aplicación es la misma del Lab 6 (`index.php`, `lib.php`, `schema.sql`): pide el nombre y las tres notas, calcula
30 % + 30 % + 40 % y guarda el registro en PostgreSQL. Lo nuevo del Lab 8 es que corre en una instancia de AWS.

> Estado: la aplicación se probó en el Lab 6 (FreeBSD con PHP 8.3 y PostgreSQL). El despliegue en AWS **no se ha ejecutado**:
> requiere la cuenta del laboratorio en la nube, y los comandos de abajo (paquetes de Amazon Linux 2023) no se han probado.

## 1. Instancia
1. En el laboratorio de AWS, lanzar una instancia EC2 con Amazon Linux 2023 (o Ubuntu).
2. Security group: abrir TCP 22 (SSH, solo desde la IP propia) y TCP 80 (HTTP). **No** abrir el 5432 al público.

## 2. Apache, PHP y PostgreSQL (Amazon Linux 2023)
```sh
sudo dnf install -y httpd php php-pgsql php-pdo php-mbstring postgresql15-server
sudo postgresql-setup --initdb
sudo systemctl enable --now httpd postgresql
```
- `enable --now` deja los servicios arrancando solos y los enciende ahora.
- `php-pgsql` y `php-pdo` son el controlador que usa la aplicación para hablar con PostgreSQL.

## 3. Base de datos
```sh
sudo -u postgres psql -c "CREATE USER webnotas WITH PASSWORD 'ELEGIR_UNA_CLAVE';"
sudo -u postgres psql -c "CREATE DATABASE notas_lab08 OWNER webnotas;"
sudo -u postgres psql -d notas_lab08 -f schema.sql
```
La base está en la misma instancia, así que la aplicación se conecta a `127.0.0.1` y no hace falta tocar `pg_hba.conf`
más que para dejar el método `scram-sha-256` (o `md5`) en la línea de `127.0.0.1/32`.

## 4. Aplicación
```sh
sudo mkdir -p /var/www/html/notas
sudo cp index.php lib.php /var/www/html/notas/
sudo cp config.example.php /var/www/html/notas/config.php
sudo nano /var/www/html/notas/config.php     # poner dbname notas_lab08, user webnotas y la clave elegida
sudo chown -R apache:apache /var/www/html/notas
sudo systemctl restart httpd
```

## 5. Prueba
1. Abrir `http://IP-PUBLICA-DE-LA-INSTANCIA/notas/`.
2. Enviar nombre y notas 4.0, 3.5 y 5.0: la nota final debe ser **4.25** (aprobado).
3. Comprobar el registro: `sudo -u postgres psql -d notas_lab08 -c "select * from notas;"`.
4. Probar una nota inválida (por ejemplo 7): debe rechazarla.

## Prueba del cálculo sin servidor
```sh
php tests/test_calculo.php
```
