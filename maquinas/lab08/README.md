# Laboratorio 8 · AYSR (capa de enlace y capa de aplicación)

Camilo Aguirre Rico y Juan David Rangel · Escuela Colombiana de Ingeniería Julio Garavito.
Guía oficial: *Lab No.08 - Data Link Layer and Application Layer*.

## Qué hay en esta carpeta
| Carpeta | Contenido |
|---|---|
| `guias/` | Word: **GUIA (Lab 8)** (qué se hizo paso a paso), **SUSTENTACION (Lab 8)** y **QUE HACES EN LA U (Lab 8)** |
| `scripts/` | `info_red.sh` / `info_red.ps1` (menú de comandos de red) y `puerto.sh` (puerto abierto SI/NO) |
| `switches/` | Configuración de switches (`switch-basico.txt`, `switch-vlan.txt`) y guía de Ethernet, Wireshark, spanning tree y VLAN |
| `wifi/` | Datos y preguntas de los puntos 5 a 8 (WiFi) |
| `webapp/` | Calculadora de notas PHP + PostgreSQL y pasos de despliegue en AWS |
| `snmp/` | Monitoreo SNMP: servidor Slackware, agentes de FreeBSD, Windows y NetBSD, y guía |
| `evidencias/` | Salidas reales de las máquinas virtuales (2026-11-06) |

## Estado (qué está probado y qué no)
| Punto | Estado |
|---|---|
| Menú de comandos de red (2.a) | **Probado** en Slackware y Solaris (`evidencias/red-*.txt`). `info_red.ps1`: sintaxis comprobada, no ejecutado en la VM de Windows |
| Puerto abierto SI/NO (2.b) | **Probado** en Slackware y Solaris |
| Monitoreo SNMP en Slackware (parte 3) | **Verificado**: agente en UDP 161, `snmpget`/`snmpwalk` y Prometheus (`evidencias/snmp-slackware.txt`) |
| Agente SNMP en NetBSD | Script escrito, **sin probar** (no hay VM de NetBSD) |
| Calculadora (parte 2.1) | Aplicación probada en el Lab 6; **despliegue en AWS no ejecutado** |
| Switches, VLAN, Wireshark (puntos 1 a 4) | Configuración escrita, **no ejecutada** (se hace con los switches del salón) |
| WiFi en Packet Tracer y físico (puntos 5 a 8) | Guía escrita, **no ejecutada**; los proyectos `.pkt` faltan por armar |

No se incluyen contraseñas reales de las máquinas ni `config.php` de la calculadora (solo `config.example.php`).
