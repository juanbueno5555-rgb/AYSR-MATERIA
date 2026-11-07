# Monitoreo de red con SNMP (Lab 8, parte 3)

La guía pide: instalar un servidor que monitoree las máquinas virtuales y mostrarlo en tiempo real. En un grupo de dos,
**un estudiante usa Slackware y el otro NetBSD**. Pista de la guía: implementaciones del protocolo SNMP.

## Cómo funciona (explicación corta)
- **SNMP** es un protocolo para preguntarle a un equipo por su estado: carga de CPU, memoria, disco, tráfico por interfaz, tiempo encendido.
- Cada equipo corre un **agente** (aquí `snmpd` de net-snmp, puerto UDP 161) que responde esas preguntas.
- El servidor de monitoreo hace las preguntas cada 15 segundos y guarda los números.
- **Comunidad:** es la "contraseña" de SNMP v2c. Aquí es `lab07mon` y solo permite lectura (`rocommunity`) desde la red del laboratorio.
- Cada dato tiene una dirección numérica llamada **OID**. Ejemplo: `1.3.6.1.2.1.1.5.0` es el nombre del equipo.

## Qué está montado (Slackware, estudiante 1)
| Pieza | Función | Puerto |
|---|---|---|
| `snmpd` (net-snmp) | Agente en cada VM | UDP 161 |
| `snmp_exporter` | Traduce las respuestas SNMP a métricas | TCP 9116 |
| Prometheus | Pregunta cada 15 s a todas las VM y guarda los datos; su página web muestra los valores en tiempo real | TCP 9090 |

Configuración: `slackware-servidor-snmp.sh`. Agentes: `freebsd-servidor-snmp.sh`, `windows-snmp.ps1` y, para Juan, `netbsd-agente-snmp.sh`.
En el PC anfitrión, Prometheus de Slackware se ve en `http://127.0.0.1:9091` (puerto 9090 de la VM, redirigido).

## Verificado el 2026-11-06 (ver `../evidencias/snmp-slackware.txt`)
- `snmpd` escucha en UDP 161 en Slackware.
- `snmpget` con la comunidad `lab07mon` devuelve nombre, descripción y tiempo encendido.
- `snmpwalk` devuelve memoria (total 1.010.184 kB) y carga de CPU.
- Prometheus: el objetivo 192.168.82.10 (Slackware) estaba `up`. Los otros objetivos estaban apagados en ese momento (FreeBSD, Windows) o recién encendidos (Solaris).

## No verificado
- El agente de NetBSD (`netbsd-agente-snmp.sh`): no hay VM de NetBSD; las rutas de pkgsrc deben comprobarse en la máquina.
- Grafana: no existe versión para Slackware de 32 bits, por eso la pantalla en tiempo real es la interfaz de Prometheus (consultas como `laLoad`, `memAvailReal`, `ifHCInOctets`).

## Pasos para repetirlo
1. En cada VM instalar y arrancar el agente con su script (Slackware ya lo tiene).
2. En Slackware, como root: `sh slackware-servidor-snmp.sh`. Descarga Prometheus y snmp_exporter, escribe `prometheus.yml` y los deja arrancando desde `rc.local`.
3. Abrir `http://IP-de-Slackware:9090/targets` y comprobar que cada máquina esté `UP`.
4. Mostrar al profesor: configuración (`/etc/snmp/snmpd.conf`, `prometheus.yml`), puertos (`netstat -uln | grep 161`, `netstat -tln | grep -E '9090|9116'`) y el gráfico en tiempo real de una consulta.
