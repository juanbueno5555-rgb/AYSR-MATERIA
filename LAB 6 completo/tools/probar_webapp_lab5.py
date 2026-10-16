"""Prueba final de la calculadora: Apache+PHP en FreeBSD (8081) guardando en el PostgreSQL del Lab 5 (Slackware).
Evidencia: camilo\evidencias\webapp-postgres-lab5-prueba.txt"""
import datetime
import os
import sys
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vm

log = []


def p(s=""):
    print(s)
    log.append(s)


def http(datos=None):
    req = urllib.request.Request("http://127.0.0.1:8081/notas/index.php", data=urllib.parse.urlencode(datos).encode() if datos else None)
    with urllib.request.urlopen(req, timeout=15) as r:
        return r.status, r.read().decode("utf-8")


p(f"== {datetime.datetime.now():%Y-%m-%d %H:%M:%S} Calculadora (FreeBSD, Apache+PHP) -> PostgreSQL 14 del Lab 5 en Slackware (192.168.82.10, base notas_lab06)")
casos = [
    ("Ana Prueba", "4,0", "3", "5", "Nota final: 4.10", "registro guardado"),
    ("Beto Prueba", "2.5", "2.5", "2.5", "Nota final: 2.50", "no aprueba"),
    ("Malo", "7", "abc", "5", "debe ser un número entre 0 y 5", None),
]
for nom, a, b, c, esp, esp2 in casos:
    st, cuerpo = http({"estudiante": nom, "nota1": a, "nota2": b, "nota3": c})
    ok = esp in cuerpo and (esp2 is None and "registro guardado" not in cuerpo or esp2 is not None and esp2 in cuerpo)
    p(f"POST {nom} {a}/{b}/{c} -> HTTP {st}; esperado '{esp}': {'OK' if ok else 'FALLO'}")
    assert ok
p("\n--- Registros guardados, consultados directamente en PostgreSQL de Slackware")
rc, o = vm.ssh("slack", "su postgres -c \"psql -d notas_lab06 -c 'SELECT id, estudiante, nota1, nota2, nota3, nota_final FROM notas ORDER BY id'\"")
p(o.replace("Keyboard-interactive authentication prompts from server:\nEnd of keyboard-interactive prompts from server", "").strip())
open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "camilo", "evidencias", "webapp-postgres-lab5-prueba.txt"), "w", encoding="utf-8").write("\n".join(log) + "\n")
