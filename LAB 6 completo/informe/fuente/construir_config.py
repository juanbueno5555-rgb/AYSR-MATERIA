"""Bitacora completa del Laboratorio 6 en el formato de la Escuela (mismo generador del Lab 5).
Uso: python construir_config.py  -> config.json ; luego generate_informe.py --config config.json --out ...docx"""
import json
import os

RAIZ = "D:/LAB 6/"
EV = RAIZ + "evidencias/"
CEV = RAIZ + "camilo/evidencias/"


def leer(ruta, max_lineas=40, ini=0):
    t = open(ruta, encoding="utf-8", errors="replace").read().strip().splitlines()[ini:]
    if len(t) > max_lineas:
        t = t[:max_lineas // 2] + ["[... recortado ...]"] + t[-max_lineas // 2:]
    return "\n".join(t)


def P(t): return {"p": t}
def H(t): return {"h": t}
def C(et, cod): return {"codigo": {"etiqueta": et, "texto": cod}}
def T(rows, cap, widths): return {"tabla": {"filas": rows, "anchos": widths, "caption": cap}}


PT = RAIZ + "camilo/packet-tracer/evidencias/"
JIMG = RAIZ + "juan/packet-tracer/evidencias/"
MIMG = RAIZ + "evidencias/multiusuario/"
def IMG(f, cap, w=12): return {"imagen": {"path": PT + f, "caption": cap, "width_cm": w}}
def IMGJ(f, cap, w=12): return {"imagen": {"path": JIMG + f, "caption": cap, "width_cm": w}}
def IMGU(f, cap, w=12): return {"imagen": {"path": MIMG + f, "caption": cap, "width_cm": w}}

# ------------------------------------------------------------------ I
entorno = [
    T([["Máquina", "IP red interna", "IP universidad", "Servicio", "Puertos en el PC"],
       ["FreeBSD 14.5", "192.168.82.14", "10.2.78.78", "Apache, PHP 8.3", "HTTP 8081, SSH 2226"],
       ["Slackware 15.0", "192.168.82.10", "10.2.78.74", "Nginx, BIND, PostgreSQL", "HTTP 8082, DNS 5301, SSH 2222"],
       ["Windows Server", "192.168.82.13", "10.2.78.76", "IIS", "HTTP 8083, SSH 2225"],
       ["Solaris 11.4", "192.168.82.11", "10.2.78.75", "Apache (vhosts), BIND", "HTTP 8084, DNS 5302, SSH 2223"]],
      "Máquinas virtuales (VirtualBox 7.2). En casa: NAT y red interna lab-uni; en la universidad: adaptador puente.", [3, 3, 3.2, 4, 4]),
]

# ------------------------------------------------------------------ II
routers = [
    P("Dos routers 1941 con módulo HWIC-2T, cuatro PC y un enlace serial 20.0.0.0/8 (Router0 .1 con clock rate 64000 como DCE, Router1 .2). Cada router lleva hostname, "
      "mensaje del día \"For exclusive use by RECO students\", no ip domain-lookup, logging synchronous, descripciones y las claves ClaveE (enable secret), ClaveC (consola) y ClaveT (vty)."),
    T([["", "Juan (Student 01)", "Camilo (Student 02)"],
       ["Router0 / Router1", "Juan / Rangel", "Camilo / Aguirre"],
       ["Red 1 (Router0, PC0)", "132.18.0.0/16", "72.0.0.0/8"],
       ["Red 2 (Router0, PC1)", "132.19.0.0/16", "73.0.0.0/8"],
       ["Red 3 (Router1, PC2)", "132.20.0.0/16", "74.0.0.0/8"],
       ["Red 4 (Router1, PC3)", "132.21.0.0/16", "75.0.0.0/8"],
       ["Serial Router0 - Router1", "20.0.0.0/8", "20.0.0.0/8"]],
      "Direccionamiento (en cada LAN el router es .1 y el PC es .2). Se asumió Student 01 = Juan.", [5, 5, 5]),
]
camilo = [
    IMG("00-topologia-camilo.png", "Topología de Camilo: routers Camilo y Aguirre, cuatro PC, serial (rojo) y consola (azul claro).", 14),
    H("Sin rutas estáticas"),
    T([["Prueba", "Resultado"],
       ["PC0 a PC1 (73.0.0.2)", "Funciona, TTL 127"],
       ["PC0 a PC2 y PC3 (74 y 75)", "Falla: Destination host unreachable desde 72.0.0.1"],
       ["PC2 a PC3 (75.0.0.2)", "Funciona, TTL 127"],
       ["PC2 a PC0 (72.0.0.2)", "Falla: Destination host unreachable desde 74.0.0.1"]],
      "Solo se comunican los PC del mismo router: cada router descarta lo que no tiene en su tabla.", [6, 9]),
    H("Con rutas estáticas"),
    P("Rutas con interfaz de salida: Camilo hacia 74 y 75 por Serial0/0/0; Aguirre hacia 72 y 73. Guardado con copy running-config startup-config ([OK])."),
    IMG("01-camilo-show-ip-route-con-rutas-guardado-OK.png", "show ip route de Camilo con rutas S hacia 74 y 75, guardado [OK].", 11),
    IMG("02-aguirre-show-ip-route-con-rutas-guardado-OK.png", "show ip route de Aguirre con rutas S hacia 72 y 73, guardado [OK].", 11),
    IMG("03-pc0-ping-con-rutas.png", "PC0: ping a 73, 74 y 75.0.0.2, 4 de 4 (TTL 127 y 126).", 10),
    IMG("05-pc3-ping-72.0.0.2.png", "PC3: ping a 72.0.0.2, 4 de 4 (TTL 126).", 9),
    IMG("04-pc0-tracert-75.0.0.2.png", "tracert 75.0.0.2 desde PC0: 72.0.0.1, 20.0.0.2 y 75.0.0.2.", 10),
]
manual = [
    P("Aguirre se borró (erase startup-config y reload) y se configuró a mano por la consola de PC2, en dos tandas: primero sin rutas y luego con ellas. Archivo: camilo-lab06-config-manual.pkt (15-oct-2026)."),
    IMG("07-aguirre-manual-show-ip-route-sin-rutas.jpg", "Aguirre configurado a mano, sin rutas: solo conectadas (C) y locales (L).", 11),
    IMG("08-aguirre-manual-rutas-guardado-OK.jpg", "Rutas estáticas a mano en Aguirre, guardado [OK] y show ip route con S hacia 72 y 73.", 11),
    IMG("09-pc2-ping-sin-y-con-rutas-y-tracert.jpg", "PC2: ping a 72.0.0.2 falla sin rutas y responde con ellas (TTL 126); tracert con tres saltos.", 11),
    IMG("10-aguirre-manual-running-config-p1.jpg", "running-config de Aguirre (1 de 5).", 10),
    IMG("11-aguirre-manual-running-config-p2.jpg", "running-config de Aguirre (2 de 5).", 10),
    IMG("12-aguirre-manual-running-config-p3.jpg", "running-config de Aguirre (3 de 5): no ip domain-lookup, descripciones e IP.", 10),
    IMG("13-aguirre-manual-running-config-p4.jpg", "running-config de Aguirre (4 de 5).", 10),
    IMG("14-aguirre-manual-running-config-p5-final.jpg", "running-config de Aguirre (5 de 5): rutas, banner y claves.", 10),
]
juan = [
    P("Armado el 15-oct-2026. Misma topología, routers borrados y configurados a mano. Archivo: juan-lab06.pkt."),
    T([["Equipo", "Interfaz", "Dirección", "Observación"],
       ["Juan", "Gig0/0", "132.18.0.1/16", "PC0 132.18.0.2"],
       ["Juan", "Gig0/1", "132.19.0.1/16", "PC1 132.19.0.2"],
       ["Juan", "Serial0/0/0", "20.0.0.1/8", "DCE, clock rate 64000"],
       ["Rangel", "Gig0/0", "132.20.0.1/16", "PC2 132.20.0.2"],
       ["Rangel", "Gig0/1", "132.21.0.1/16", "PC3 132.21.0.2"],
       ["Rangel", "Serial0/0/0", "20.0.0.2/8", "DTE"]],
      "Direcciones del montaje de Juan.", [3, 3, 4, 5]),
    IMGJ("00-topologia-juan.jpg", "Topología de Juan: routers Juan y Rangel.", 14),
    IMGJ("01-rangel-show-ip-route-sin-rutas.jpg", "Rangel sin rutas: solo C y L.", 11),
    IMGJ("02-pc2-ping-sin-rutas.jpg", "PC2 sin rutas: responde 132.21.0.2 y falla 132.18.0.2 (unreachable desde 132.20.0.1).", 11),
    IMGJ("04-juan-rutas-guardado-OK.jpg", "Juan: rutas hacia 132.20 y 132.21 por Serial0/0/0, guardado [OK].", 11),
    IMGJ("03-rangel-rutas-guardado-OK.jpg", "Rangel: rutas hacia 132.18 y 132.19 por Serial0/0/0, guardado [OK].", 11),
    IMGJ("05-pc0-ping-132.20.0.2-y-tracert.jpg", "PC0: ping a 132.20.0.2 (TTL 126) y tracert 132.21.0.2: 132.18.0.1, 20.0.0.2, 132.21.0.2.", 10),
    IMGJ("06-pc0-ping-132.19-y-132.21.jpg", "PC0: ping a 132.19.0.2 (TTL 127) y 132.21.0.2 (TTL 126).", 10),
]
multi = [
    P("Dos instancias de Packet Tracer en el mismo PC: una escucha (Extensions > Multiuser > Listen, puerto 38002) y la otra se conecta por 127.0.0.1 con una nube Remote Network. "
      "El enlace va por Serial0/0/1 de cada Router1 (Aguirre DTE y Rangel DCE), red 30.0.0.0/8 (Rangel .1, Aguirre .2). Cada router lleva rutas hacia las cuatro redes del otro montaje."),
    T([["Router", "Rutas hacia", "Salida"],
       ["Camilo y Aguirre", "132.18 a 132.21.0.0/16", "Serial0/0/0 y Serial0/0/1"],
       ["Juan y Rangel", "72 a 75.0.0.0/8", "Serial0/0/0 y Serial0/0/1"]],
      "Rutas estáticas de la unión (Router0 por Serial0/0/0, Router1 por Serial0/0/1).", [4, 6, 5]),
    IMGU("01-camilo-topologia-con-nube-remota.jpg", "Camilo: nube Peer0 conectada al Serial0/0/1 de Aguirre.", 14),
    IMGU("02-juan-topologia-con-nube-remota.jpg", "Juan: nube Peer0 conectada al Serial0/0/1 de Rangel.", 14),
    IMGU("08-rangel-serial0-0-1-config-y-rutas.jpg", "Rangel: configuración de Serial0/0/1 y rutas.", 11),
    IMGU("09-camilo-rutas-hacia-132-guardado-OK.jpg", "Camilo: rutas hacia 132.x guardadas [OK].", 11),
    IMGU("03-aguirre-show-ip-route-con-enlace-multiusuario.jpg", "Aguirre: red 30.0.0.0/8 y rutas S hacia 132.18 a 132.21.", 11),
    IMGU("04-rangel-show-ip-route-con-enlace-multiusuario.jpg", "Rangel: red 30.0.0.0/8 y rutas S hacia 72 a 75.", 11),
    P("Verificación: TTL 124 = cuatro routers. El tracert de PC0 de Camilo a 132.21.0.2 pasa por 72.0.0.1, 20.0.0.2, 30.0.0.1 y 132.21.0.2, es decir, por los dos Router1."),
    IMGU("05-camilo-pc0-ping-132.18.0.2-y-tracert-132.21.0.2.jpg", "PC0 de Camilo: ping a 132.18.0.2 (TTL 124) y tracert a 132.21.0.2.", 10),
    IMGU("06-camilo-pc0-ping-132.20-y-132.21.jpg", "PC0 de Camilo: ping a 132.20.0.2 y 132.21.0.2 (TTL 125).", 10),
    IMGU("07-juan-pc0-ping-72.0.0.2-y-tracert-75.0.0.2.jpg", "PC0 de Juan: ping a 72.0.0.2 (TTL 124) y tracert a 75.0.0.2.", 10),
    P("Con dos PC físicos se cambia localhost por la IP del PC servidor. Archivos: camilo-lab06-multiusuario.pkt y juan-lab06-multiusuario.pkt."),
]

# ------------------------------------------------------------------ III
nginx_conf = """worker_processes 1;
events { worker_connections 256; }
http {
    include       mime.types;
    server {
        listen 80;
        server_name nginx.camilo.org.uk;
        root /srv/lab06/nginx;
    }
}"""
apache = [
    P("Se creó una máquina FreeBSD 14.5 (imagen oficial verificada con SHA-256), IP 192.168.82.14. Apache: pkg install apache24, sysrc apache24_enable=YES, service apache24 start."),
    C("D:\\LAB 6\\camilo\\evidencias\\freebsd-apache-pruebas.txt", leer(CEV + "freebsd-apache-pruebas.txt", 10)),
]
nginx = [
    P("Compilado desde el código fuente (1.26.3): ./configure --prefix=/usr/local/nginx, make, make install. Arranque con el guion /etc/rc.d/rc.nginx invocado desde rc.local."),
    C("/usr/local/nginx/conf/nginx.conf", nginx_conf),
    C("D:\\LAB 6\\camilo\\evidencias\\slackware-nginx-instalacion.txt", leer(CEV + "slackware-nginx-instalacion.txt", 14)),
]
iis = [
    P("Rol Servidor Web por PowerShell, W3SVC en inicio automático y regla de firewall para el puerto 80. Respuesta HTTP 200. "
      "Incidente: el segundo adaptador estaba deshabilitado (código 22); se habilitó con Disable-PnpDevice y Enable-PnpDevice y se fijó 192.168.82.13/24."),
    C("D:\\LAB 6\\webservers\\iis-windows\\instalar.ps1 (extracto)",
      "Install-WindowsFeature -Name Web-Server -IncludeManagementTools\nSet-Service -Name W3SVC -StartupType Automatic\nStart-Service -Name W3SVC\n"
      "New-NetFirewallRule -DisplayName 'Lab06 HTTP 80' -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow"),
]
arranque = [
    P("Se reinició cada máquina y las páginas respondieron HTTP 200 sin intervención."),
    C("D:\\LAB 6\\evidencias\\reinicio-arranque-automatico.txt", leer(EV + "reinicio-arranque-automatico.txt", 10)),
]
dns = [
    P("BIND del Laboratorio 3. Se agregaron registros A a la zona camilo.org.uk y se subió el serial."),
    C("Registros en /etc/DNS/camilo.org.uk.hosts",
      "apache.camilo.org.uk. IN A 192.168.82.14\nnginx.camilo.org.uk.  IN A 192.168.82.10\niis.camilo.org.uk.    IN A 192.168.82.13"),
    C("D:\\LAB 6\\evidencias\\dns-pruebas.txt", leer(EV + "dns-pruebas.txt", 12)),
]
otro_pc = [
    P("En casa, desde la máquina FreeBSD (red interna) usando los dos BIND. En la universidad se repite desde otro PC físico contra 10.2.78.x."),
    C("D:\\LAB 6\\evidencias\\acceso-otro-equipo-por-nombre.txt", leer(EV + "acceso-otro-equipo-por-nombre.txt", 24)),
]

# ------------------------------------------------------------------ IV
vhosts = """<VirtualHost *:80>
    ServerName network.juan.com.co
    DocumentRoot /var/apache2/2.4/htdocs/network
</VirtualHost>
<VirtualHost *:80>
    ServerName security.camilo.org.jp
    DocumentRoot /var/apache2/2.4/htdocs/security
</VirtualHost>"""
hosting = [
    P("Un solo Apache en Solaris sirve dos sitios según el nombre pedido (cabecera Host): network.juan.com.co y security.camilo.org.jp. "
      "Zonas: juan.com.co (primaria en Solaris, secundaria en Slackware) y camilo.org.jp (primaria en Slackware, secundaria en Solaris); ambos nombres apuntan a 192.168.82.11."),
    C("/etc/apache2/2.4/extra/lab06-vhosts.conf (extracto)", vhosts),
    C("Zona juan.com.co (D:\\LAB 6\\dns\\salida\\casa\\juan.com.co.hosts)", leer(RAIZ + "dns/salida/casa/juan.com.co.hosts", 14)),
    P("Incidente: la zona secundaria tardaba en cargar porque en masters estaba primero la IP de la universidad; ahora cada modo lleva solo su IP. "
      "Tercer sitio (systems.<estudiante 03>.com.cl): no aplica, el grupo es de dos estudiantes."),
]

# ------------------------------------------------------------------ V
app = [
    P("PHP 8.3 con mod_php (MPM prefork) en Apache de FreeBSD. La calculadora pide nombre y tres notas, calcula 30 %, 30 % y 40 %, aprueba con 3,0 o más y guarda en PostgreSQL "
      "(base notas_lab06, tabla notas, CHECK de 0 a 5) del Laboratorio 5. PDO con sentencias preparadas contra inyección SQL y salida escapada contra XSS."),
    C("D:\\LAB 6\\webapp\\schema.sql", leer(RAIZ + "webapp/schema.sql", 16, 4)),
    P("Pruebas: 4,0 / 3 / 5 dan 4,10 y aprueba; 2,5 en las tres da 2,50 y no aprueba; 7 y \"abc\" se rechazan; una etiqueta script se muestra escapada. Acceso: http://apache.camilo.org.uk/notas/."),
    C("D:\\LAB 6\\camilo\\evidencias\\webapp-postgres-lab5-prueba.txt", leer(CEV + "webapp-postgres-lab5-prueba.txt", 14)),
]

# ------------------------------------------------------------------ VI
pend = [
    P("Falta lo que depende de la universidad: (1) pasar las máquinas a adaptador puente con IP 10.2.78.x y regenerar el DNS; (2) probar el acceso desde un PC físico (punto 2.1.f); "
      "(3) repetir el multiusuario con dos PC; (4) mostrar el laboratorio al profesor."),
    P("Supuestos: Student 01 = Juan y 02 = Camilo; 10.2.78.76 (Windows) y 10.2.78.78 (FreeBSD) por confirmar. El montaje de Juan, IIS y network.juan.com.co los preparó Camilo con ayuda de Claude."),
]
concl = [
    P("Un servicio web funciona cuando coinciden varias capas: el servidor (Apache, Nginx, IIS), el nombre (DNS con zonas primarias y secundarias), la red (IP, puertos) y el arranque automático. "
      "Los fallos aparecieron en las uniones entre capas: un adaptador deshabilitado, una IP inalcanzable en la lista de masters del DNS."),
]
refs = [
    P("[1] Apache HTTP Server Project, Virtual Host documentation, https://httpd.apache.org/docs/2.4/vhosts/"),
    P("[2] nginx.org, nginx documentation, https://nginx.org/en/docs/"),
    P("[3] Microsoft, Install-WindowsFeature y servidor web (IIS), https://learn.microsoft.com/windows-server/"),
    P("[4] ISC, BIND 9 Administrator Reference Manual, https://bind9.readthedocs.io/"),
    P("[5] The PHP Group, PHP Manual: PDO, https://www.php.net/manual/es/book.pdo.php"),
    P("[6] The PostgreSQL Global Development Group, PostgreSQL Documentation, https://www.postgresql.org/docs/"),
    P("[7] Cisco, Packet Tracer y rutas estáticas en IOS, https://www.netacad.com/"),
]

secciones = [
    {"titulo": "Entorno de trabajo", "bloques": entorno, "subsecciones": []},
    {"titulo": "Router Simulation", "bloques": routers, "subsecciones": [
        {"titulo": "Montaje de Camilo", "bloques": camilo},
        {"titulo": "Configuración manual de un router por consola", "bloques": manual},
        {"titulo": "Montaje de Juan", "bloques": juan},
        {"titulo": "Unión multiusuario a través de Router1", "bloques": multi}]},
    {"titulo": "Web Service Installation", "bloques": [], "subsecciones": [
        {"titulo": "Apache en FreeBSD (punto a)", "bloques": apache},
        {"titulo": "Nginx en Slackware (punto b)", "bloques": nginx},
        {"titulo": "IIS en Windows Server (punto c)", "bloques": iis},
        {"titulo": "Arranque automático (puntos d y e)", "bloques": arranque},
        {"titulo": "DNS para acceder por nombre (punto g)", "bloques": dns},
        {"titulo": "Acceso desde otro computador (punto f)", "bloques": otro_pc}]},
    {"titulo": "Hosting Service Configuration", "bloques": hosting, "subsecciones": []},
    {"titulo": "On-Premise Web Application", "bloques": app, "subsecciones": []},
    {"titulo": "Conclusiones", "bloques": concl, "subsecciones": []},
    {"titulo": "Referencias bibliográficas", "bloques": refs, "subsecciones": []},
]

cfg = {
    "encabezado": "LABORATORIO 6",
    "titulo": "Protocolos de capa de aplicación, plataforma base y capa de red",
    "autores": ["Camilo Aguirre Rico", "Juan David Rangel"],
    "profesor": "John Alexander Pachón Pinzón",
    "materia": "Arquitectura y Servicios de Red - AYSR",
    "ciudad_fecha": "Bogotá, D.C., octubre de 2026",
    "secciones": secciones,
}
json.dump(cfg, open(RAIZ + "informe/fuente/config.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("ok", sum(len(s["bloques"]) + sum(len(x["bloques"]) for x in s["subsecciones"]) for s in secciones), "bloques")
