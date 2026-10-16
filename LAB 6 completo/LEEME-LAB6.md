# Lab 6 de AYSR: plan de ejecución

Guía oficial: `D:\LAB 6\0-GUIA-OFICIAL\Laboratory_No.06.pdf`.
Todo el laboratorio vive en `D:\LAB 6\` (VM, proyecto, evidencia, informe). Mapa de carpetas: `D:\LAB 6\00-LEEME-PRIMERO.md`.
Control de tareas: `D:\LAB 6\odd\tasks\lab06-completo.md`.

## Qué pide cada punto y dónde está lo preparado

| Punto de la guía | Qué es | Carpeta | Estado |
|---|---|---|---|
| 1 Router Simulation | Packet Tracer: 2 routers, 4 redes, rutas estáticas | `routers\` | HECHO y probado en Packet Tracer (15-oct): montaje de Camilo, montaje de Juan, configuración manual de un router y unión multiusuario por Router1; falta repetir la unión con dos PC en la U |
| 2.1.a Apache en FreeBSD | VM FreeBSD real (decisión del usuario) | `webservers\freebsd-apache\` | HECHO y verificado: VM `freebsd-14.5-lab06` (imagen oficial 14.5 con checksum comprobado), Apache, página de prueba, arranque automático tras reiniciar y acceso desde el PC anfitrión |
| 2.1.b Nginx en Slackware | Compilar Nginx y dejarlo arrancando solo | `webservers\nginx-slackware\` | HECHO y probado (compilado, arranque automatico tras reiniciar, acceso por nombre) |
| 2.1.c IIS en Windows Server | Servidor web de Windows | `webservers\iis-windows\` | HECHO y probado (IIS, W3SVC automatico, acceso por nombre) |
| 2.1.g y 2.2.b DNS | Zonas nuevas y nombres de los servidores | `dns\` | HECHO: zonas aplicadas en Slackware y Solaris, transferencias y nombres verificados |
| 2.2 Hosting en Solaris | Hosts virtuales de Apache | `hosting\solaris\` | HECHO: dos hosts virtuales verificados por nombre (falta decidir el tercero) |
| 3 Aplicación web | Calculadora de notas en PHP con PostgreSQL | `webapp\` | Probada en FreeBSD (PHP 8.3 + PostgreSQL de prueba); HECHO: guarda en notas_lab06 del PostgreSQL del Lab 5 (Slackware) |

## Direcciones

| Máquina | Red de la universidad (puente) | Red interna `lab-uni` | Puertos redirigidos en el PC (modo casa) |
|---|---|---|---|
| Slackware | 10.2.78.74 | 192.168.82.10 | SSH 2222, HTTP 8082, DNS 5301 |
| Solaris | 10.2.78.75 | 192.168.82.11 | SSH 2223, HTTP 8084, DNS 5302 |
| Windows Server GUI | 10.2.78.76 (supuesto: nunca se asignó) | 192.168.82.13 | RDP 3389, SSH 2225, HTTP 8083 |
| FreeBSD (nueva) | 10.2.78.78 (supuesto) | 192.168.82.14 (supuesto) | SSH 2226, HTTP 8081 |

Las IP de la red de la universidad vienen del Lab 3 (`10.2.0.0/16`, gateway `10.2.65.1`, sin DHCP). Son supuestos hasta confirmarlos con la sala.
Para probar "desde otro computador" (2.1.f): en casa, el PC anfitrión hace de otro computador y entra por los puertos redirigidos; en la universidad, se prueba desde otro PC contra las IP `10.2.78.x`.

## Nombres (DNS)

| Nombre | Apunta a | Para qué |
|---|---|---|
| `apache.camilo.org.uk` | FreeBSD | Punto 2.1.a |
| `nginx.camilo.org.uk` | Slackware | Punto 2.1.b |
| `iis.camilo.org.uk` | Windows Server | Punto 2.1.c |
| `network.juan.com.co` | Solaris | Punto 2.2 (zona primaria en Solaris) |
| `security.camilo.org.jp` | Solaris | Punto 2.2 (zona primaria en Slackware) |

## Decisiones y supuestos (cerrados el 15-oct)
1. **Tercer sitio del hosting.** La guía asigna `systems.<estudiante 03>.com.cl` a un tercer integrante que este grupo de dos no tiene: no aplica. Si el profesor lo pide, se agrega un VirtualHost y una zona `.com.cl`.
2. **Quién es Student 01.** Se supuso Juan (como en el Lab 3). Si es Camilo, se intercambian los bloques de redes y los nombres.
3. **Claves de los routers.** `ClaveE`, `ClaveC` y `ClaveT`, literalmente como dice la guía.
4. **Base de datos de la calculadora.** `notas_lab06` en el PostgreSQL del Lab 5 (Slackware).
5. **Multiusuario.** Dos instancias de Packet Tracer en el mismo PC (127.0.0.1, puerto 38002), enlace serial entre los Router1 y red 30.0.0.0/8.
6. **El montaje de Juan, IIS y el sitio de Juan** los dejó hechos Camilo con ayuda de Claude porque Juan no estaba disponible.

## Orden de ejecución sobre las VM (cuando estén disponibles)
1. FreeBSD: crear la VM, ejecutar `instalar.sh`, probar la página.
2. Slackware: `instalar.sh` de Nginx; Windows: `instalar.ps1`; probar las páginas.
3. DNS: aplicar `dns\salida\<modo>\` en Slackware y Solaris (subir el serial), `rndc reload` y comprobar con `nslookup`.
4. Solaris: `instalar.sh` del hosting; probar las dos URLs por nombre.
5. Calculadora: crear la base y la tabla, copiar `webapp\`, probarla y comprobar el registro en PostgreSQL.
6. Evidencia (capturas y salidas) en `evidencias\`, informe en Word y guía "QUE HACES EN LA U".
