# Juan: tu parte del Laboratorio 6

Esta carpeta (`D:\LAB 6\juan\`) es de Juan. La guía no reparte el trabajo: el reparto es una propuesta y se ajusta si el profesor dice otra cosa.

**Importante:** como no estabas disponible el 15 de octubre de 2026, **tu montaje de Packet Tracer lo armó Camilo con ayuda de Claude**, y también quedaron hechos IIS y el sitio `network.juan.com.co`. Todo funciona y tiene evidencia, pero **tú debes revisarlo y poder explicarlo** porque el profesor puede preguntártelo. Si quieres hacerlo tú mismo de cero, abajo está el paso a paso.

## Qué hay hecho a tu nombre

| Punto de la guía | Entregable | Estado | Dónde está |
|---|---|---|---|
| 1. Routers | Montaje de Juan en Packet Tracer (routers **Juan** y **Rangel**, redes 132.18 a 132.21 con máscara /16) | **Hecho y probado** | `juan\packet-tracer\juan-lab06.pkt` |
| 1. Routers | Prueba sin rutas, con rutas, `tracert`, configuración guardada | **Hecho**, con 7 capturas | `juan\packet-tracer\evidencias\` |
| 1. Routers | Unión multiusuario con el montaje de Camilo por Router1 | **Hecho** (las dos instancias en el mismo PC) | `juan\packet-tracer\juan-lab06-multiusuario.pkt` y `evidencias\multiusuario\` |
| 2.1.c | IIS en Windows Server | **Hecho** | `webservers\iis-windows\instalar.ps1` y `evidencias\reinicio-arranque-automatico.txt` |
| 2.2 | Zona `juan.com.co` en Solaris y sitio `network.juan.com.co` | **Hecho** | `dns\salida\casa\juan.com.co.hosts`, `hosting\solaris\instalar.sh`, `evidencias\acceso-otro-equipo-por-nombre.txt` |
| Informe | Sección "Montaje de Juan" | **Completa** | `informe\Informe-Laboratorio-06-AYSR.pdf` |

## Lo que debes hacer tú

1. Abrir `juan\packet-tracer\juan-lab06.pkt` y repasar cada router con `show running-config` y `show ip route`.
2. **Repetir a mano** la configuración de un router (por ejemplo Rangel): `erase startup-config`, `reload` y escribir los comandos. Los comandos están en `juan\packet-tracer\juan-Router0-Juan.txt` y `juan-Router1-Rangel.txt`.
3. Leer la sección de unión multiusuario del informe y probarla con Camilo, en dos PC distintos.
4. Estudiar IIS y el host virtual de Solaris.

## Lo que debes saber explicar

- **Ruta estática:** instrucción manual "para llegar a la red X, sal por esta interfaz"; sin ella el router descarta el paquete.
- **`tracert` y TTL:** muestra cada router del camino; el TTL baja 1 por router (124 = cuatro routers).
- **Multiusuario:** dos Packet Tracer unidos por una nube *Remote Network*; uno escucha (puerto 38002 en la prueba) y el otro se conecta. El enlace usa Serial0/0/1 de cada Router1 y la red 30.0.0.0/8.
- **IIS:** rol Servidor Web, instalado con `Install-WindowsFeature`; `W3SVC` en inicio automático y regla de firewall del puerto 80.
- **Host virtual:** un solo Apache en Solaris que sirve `network.juan.com.co` y `security.camilo.org.jp` según el nombre que pide el navegador.
- **DNS:** `juan.com.co` es primaria en Solaris y secundaria en Slackware.

## Juntos (con Camilo)

Pruebas en la universidad en modo puente y la demostración al profesor.
