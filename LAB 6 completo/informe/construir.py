"""Construye el informe del Lab 6 y la guia 'QUE HACES EN LA U (Lab 6)' en Word, con la evidencia real de D:\\LAB 6\\evidencias."""
import os

from docx import Document
from docx.shared import Pt

RAIZ = r"D:\LAB 6"
EV = os.path.join(RAIZ, "evidencias")
SAL = os.path.join(RAIZ, "informe")


def leer(ruta, max_lineas=60):
    t = open(ruta, encoding="utf-8", errors="replace").read().strip().splitlines()
    if len(t) > max_lineas:
        t = t[:max_lineas // 2] + ["[... recortado: el archivo completo esta en " + ruta + " ...]"] + t[-max_lineas // 2:]
    return "\n".join(t)


def nuevo():
    d = Document()
    d.styles["Normal"].font.name = "Calibri"
    d.styles["Normal"].font.size = Pt(11)
    return d


def codigo(d, texto):
    r = d.add_paragraph().add_run(texto)
    r.font.name = "Consolas"
    r.font.size = Pt(8.5)


def evid(d, titulo, archivo, max_lineas=60):
    d.add_paragraph(titulo).runs[0].bold = True
    codigo(d, leer(archivo, max_lineas))
    d.add_paragraph("Archivo de evidencia: " + archivo)


def tabla(d, cabecera, filas):
    t = d.add_table(rows=1, cols=len(cabecera))
    t.style = "Light Grid Accent 1"
    for i, h in enumerate(cabecera):
        t.rows[0].cells[i].text = h
    for fila in filas:
        c = t.add_row().cells
        for i, v in enumerate(fila):
            c[i].text = v


def informe():
    d = nuevo()
    d.add_heading("Laboratorio No. 06 - Protocolos de capa de aplicacion, plataforma base y capa de red", 0)
    d.add_paragraph("Asignatura: Administracion y Seguridad en Redes (AYSR). Profesor: John Alexander Pachon Pinzon.\n"
                    "Integrantes: Camilo Aguirre Rico y Juan David Rangel (grupo de 2).\nFecha de ejecucion: 3 de octubre de 2026.")

    d.add_heading("1. Objetivo y entorno", 1)
    d.add_paragraph("Instalar y configurar el software base de servidores web. Se uso VirtualBox 7.2 con las maquinas del Laboratorio 5 "
                    "(Slackware 15.0, Solaris 11.4 y Windows Server GUI, con el sufijo \" - UNI\") mas una maquina FreeBSD 14.5 nueva. "
                    "En casa las maquinas usan NAT con redirecciones a 127.0.0.1 y una red interna \"lab-uni\" (192.168.82.0/24); en la universidad se usa "
                    "puente con las direcciones 10.2.78.x.")
    tabla(d, ["Maquina", "Red interna", "Servicio", "Puerto en el PC"],
          [("FreeBSD 14.5", "192.168.82.14", "Apache 2.4 + PHP 8.3", "HTTP 8081, SSH 2226"),
           ("Slackware 15.0", "192.168.82.10", "Nginx 1.26.3, BIND, PostgreSQL 14", "HTTP 8082, DNS 5301, SSH 2222"),
           ("Windows Server GUI", "192.168.82.13", "IIS 10", "HTTP 8083, SSH 2225"),
           ("Solaris 11.4", "192.168.82.11", "Apache 2.4 (hosts virtuales), BIND", "HTTP 8084, DNS 5302, SSH 2223")])

    d.add_heading("2. Simulacion de routers (punto 1)", 1)
    d.add_paragraph("Se preparo, para cada estudiante, el plan de direccionamiento y los comandos IOS de los dos routers (Router0 = nombre y Router1 = apellido, "
                    "mensaje del dia, sincronizacion de pantalla, bloqueo de busqueda DNS externa, descripcion de interfaces, claves de modo privilegiado, consola y terminal remota, "
                    "enlace serial 20.0.0.0/8 y rutas estaticas). Un verificador en Python calcula el alcance entre los PC: sin rutas solo se comunican los PC que comparten router "
                    "(2 de 6 pares) y con rutas estaticas se comunican los 6 de 6, en ambas configuraciones.")
    evid(d, "Resultado del verificador (simulacion, no es Packet Tracer):", os.path.join(RAIZ, "routers", "salida", "verificacion.txt"), 46)
    p = d.add_paragraph()
    p.add_run("Estado: PENDIENTE de la prueba real en Packet Tracer (ping, tracert y la opcion multiusuario). ").bold = True
    p.add_run("Los comandos estan en D:\\LAB 6\\camilo\\packet-tracer\\ y D:\\LAB 6\\juan\\packet-tracer\\, y la guia en D:\\LAB 6\\routers\\LEEME-ROUTERS.md. Las claves se usaron literalmente como ClaveE, ClaveC y ClaveT.")

    d.add_heading("3. Servidores web (punto 2.1)", 1)
    d.add_heading("a) Apache en FreeBSD", 2)
    d.add_paragraph("VM real FreeBSD 14.5-RELEASE (imagen oficial, suma SHA-256 comprobada). Apache 2.4 instalado con pkg, pagina de prueba, servicio habilitado con sysrc y comprobado tras reiniciar.")
    evid(d, "Pruebas:", os.path.join(EV, "freebsd-apache-pruebas.txt"), 20)
    d.add_heading("b) Nginx en Slackware", 2)
    d.add_paragraph("Nginx 1.26.3 compilado desde el codigo fuente, pagina de prueba en /srv/lab06/nginx y arranque automatico con /etc/rc.d/rc.nginx llamado desde rc.local.")
    evid(d, "Instalacion y prueba desde el PC:", os.path.join(EV, "slackware-nginx-instalacion.txt"), 30)
    d.add_heading("c) IIS en Windows Server", 2)
    d.add_paragraph("Rol Web-Server instalado con Install-WindowsFeature, pagina en C:\\inetpub\\wwwroot, servicio W3SVC en inicio automatico y regla de firewall del puerto 80. "
                    "Resultado observado: Success, W3SVC Running/Automatic y HTTP 200. Ademas se activo el adaptador de red interna (estaba deshabilitado) con la IP 192.168.82.13/24.")
    d.add_heading("d), e) Pagina de prueba y arranque automatico", 2)
    evid(d, "Reinicio de Slackware y Windows sin tocar nada despues de arrancar:", os.path.join(EV, "reinicio-arranque-automatico.txt"), 20)
    d.add_heading("f) Acceso desde otro computador, y g) DNS por nombre", 2)
    d.add_paragraph("Los nombres se agregaron al DNS del Laboratorio 3: apache, nginx e iis bajo camilo.org.uk en el BIND de Slackware (se subio el serial). "
                    "La maquina FreeBSD actua como otro computador de la red interna, usa los dos BIND como resolutores y abre cada pagina por nombre.")
    evid(d, "Resolucion de nombres contra los dos servidores DNS (puertos 5301 y 5302 del PC):", os.path.join(EV, "dns-pruebas.txt"), 20)
    evid(d, "Acceso por nombre desde otra maquina:", os.path.join(EV, "acceso-otro-equipo-por-nombre.txt"), 40)

    d.add_heading("4. Hosting con hosts virtuales en Solaris (punto 2)", 1)
    d.add_paragraph("Apache 2.4 de Solaris con dos VirtualHost por nombre en /etc/apache2/2.4/extra/lab06-vhosts.conf (la carpeta extra no existia y se creo). "
                    "Servicio svc:/network/http:apache24 habilitado (online). Zonas: juan.com.co es primaria en Solaris y esclava en Slackware; camilo.org.jp es primaria en Slackware y esclava en Solaris. "
                    "network.juan.com.co y security.camilo.org.jp apuntan a 192.168.82.11 y cada una muestra su propia pagina (ver la prueba por nombre de la seccion anterior). "
                    "Incidente: la zona esclava tardaba porque una IP inalcanzable de la universidad estaba primero en masters; el generador ahora usa solo la IP del modo.")
    p = d.add_paragraph()
    p.add_run("Pendiente de decision: ").bold = True
    p.add_run("el enunciado lista tres URLs (systems.<nombre 03>.com.cl) pero un grupo de 2 no tiene tercer nombre; solo estan configuradas dos.")

    d.add_heading("5. Aplicacion web local (punto 3)", 1)
    d.add_paragraph("Calculadora de notas en PHP 8.3 sobre el Apache de FreeBSD (mod_php con MPM prefork). Pide nombre y tres notas, calcula 30 %, 30 % y 40 %, "
                    "valida el rango 0 a 5, escapa la salida y guarda cada registro con sentencias preparadas PDO en la base notas_lab06 del PostgreSQL 14 del Laboratorio 5 (Slackware), con el usuario webnotas.")
    evid(d, "Prueba de extremo a extremo (formulario HTTP y lectura directa en PostgreSQL):", os.path.join(EV, "webapp-postgres-lab5-prueba.txt"), 20)
    evid(d, "Prueba de la logica de calculo (CLI) y de seguridad:", os.path.join(EV, "freebsd-webapp-prueba.txt"), 40)

    d.add_heading("6. Pendientes y supuestos", 1)
    for s in ["Prueba real en Packet Tracer (ping, tracert, multiusuario): la hace el estudiante en la universidad.",
              "Acceso desde otro PC fisico: en casa se probo desde la maquina FreeBSD de la red interna; en la universidad se prueba contra las IP 10.2.78.x.",
              "Tercer sitio del hosting (systems.<nombre>.com.cl): sin definir.",
              "Se asumio Estudiante 01 = Juan y Estudiante 02 = Camilo (como en el Laboratorio 3).",
              "Las IP 10.2.78.76 (Windows) y 10.2.78.78 (FreeBSD) son supuestos hasta confirmarlas con la sala."]:
        d.add_paragraph(s, style="List Bullet")
    d.save(os.path.join(SAL, "Laboratorio06-AYSR.docx"))


def guia():
    d = nuevo()
    d.add_heading("QUE HACES EN LA U (Laboratorio 6)", 0)
    d.add_paragraph("Todo esta en D:\\LAB 6\\. Las 4 maquinas (Slackware, Solaris y Windows con sufijo \" - UNI\", y FreeBSD) estan en "
                    "D:\\LAB 6\\1-MAQUINAS-VIRTUALES\\, cada una en su carpeta con su archivo .vbox.")
    d.add_heading("1. Antes de empezar", 1)
    for s in ["Importa las maquinas como en D:\\LAB 5\\GUIA-IMPORTAR-VMS - UNI.pdf, pero tomando los archivos .vbox de D:\\LAB 6\\1-MAQUINAS-VIRTUALES\\ (VirtualBox > Maquina > Agregar), incluida freebsd-14.5-lab06.vbox.",
              "Pon las 4 maquinas en Adaptador puente (adaptador cableado del PC) e inicia: Slackware, Solaris, Windows GUI y FreeBSD.",
              "Direcciones de la universidad: Slackware 10.2.78.74, Solaris 10.2.78.75, Windows 10.2.78.76 (supuesto), FreeBSD 10.2.78.78 (supuesto); mascara 255.255.0.0, gateway 10.2.65.1.",
              "Las VM hoy tienen IP 192.168.82.x (red interna). Para la U hay que fijar las 10.2.78.x en cada VM, regenerar el DNS con "
              "python D:\\LAB 6\\dns\\generar_zonas.py uni y aplicar D:\\LAB 6\\dns\\salida\\uni\\ (subiendo el serial) en Slackware (/etc/DNS) y Solaris (/etc/inet/DNS)."]:
        d.add_paragraph(s, style="List Number")
    d.add_heading("2. Que mostrarle al profesor", 1)
    tabla(d, ["Punto", "Que abrir", "Que debe verse"],
          [("1 Routers", "Packet Tracer con los comandos de D:\\LAB 6\\camilo\\packet-tracer\\ y D:\\LAB 6\\juan\\packet-tracer\\", "Abrir camilo-lab06-config-manual.pkt y juan-lab06.pkt: ping sin rutas (2 de 6) y con rutas (6 de 6); tracert. Union multiusuario: D:\\LAB 6\\evidencias\\multiusuario\\ (ping y tracert entre los dos montajes por los dos Router1)"),
           ("2.1.a Apache", "http://apache.camilo.org.uk/", "Pagina Apache en FreeBSD"),
           ("2.1.b Nginx", "http://nginx.camilo.org.uk/", "Pagina Nginx en Slackware"),
           ("2.1.c IIS", "http://iis.camilo.org.uk/", "Pagina IIS en Windows Server"),
           ("2.2 Hosting", "http://network.juan.com.co/ y http://security.camilo.org.jp/", "Dos paginas distintas en el mismo Solaris"),
           ("3 Calculadora", "http://apache.camilo.org.uk/notas/", "Nota final calculada y registro guardado en PostgreSQL (SELECT en notas_lab06)")])
    d.add_heading("3. Si algo falla", 1)
    for s in ["Una pagina no abre: dentro de la VM revisa el servicio (Slackware: /etc/rc.d/rc.nginx status; FreeBSD: service apache24 status; Windows: Get-Service W3SVC; Solaris: svcs apache24).",
              "El nombre no resuelve: comprueba que el DNS del PC de prueba sea la IP de Slackware o Solaris, y el serial de las zonas. Si network.juan.com.co falla justo despues de encender las maquinas, Slackware arranco antes que Solaris y BIND dejo a Solaris en cache como inalcanzable: con las dos encendidas, ejecuta /etc/rc.d/rc.bind restart en Slackware y luego rndc retransfer juan.com.co. Pasa igual con camilo.org.jp en Solaris (svcadm restart dns/server y rndc retransfer camilo.org.jp). Conviene encender primero Slackware y Solaris y esperar unos minutos antes de probar.",
              "La calculadora no guarda: revisa D:\\LAB 6\\CREDENCIALES-LAB06.md y la conexion a Slackware por el puerto 5432.",
              "Multiusuario en la U: con dos PC, abrir Extensions > Multiuser > Listen en uno (puerto 38002 y contrasena) y en el otro conectar la nube Remote Network con la IP de ese PC en vez de localhost. Los archivos camilo-lab06-multiusuario.pkt y juan-lab06-multiusuario.pkt no traen el enlace activo: se vuelve a establecer.", "Tercer sitio del 2.2 (systems.<nombre3>.com.cl): corresponde a un Estudiante 03 que este grupo de dos no tiene; si el profesor lo pide, se agrega un VirtualHost y una zona .com.cl."]:
        d.add_paragraph(s, style="List Bullet")
    d.save(os.path.join(RAIZ, "QUE HACES EN LA U (Lab 6).docx"))


guia()
print("ok")
