"""Prueba de extremo a extremo de la calculadora de notas en la VM FreeBSD (Apache + PHP + PostgreSQL de prueba).
Deja la evidencia en camilo\\evidencias\\freebsd-webapp-prueba.txt. La base de esta prueba vive en FreeBSD solo para validar el codigo;
el despliegue final usa el PostgreSQL del Lab 5 (ver LEEME-LAB6.md)."""
import datetime
import os
import secrets
import string
import sys
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fbsd import RAIZ, ssh, put

log = []


def p(s=""):
    print(s)
    log.append(s)


def paso(titulo, cmd, timeout=900):
    rc, o = ssh(cmd, timeout)
    p(f"$ {titulo}  (rc={rc})")
    if o:
        p(o)
    assert rc == 0, f"fallo: {titulo}"
    return o


def http(url, datos=None):
    req = urllib.request.Request(url, data=urllib.parse.urlencode(datos).encode() if datos else None)
    with urllib.request.urlopen(req, timeout=15) as r:
        return r.status, r.read().decode("utf-8")


pw = "Db" + "".join(secrets.choice(string.ascii_letters + string.digits) for _ in range(12))
with open(os.path.join(RAIZ, "CREDENCIALES-LAB06.md"), "a", encoding="utf-8") as f:
    f.write(f"- PostgreSQL de prueba en FreeBSD: base `notas_lab06`, usuario `webnotas`, contrasena `{pw}`\n")

p(f"== {datetime.datetime.now():%Y-%m-%d %H:%M:%S} Prueba de la calculadora de notas en freebsd-14.5-lab06")
paso("pkg install postgresql16-server postgresql16-client",
     "pkg install -y postgresql16-server postgresql16-client >/dev/null 2>&1; pkg info | grep -E '^postgresql16-(server|client)'")
paso("sysrc postgresql_enable=YES; service postgresql initdb", "sysrc postgresql_enable=YES; service postgresql initdb 2>&1 | tail -2")
paso("service postgresql start", "service postgresql start 2>&1 | tail -2")
paso("crear usuario y base de prueba",
     f"su postgres -c \"psql -c \\\"CREATE USER webnotas PASSWORD '{pw}'\\\"\"; su postgres -c \"psql -c 'CREATE DATABASE notas_lab06 OWNER webnotas'\"")
put(os.path.join(RAIZ, "webapp", "schema.sql"), "/tmp/schema.sql")
paso("cargar schema.sql", "su postgres -c 'psql -d notas_lab06 -f /tmp/schema.sql' 2>&1; su postgres -c 'psql -d notas_lab06 -c \"ALTER TABLE notas OWNER TO webnotas\"'")

put(os.path.join(RAIZ, "webapp"), "/tmp/")
paso("desplegar webapp en /usr/local/www/apache24/data/notas",
     "rm -rf /usr/local/www/apache24/data/notas && mkdir -p /usr/local/www/apache24/data/notas && cp -R /tmp/webapp/. /usr/local/www/apache24/data/notas/ "
     "&& rm -f /usr/local/www/apache24/data/notas/config.example.php /usr/local/www/apache24/data/notas/schema.sql")
paso("crear config.php", "cat > /usr/local/www/apache24/data/notas/config.php <<'CFG'\n<?php\nreturn ['host'=>'127.0.0.1','port'=>5432,'dbname'=>'notas_lab06','user'=>'webnotas','password'=>'" + pw + "'];\nCFG\n"
     "chown -R www:www /usr/local/www/apache24/data/notas && chmod 640 /usr/local/www/apache24/data/notas/config.php && ls -l /usr/local/www/apache24/data/notas")
# 127.0.0.1 con scram: el pg_hba por defecto de FreeBSD usa 'trust' en local; se exige contrasena igualmente
paso("pg_hba: contrasena para 127.0.0.1", "grep -E '^host' /var/db/postgres/data16/pg_hba.conf")

p("\n--- Prueba CLI de la logica de calculo (php tests/test_calculo.php)")
paso("php tests/test_calculo.php", "php /usr/local/www/apache24/data/notas/tests/test_calculo.php")
ssh("rm -rf /usr/local/www/apache24/data/notas/tests")

p("\n--- Pruebas HTTP desde el PC anfitrion (http://127.0.0.1:8081/notas/ -> puerto 80 de FreeBSD)")
st, cuerpo = http("http://127.0.0.1:8081/notas/")
p(f"GET /notas/ -> HTTP {st}; contiene '<?php': {'<?php' in cuerpo}; contiene 'Calculadora de notas': {'Calculadora de notas' in cuerpo}")
assert st == 200 and "<?php" not in cuerpo and "Calculadora de notas" in cuerpo

st, cuerpo = http("http://127.0.0.1:8081/notas/index.php", {"estudiante": "Ana Prueba", "nota1": "4,0", "nota2": "3", "nota3": "5"})
ok = "Nota final: 4.10" in cuerpo and "registro guardado" in cuerpo
p(f"POST Ana Prueba 4,0 / 3 / 5 -> HTTP {st}; 'Nota final: 4.10' y 'registro guardado': {ok}")
assert st == 200 and ok

st, cuerpo = http("http://127.0.0.1:8081/notas/index.php", {"estudiante": "Beto Prueba", "nota1": "2.5", "nota2": "2.5", "nota3": "2.5"})
ok = "Nota final: 2.50" in cuerpo and "no aprueba" in cuerpo
p(f"POST Beto Prueba 2.5 / 2.5 / 2.5 -> HTTP {st}; 'Nota final: 2.50' y 'no aprueba': {ok}")
assert ok

st, cuerpo = http("http://127.0.0.1:8081/notas/index.php", {"estudiante": "Malo", "nota1": "7", "nota2": "abc", "nota3": "5"})
ok = "debe ser un número entre 0 y 5" in cuerpo and "registro guardado" not in cuerpo
p(f"POST con notas invalidas (7 y abc) -> HTTP {st}; muestra errores y no guarda: {ok}")
assert ok

st, cuerpo = http("http://127.0.0.1:8081/notas/index.php", {"estudiante": "<script>alert(1)</script>", "nota1": "5", "nota2": "5", "nota3": "5"})
ok = "<script>alert(1)</script>" not in cuerpo and "&lt;script&gt;" in cuerpo
p(f"POST con nombre <script>: la pagina lo escapa (sin XSS): {ok}")
assert ok

p("\n--- Registros guardados en PostgreSQL (consulta directa en la VM)")
paso("select de notas", "su postgres -c \"psql -d notas_lab06 -c 'SELECT id, estudiante, nota1, nota2, nota3, nota_final FROM notas ORDER BY id'\"")

open(os.path.join(RAIZ, "camilo", "evidencias", "freebsd-webapp-prueba.txt"), "w", encoding="utf-8").write("\n".join(log) + "\n")
p("\nOK: evidencia guardada en camilo\\evidencias\\freebsd-webapp-prueba.txt")
