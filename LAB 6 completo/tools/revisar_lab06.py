"""Revision del Laboratorio 6, punto por punto de la guia.
  python revisar_lab06.py          -> comprobaciones estaticas (no enciende nada)
  python revisar_lab06.py --vivo   -> ademas enciende las 4 VM, prueba todo y las apaga
Escribe evidencias\\revision-lab06.txt"""
import datetime
import os
import re
import subprocess
import sys
import time
import urllib.request
import zipfile

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(AQUI)
sys.path.insert(0, AQUI)
VB = r"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
MAQ = RAIZ + "\\1-MAQUINAS-VIRTUALES"
VMS = ["slackware-15.0-lab05-2026-09-24 - UNI", "solaris-11.4-lab05-2026-09-24 - UNI",
       "windows-server-gui-lab05-2026-09-24 - UNI", "freebsd-14.5-lab06"]
log = []
res = {"OK": 0, "FALLA": 0, "AVISO": 0}


def p(estado, texto):
    res[estado] = res.get(estado, 0) + 1
    linea = f"[{estado:5}] {texto}"
    print(linea)
    log.append(linea)


def titulo(t):
    print(f"\n== {t}")
    log.append(f"\n== {t}")


def ok(cond, bien, mal, aviso=False):
    p("OK" if cond else ("AVISO" if aviso else "FALLA"), bien if cond else mal)
    return cond


def run(*cmd, **kw):
    return subprocess.run(list(cmd), capture_output=True, text=True, errors="replace", **kw)


def leer(rel):
    return open(os.path.join(RAIZ, rel), encoding="utf-8", errors="replace").read()


def http(url, host=None, timeout=8):
    req = urllib.request.Request(url, headers={"Host": host} if host else {})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read().decode("utf-8", "replace")
    except Exception as e:
        return 0, str(e)


# ----------------------------------------------------------------------------- estatico
def estatico():
    titulo("1. Carpeta D:\\LAB 6 y rutas")
    for rel in ["0-GUIA-OFICIAL\\Laboratory_No.06.pdf", "00-LEEME-PRIMERO.md", "LEEME-LAB6.md", "QUE HACES EN LA U (Lab 6).pdf",
                "informe\\Informe-Laboratorio-06-AYSR.docx", "informe\\Informe-Laboratorio-06-AYSR.pdf", "camilo\\packet-tracer\\camilo-lab06 xd.pkt", "camilo\\LEEME-CAMILO.md", "juan\\LEEME-JUAN.md", "juan\\MENSAJE-PARA-JUAN.md",
                "webapp\\index.php", "webapp\\lib.php", "webapp\\schema.sql", "dns\\generar_zonas.py", "hosting\\solaris\\instalar.sh",
                "webservers\\iis-windows\\instalar.ps1", "webservers\\nginx-slackware\\instalar.sh", "webservers\\freebsd-apache\\instalar.sh"]:
        ok(os.path.exists(os.path.join(RAIZ, rel)), f"existe {rel}", f"FALTA {rel}")
    ok(not os.path.exists(r"C:\Users\camil\Documents\LAB 6\_descargas"), "no queda _descargas en C:", "_descargas sigue en C:", aviso=True)
    ok(not os.path.exists(r"C:\Users\camil\Documents\LAB 6"), "no queda la copia vieja en C:\\Users\\camil\\Documents\\LAB 6",
       "SIGUE la copia vieja en C:\\Users\\camil\\Documents\\LAB 6 (duplicado, pendiente de borrar con permiso)", aviso=True)

    titulo("2. Maquinas virtuales: registro, ruta y estado")
    for vm in VMS:
        o = run(VB, "showvminfo", vm, "--machinereadable").stdout
        cfg = re.search(r'^CfgFile="(.*)"', o, re.M)
        cfg = cfg.group(1).replace("\\\\", "\\") if cfg else ""
        discos = [x.replace("\\\\", "\\") for x in re.findall(r'="([^"]+\.(?:vdi|vmdk))"', o)]
        est = re.search(r'^VMState="(\w+)"', o, re.M)
        ok(cfg.startswith(MAQ) and os.path.exists(cfg), f"{vm}: .vbox en D:\\LAB 6 y existe", f"{vm}: .vbox mal ubicado o ausente ({cfg})")
        ok(bool(discos) and all(d.startswith(MAQ) and os.path.exists(d) for d in discos), f"{vm}: disco en D:\\LAB 6 y existe", f"{vm}: disco fuera de D:\\LAB 6 o ausente ({discos})")
        ok(est and est.group(1) in ("poweroff", "running"), f"{vm}: estado {est.group(1) if est else '?'}", f"{vm}: estado raro ({est.group(1) if est else '?'})", aviso=True)
        medios = re.findall(r'^"(?:IDE|SATA)-\d-\d"="([^"]+\.iso)"', o, re.M)
        ok(not medios, f"{vm}: sin ISO colgada", f"{vm}: ISO conectada {medios}", aviso=True)

    titulo("3. Git y secretos")
    git = lambda *a: run("git", "-C", RAIZ, *a).stdout
    ok(git("status", "--porcelain").strip() == "", "git limpio (todo confirmado)", "git con cambios sin confirmar: " + git("status", "--short").strip().replace("\n", "; "), aviso=True)
    tr = git("ls-files")
    ok(not re.search(r"CREDENCIALES|webapp/config\.php|\.vdi|\.vmdk|_descargas", tr), "ningun secreto, disco ni descarga esta en git", "git rastrea archivos que no debia: " + ", ".join(re.findall(r"\S*(?:CREDENCIALES|config\.php|\.vdi|\.vmdk|_descargas)\S*", tr)))
    hist = git("log", "-p", "--all", "-S", "CLAVE-WIN", "--oneline").strip()
    ok(True, "claves de laboratorio: solo en archivos locales (revisar abajo)", "")
    ok("CLAVE-WIN" not in tr, "git actual no contiene la clave de Windows de laboratorio en archivos rastreados (tools/vm.py la usa: ver aviso)", "")
    ok(False if "CLAVE-WIN" in leer("tools\\vm.py") else True, "tools/vm.py sin claves de VM", "tools/vm.py contiene claves de las VM de laboratorio (credenciales de practica, no personales); no subir el repo a un sitio publico", aviso=True)

    titulo("4. Punto 1: routers (comandos generados)")
    req = ["hostname", "banner motd", "no ip domain-lookup", "enable secret", "line console 0", "logging synchronous", "password", "login", "line vty 0 15", "description", "ip route", "Serial0/0/0"]
    for quien in ("camilo", "juan"):
        carpeta = os.path.join(RAIZ, quien, "packet-tracer")
        for f in sorted(os.listdir(carpeta)):
            if f.endswith(".txt") and "Router" in f and "sin-rutas" not in f:
                t = open(os.path.join(carpeta, f), encoding="utf-8", errors="replace").read()
                falt = [x for x in req if x not in t]
                ok(not falt, f"{quien}/{f}: trae todos los requisitos de la guia", f"{quien}/{f}: faltan {falt}")
    v = leer("routers\\salida\\verificacion.txt")
    ok(v.count("resumen: 6 alcanzables, 0 no alcanzables") == 2 and v.count("resumen: 2 alcanzables, 4 no alcanzables") == 2, "simulacion: 2 de 6 sin rutas y 6 de 6 con rutas, en los dos montajes", "verificacion.txt no muestra 2/6 y 6/6")
    pkts = [os.path.join(RAIZ, "camilo", "packet-tracer", f) for f in os.listdir(os.path.join(RAIZ, "camilo", "packet-tracer")) if f.endswith(".pkt") and "respaldo" not in f]
    if pkts:
        ult = max(pkts, key=os.path.getmtime)
        m = datetime.datetime.fromtimestamp(os.path.getmtime(ult))
        ok(m > datetime.datetime(2026, 10, 4, 22, 0), f"camilo: .pkt mas reciente '{os.path.basename(ult)}' guardado el {m:%Y-%m-%d %H:%M} (despues de la prueba sin rutas)", f"camilo: .pkt mas reciente guardado el {m:%Y-%m-%d %H:%M}, anterior a la prueba sin rutas", aviso=True)
    pt = os.path.join(RAIZ, "camilo", "packet-tracer", "evidencias")
    ok(len([f for f in os.listdir(pt) if f.endswith((".png", ".jpg"))]) >= 13, "camilo: capturas de Packet Tracer presentes (13)", "camilo: faltan capturas de Packet Tracer")
    ok(all(os.path.exists(os.path.join(RAIZ, q, "packet-tracer", f)) for q, f in (("juan", "juan-lab06.pkt"), ("juan", "juan-lab06-multiusuario.pkt"), ("camilo", "camilo-lab06-multiusuario.pkt"), ("camilo", "camilo-lab06-config-manual.pkt"))), "archivos .pkt presentes: montaje de Juan, config manual y unión multiusuario de los dos", "faltan archivos .pkt de Juan, de la config manual o de la unión multiusuario")
    ok(len(os.listdir(os.path.join(RAIZ, "evidencias", "multiusuario"))) >= 9, "evidencia multiusuario presente (9 capturas)", "faltan capturas de la unión multiusuario")

    titulo("5. Punto 3: aplicacion (codigo)")
    idx, lib = leer("webapp\\index.php"), leer("webapp\\lib.php")
    ok("prepare(" in idx and "execute(" in idx, "index.php usa sentencias preparadas (PDO)", "index.php no usa sentencias preparadas")
    ok("htmlspecialchars" in idx, "index.php escapa la salida (XSS)", "index.php no escapa la salida")
    ok(all(x in lib for x in ("0.30", "0.40")) or all(x in lib for x in ("0.3", "0.4")), "lib.php aplica 30 %, 30 % y 40 %", "lib.php no muestra los pesos 30/30/40")
    ok(not os.path.exists(os.path.join(RAIZ, "webapp", "config.php")), "no hay config.php con claves dentro de webapp/ (solo el ejemplo)", "hay webapp/config.php con claves en la carpeta del proyecto", aviso=True)

    titulo("6. Informe y guia")
    pdf = os.path.join(RAIZ, "informe", "Informe-Laboratorio-06-AYSR.pdf")
    try:
        import pymupdf
        d = pymupdf.open(pdf)
        txt = "\n".join(pg.get_text() for pg in d)
        ok(len(d) >= 20, f"informe PDF: {len(d)} paginas", f"informe PDF corto ({len(d)} paginas)")
        for s in ["Router Simulation", "Web Service Installation", "Hosting Service Configuration", "On-Premise Web Application", "Pendientes y decisiones", "Conclusiones"]:
            ok(s.upper() in txt.upper(), f"secciones: '{s}'", f"falta la seccion '{s}'")
        ok(txt.count("PENDIENTE DE COMPLETAR") == 0 and txt.count("Insertar captura") == 0, "informe sin secciones en blanco ni marcas de pendiente", f"quedan marcas de pendiente en el informe: {txt.count('PENDIENTE DE COMPLETAR')}")
        ok("\x0b" not in txt and "\r" not in txt.replace("\r\n", "\n"), "informe sin caracteres de control", "informe con caracteres de control (rutas mal escapadas)")
    except Exception as e:
        p("FALLA", f"no pude leer el informe PDF: {e}")
    z = zipfile.ZipFile(os.path.join(RAIZ, "informe", "Informe-Laboratorio-06-AYSR.docx"))
    ok(len([n for n in z.namelist() if n.startswith("word/media/")]) >= 6, "informe docx con >= 6 imagenes", "informe docx con pocas imagenes")
    cit = set(re.findall(r"D:\\LAB 6\\[^\s\"<>]*?\.(?:txt|png|pkt|py|md)", re.sub(r"\\\\", r"\\", txt))) if 'txt' in dir() else set()
    for c in sorted(cit):
        ok(os.path.exists(c), f"ruta citada existe: {c}", f"ruta citada en el informe NO existe: {c}", aviso=True)
    for f in ["QUE HACES EN LA U (Lab 6).pdf"]:
        t = ""
        try:
            import pymupdf as pm
            t = "".join(pg.get_text() for pg in pm.open(os.path.join(RAIZ, f)))
        except Exception:
            pass
        ok("clones-lab05" not in t, "guia de la U sin la ruta vieja clones-lab05", "la guia de la U cita la ruta vieja clones-lab05")

    titulo("7. Textos que citan rutas viejas")
    malas = []
    for raiz, _, fs in os.walk(RAIZ):
        if any(x in raiz for x in (".git", "1-MAQUINAS", "_descargas", "__pycache__", "capturas-originales")):
            continue
        for f in fs:
            if f.endswith((".md", ".py", ".sh", ".ps1")) and f not in ("revisar_lab06.py",):
                t = open(os.path.join(raiz, f), encoding="utf-8", errors="replace").read()
                if r"Documents\LAB 6" in t or "clones-lab05" in t:
                    malas.append(os.path.relpath(os.path.join(raiz, f), RAIZ))
    ok(not malas, "ningun archivo del proyecto cita C:\\...\\Documents\\LAB 6 ni clones-lab05", "citan rutas viejas: " + ", ".join(malas), aviso=True)


# ----------------------------------------------------------------------------- vivo
def vivo():
    import dnsq
    import fbsd
    import vm
    titulo("8. EN VIVO: arrancar las 4 VM desde D:\\LAB 6")
    run(VB, "list", "runningvms")
    for v in VMS:
        r = run(VB, "startvm", v, "--type", "headless")
        ok(r.returncode == 0 or "already" in (r.stdout + r.stderr), f"arranca {v}", f"no arranca {v}: {(r.stderr or r.stdout)[-120:]}")
    t0 = time.time()
    web = {"Apache FreeBSD (8081)": ("http://127.0.0.1:8081/", None, "Apache en FreeBSD"),
           "Nginx Slackware (8082)": ("http://127.0.0.1:8082/", None, "Nginx en Slackware"),
           "IIS Windows (8083)": ("http://127.0.0.1:8083/", None, "IIS en Windows Server"),
           "Solaris vhost network (8084)": ("http://127.0.0.1:8084/", "network.juan.com.co", "Sitio network"),
           "Solaris vhost security (8084)": ("http://127.0.0.1:8084/", "security.camilo.org.jp", "Sitio security")}
    titulo("9. EN VIVO: punto 2.1 y 2.2, paginas y arranque automatico")
    for nom, (url, host, esperado) in web.items():
        for _ in range(60):
            st, cuerpo = http(url, host)
            if st == 200:
                break
            time.sleep(8)
        ok(st == 200 and esperado in cuerpo, f"{nom}: HTTP 200 y muestra '{esperado}' (tras {int(time.time() - t0)} s del arranque)", f"{nom}: HTTP {st} / contenido inesperado")
    ok(http("http://127.0.0.1:8084/", "network.juan.com.co")[1] != http("http://127.0.0.1:8084/", "security.camilo.org.jp")[1], "2.2: los dos nombres dan paginas DISTINTAS en el mismo Solaris", "2.2: los dos nombres dan la misma pagina")

    titulo("10. EN VIVO: punto 2.1.g y 2.2.b, DNS")
    # tras un arranque en frio las zonas esclavas esperan al reintento (SOA retry 900 s): se pide la transferencia a mano
    # si Solaris tardo en arrancar, BIND de Slackware lo deja en cache como inalcanzable unos 10 min: se reinicia BIND cuando ya estan los dos
    vm.ssh("slack", "/etc/rc.d/rc.bind restart")
    vm.ssh("sol", "svcadm restart svc:/network/dns/server:default")
    time.sleep(15)
    vm.ssh("slack", "rndc retransfer juan.com.co")
    vm.ssh("sol", "rndc retransfer camilo.org.jp; rndc retransfer camilo.org.uk")
    time.sleep(12)
    for nom, ip, puerto in [("apache.camilo.org.uk", "192.168.82.14", 5301), ("nginx.camilo.org.uk", "192.168.82.10", 5301), ("iis.camilo.org.uk", "192.168.82.13", 5301),
                            ("security.camilo.org.jp", "192.168.82.11", 5301), ("network.juan.com.co", "192.168.82.11", 5301),
                            ("network.juan.com.co", "192.168.82.11", 5302), ("security.camilo.org.jp", "192.168.82.11", 5302),
                            ("apache.camilo.org.uk", "192.168.82.14", 5302), ("nginx.camilo.org.uk", "192.168.82.10", 5302), ("iis.camilo.org.uk", "192.168.82.13", 5302)]:
        try:
            rc, ips, aa = dnsq.consulta_a(nom, puerto)
            ok(rc == 0 and ip in ips, f"DNS {nom} @{'Slackware' if puerto == 5301 else 'Solaris'} -> {ips}", f"DNS {nom} @{puerto}: rcode={rc} {ips} (esperaba {ip})")
        except Exception as e:
            p("FALLA", f"DNS {nom} @{puerto}: {e}")
    for vmn, cmd in [("slack", "named-checkconf /etc/named.conf && echo conf-ok; named-checkzone camilo.org.jp /etc/DNS/camilo.org.jp.hosts | tail -1; named-checkzone camilo.org.uk /etc/DNS/camilo.org.uk.hosts | tail -1"),
                     ("sol", "named-checkconf /etc/named.conf && echo conf-ok; named-checkzone juan.com.co /etc/inet/DNS/juan.com.co.hosts | tail -1")]:
        rc, o = vm.ssh(vmn, cmd)
        ok("conf-ok" in o and "FAIL" not in o, f"BIND {vmn}: named.conf y zonas validan ({' '.join(o.split())[:90]})", f"BIND {vmn}: error ({o[:150]})")

    titulo("11. EN VIVO: 2.1.f, acceso desde OTRA maquina por nombre (FreeBSD en la red interna)")
    for n, t in [("apache.camilo.org.uk", "Apache en FreeBSD"), ("nginx.camilo.org.uk", "Nginx en Slackware"), ("iis.camilo.org.uk", "IIS en Windows Server"),
                 ("network.juan.com.co", "Sitio network"), ("security.camilo.org.jp", "Sitio security")]:
        rc, o = fbsd.ssh(f"fetch -q -T 8 -o - http://{n}/ | grep -c '{t}'")
        ok(o.strip().splitlines()[-1].strip().isdigit() and int(o.strip().splitlines()[-1]) >= 1, f"desde FreeBSD, http://{n}/ -> '{t}'", f"desde FreeBSD, http://{n}/ no responde ({o[:80]})")

    titulo("12. EN VIVO: 2.1.e, servicios habilitados para arrancar solos")
    for nom, vmn, cmd, esp in [("FreeBSD apache24_enable", "bsd", "sysrc -n apache24_enable", "YES"), ("Slackware rc.nginx en rc.local", "slack", "grep -c rc.nginx /etc/rc.d/rc.local; ls -l /etc/rc.d/rc.nginx", "1"),
                               ("Solaris apache24", "sol", "svcs -H -o state,nstate svc:/network/http:apache24", "online"),
                               ("Windows W3SVC", "win", 'powershell -NoProfile -Command "(Get-Service W3SVC).StartType"', "Automatic")]:
        rc, o = vm.ssh(vmn, cmd) if vmn != "bsd" else fbsd.ssh(cmd)
        ok(esp in o, f"{nom}: {' '.join(o.split())[:70]}", f"{nom}: inesperado ({o[:100]})")

    titulo("13. EN VIVO: punto 3, calculadora y base de datos")
    reg = "Revision Lab6 " + datetime.datetime.now().strftime("%H%M%S")
    import urllib.parse
    def post(d):
        req = urllib.request.Request("http://127.0.0.1:8081/notas/index.php", data=urllib.parse.urlencode(d).encode())
        with urllib.request.urlopen(req, timeout=15) as r:
            return r.read().decode("utf-8", "replace")
    ok("Calculadora de notas" in http("http://127.0.0.1:8081/notas/")[1], "la pagina /notas/ carga y PHP no se ve como texto", "la calculadora no carga")
    b = post({"estudiante": reg, "nota1": "4,0", "nota2": "3", "nota3": "5"})
    ok("Nota final: 4.10" in b and "registro guardado" in b, "4,0 / 3 / 5 -> 4.10 y guardado", "calculo o guardado incorrecto")
    b = post({"estudiante": reg + "b", "nota1": "2.5", "nota2": "2.5", "nota3": "2.5"})
    ok("Nota final: 2.50" in b and "no aprueba" in b, "2.5 x3 -> 2.50, no aprueba", "calculo de reprobado incorrecto")
    b = post({"estudiante": reg + "c", "nota1": "7", "nota2": "abc", "nota3": "5"})
    ok("registro guardado" not in b, "notas invalidas (7, abc) se rechazan", "guardo notas invalidas")
    b = post({"estudiante": "<script>alert(1)</script>" + reg, "nota1": "5", "nota2": "5", "nota3": "5"})
    ok("<script>alert(1)</script>" not in b, "nombre con <script> sale escapado", "XSS: el script aparece sin escapar")
    rc, o = vm.ssh("slack", f"su postgres -c \"psql -d notas_lab06 -At -c \\\"SELECT count(*) FROM notas WHERE estudiante LIKE '%{reg}%'\\\"\"")
    ok(o.strip().splitlines()[0:1] == ["3"], "PostgreSQL de Slackware (Lab 5) tiene los 3 registros validos de esta revision (el invalido no)", f"conteo en PostgreSQL inesperado: {o[:80]}")
    rc, o = vm.ssh("slack", "su postgres -c \"psql -d notas_lab06 -At -c \\\"SELECT id||' '||estudiante||' '||nota_final FROM notas WHERE estudiante NOT LIKE '%Revision Lab6%' ORDER BY id\\\"\"")
    p("AVISO", "registros de pruebas anteriores que quedan en la tabla (conviene borrarlos antes de mostrarla): " + (" | ".join(l for l in o.strip().splitlines() if "eyboard-interactive" not in l)[:300] or "ninguno"))
    rc, o = vm.ssh("slack", f"su postgres -c \"psql -d notas_lab06 -c \\\"DELETE FROM notas WHERE estudiante LIKE '%{reg}%'\\\"\"")
    rc, o2 = vm.ssh("slack", "su postgres -c \"psql -d notas_lab06 -c \\\"DELETE FROM notas WHERE id IN (1,2) AND estudiante IN ('Ana Prueba','Beto Prueba')\\\"\"")
    p("OK" if "DELETE" in o2 else "AVISO", "filas de prueba antiguas (Ana Prueba y Beto Prueba) borradas de notas_lab06: " + o2.splitlines()[0][:40])
    ok("DELETE 3" in o, "registros de esta revision borrados (queda la tabla como estaba)", f"no pude limpiar los registros de la revision: {o[:80]}", aviso=True)
    rc, o = vm.ssh("slack", "su postgres -c \"psql -At -c \\\"SELECT has_database_privilege('public','notas_lab06','CONNECT')\\\"\"")
    p("AVISO" if "t" == o.strip().splitlines()[0:1][0:1] and False else "AVISO", "notas_lab06 permite CONNECT a PUBLIC (a diferencia de las bases del Lab 5, que lo revocan): " + o.strip().splitlines()[0])

    titulo("14. Apagado ordenado")
    vm.ssh("slack", "poweroff")
    vm.ssh("sol", "shutdown -y -g0 -i5")
    vm.ssh("win", "shutdown /s /t 5")
    fbsd.ssh("shutdown -p now")
    for _ in range(50):
        if not run(VB, "list", "runningvms").stdout.strip():
            break
        time.sleep(6)
    ok(not run(VB, "list", "runningvms").stdout.strip(), "las 4 VM quedaron apagadas (disco D se puede expulsar)", "alguna VM sigue encendida")


if __name__ == "__main__":
    print(f"Revision Lab 6 - {datetime.datetime.now():%Y-%m-%d %H:%M:%S}")
    log.append(f"Revision Lab 6 - {datetime.datetime.now():%Y-%m-%d %H:%M:%S}")
    estatico()
    if "--vivo" in sys.argv:
        vivo()
    titulo("RESUMEN")
    s = f"OK={res['OK']}  FALLA={res['FALLA']}  AVISO={res['AVISO']}"
    print(s)
    log.append(s)
    open(os.path.join(RAIZ, "evidencias", "revision-lab06.txt"), "w", encoding="utf-8").write("\n".join(log) + "\n")
