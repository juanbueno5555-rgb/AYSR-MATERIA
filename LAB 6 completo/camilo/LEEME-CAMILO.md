# Camilo: tu parte del Laboratorio 6

Esta carpeta (`D:\LAB 6\camilo\`) es de Camilo. La guía no reparte el trabajo: el reparto es una propuesta y se ajusta si el profesor dice otra cosa.

## Qué entregas

| Punto de la guía | Entregable | Estado | Dónde está |
|---|---|---|---|
| 1. Routers | Montaje de Camilo en Packet Tracer (routers Camilo y Aguirre, redes 72 a 75) | **Hecho y probado** | `camilo\packet-tracer\camilo-lab06 xd.pkt` |
| 1. Routers | Ping sin y con rutas, `tracert`, configuración guardada | **Hecho** | `camilo\packet-tracer\evidencias\` (capturas `00` a `14`) |
| 1. Routers | Configurar un router **a mano** por consola | **Hecho el 15-oct en Aguirre** (lo escribió Claude con computer use, comando por comando, desde PC2) | `camilo\packet-tracer\camilo-lab06-config-manual.pkt` y capturas `07` a `14` |
| 1. Routers | Unión multiusuario con el montaje de Juan por Router1 | **Hecho** (las dos instancias en el mismo PC) | `camilo\packet-tracer\camilo-lab06-multiusuario.pkt` y `evidencias\multiusuario\` |
| 2.1.a | Apache en FreeBSD | **Hecho** | `camilo\evidencias\freebsd-apache-*.txt` |
| 2.1.b | Nginx en Slackware | **Hecho** | `camilo\evidencias\slackware-nginx-instalacion.txt` |
| 2.1.g | DNS `apache.` y `nginx.camilo.org.uk` | **Hecho** | `evidencias\dns-pruebas.txt` |
| 2.2 | Zona `camilo.org.jp` en Slackware y sitio `security.camilo.org.jp` | **Hecho** | `evidencias\acceso-otro-equipo-por-nombre.txt` |
| 3. Aplicación | Calculadora PHP guardando en PostgreSQL | **Hecho** | `camilo\evidencias\freebsd-webapp-prueba.txt` y `webapp-postgres-lab5-prueba.txt` |
| Informe | Informe completo en el formato de la Escuela | **Hecho** (30 páginas) | `informe\Informe-Laboratorio-06-AYSR.pdf` |

## Lo que te falta

1. **Repetir tú mismo** la configuración manual de un router (por ejemplo Camilo): abre `camilo-lab06-config-manual.pkt`, conéctate por *Desktop > Terminal*, `erase startup-config`, `reload` y escribe los comandos. La hizo Claude por ti, así que si el profesor te pide hacerlo en vivo, necesitas haberlo practicado.
2. En la universidad: pasar las máquinas a modo puente, probar desde otro PC físico y repetir la unión multiusuario con dos PC (cambiando `localhost` por la IP del servidor).
3. Mostrar todo al profesor.

## Lo que debes saber explicar

- **Ruta estática:** instrucción manual que dice "para llegar a la red X, sal por esta interfaz". Sin ella el router descarta el paquete.
- **`tracert` y TTL:** muestra cada router por el que pasa el paquete. El TTL baja 1 por router (127 = un router, 126 = dos, 124 = cuatro en la unión multiusuario).
- **`clock rate`:** marca el ritmo en el extremo DCE del enlace serial.
- **Multiusuario:** nube *Remote Network*, servidor que escucha y cliente que se conecta; enlace serial entre los Router1 (red 30.0.0.0/8).
- **Apache y Nginx:** para qué sirve cada uno, y por qué Nginx se compiló.
- **DNS:** zona primaria y secundaria, y para qué sirve el serial.
- **PHP y PDO:** sentencias preparadas contra la inyección SQL, y `htmlspecialchars` contra XSS.

## Juntos (con Juan)

Pruebas en la universidad en modo puente y la demostración al profesor.
