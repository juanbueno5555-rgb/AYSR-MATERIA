# Laboratorio 8 · AYSR (capa de enlace y capa de aplicación)

Camilo Aguirre Rico y Juan David Rangel · Escuela Colombiana de Ingeniería Julio Garavito.
Guía oficial: *Lab No.08 - Data Link Layer and Application Layer*.

## Qué hay en esta carpeta
| Carpeta | Contenido |
|---|---|
| `informe/` | **Informe-Lab8-Aguirre-Rangel.docx**: informe con la portada de la escuela (resultados, figuras y limitaciones) |
| `packet-tracer/` | Proyectos de Packet Tracer 9.0.1: puntos 1 y 2, 3 (red de 26 dispositivos), 4 (VLAN) y 5 (WiFi) |
| `guias/` | Word: **GUIA (Lab 8)**, **SUSTENTACION (Lab 8)** y **QUE HACES EN LA U (Lab 8)** |
| `scripts/` | `info_red.sh` / `info_red.ps1` (menú de comandos de red) y `puerto.sh` (puerto abierto SI/NO) |
| `switches/` | Configuración de switches y guía de Ethernet, Wireshark, spanning tree y VLAN |
| `wifi/` | Datos, resultados y preguntas de los puntos 5 a 8 |
| `webapp/` | Calculadora de notas PHP + PostgreSQL y pasos de despliegue en AWS |
| `snmp/` | Monitoreo SNMP: servidor Slackware, agentes de FreeBSD, Windows y NetBSD, y guía |
| `evidencias/` | Capturas de Packet Tracer, captura de Wireshark y salidas reales de las VM (2026-11-06) |

## Estado (qué está comprobado y qué no)
| Punto | Estado |
|---|---|
| Trama Ethernet con Wireshark (punto 1) | **Hecho**: captura real con tshark (`evidencias/captura-ping-trama.txt`) |
| Configuración del switch (punto 2) | **Hecho y verificado** en Packet Tracer: nombre, banner, claves |
| Red grande de 26 dispositivos (punto 3) | **Hecho**; pings PC1 a PC7, Server1 y Laptop1 con 0 % de pérdida. **Falta** el análisis en modo simulación y el experimento de spanning tree |
| VLAN 50 y 55 con trunk (punto 4) | **Hecho y verificado**: `show vlan brief`, trunk y pings (misma VLAN responde, otra no) |
| WiFi básico (punto 5) | **Hecho** en Packet Tracer: router, AP, celulares, DHCP y NAT comprobado. **Falta** la tarjeta WiFi de los dos laptops |
| Punto 6 (LAN + WiFi + VLAN por colores) | **No construido** |
| Puntos 7 y 8 (router físico, celular, WiFi Analyzer) | **No ejecutados**: necesitan el router del salón y un celular |
| Menú de comandos de red (2.a) | **Probado** en Slackware y Solaris. `info_red.ps1`: solo sintaxis, no ejecutado en Windows |
| Puerto abierto SI/NO (2.b) | **Probado** en Slackware y Solaris |
| Calculadora en AWS | Aplicación probada en el Lab 6; **despliegue en AWS no ejecutado** |
| SNMP en Slackware (parte 3) | **Verificado**: agente UDP 161, `snmpget`/`snmpwalk` y Prometheus |
| Agente SNMP en NetBSD | Script escrito, **sin probar** (no hay VM de NetBSD) |

Notas: los proyectos de Packet Tracer 3 y 4 no incluyen el análisis en modo simulación. Packet Tracer no acepta espacios en la clave WiFi,
así que `SECURITY R` y `SECURITY AP` se escribieron `SECURITYR` y `SECURITYAP`. No se incluyen contraseñas reales de las máquinas ni `config.php` de la calculadora.
