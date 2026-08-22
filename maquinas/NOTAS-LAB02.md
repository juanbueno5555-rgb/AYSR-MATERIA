# Notas — Laboratorio No. 02: OS Setup, Shell y Software de Soporte de Red

> Grupo de 2 estudiantes: Camilo Aguirre y Juan David Rangel
> Curso: Arquitectura y Servicios de Red (AYSR) — Prof. John Alexander Pachón Pinzón
> Entrega: viernes 21 de agosto de 2026
> Plan maestro y checklist: `GUIA-LAB02.md`

---

## 1. Getting to Know Packet Tracer

### 1.1 Pregunta 1 — Versión de Packet Tracer en la plataforma Cisco

- **Respuesta:** Packet Tracer 9.0.1

### 1.2 Curso "Getting Started with Cisco Packet Tracer" (video cap. 1-4, máx. 5 min)

- **Estado:** Guion listo → `GUION-VIDEO-1-PACKET-TRACER.md` (base: contenido ITN v7 capturado)
- **Pregunta 1 del lab (versión):** Packet Tracer 9.0.1 ✅
- **Video a grabar:** 6 bloques ~5 min, Camilo + Juan David
- **Aclaración:** el scraping local (`cisco-course/out/`) es del curso CCNA ITN v7 completo; el curso corto "Getting Started with Cisco Packet Tracer" no estaba scrapeado, el guion se armó con el contenido equivalente de PT del ITN v7.

### 1.3 Quiz "Introduction to Packet Tracer - PT Basics Quiz" (individual, screenshot)

- **Camilo:** [PENDIENTE]
- **Juan David:** ✅ Rendido — pantallazo del resultado tomado.
  - Evidencia: `Compartido/JuanDavidRangel-ExamGettingStarted.png` (en la raíz de Compartido).
  - Sugerencia: copiarla también a `lab-evidencias/` para que quede con el resto de las evidencias del lab.

### 1.4 Diagrama de red en Packet Tracer (individual, archivo .pkt)

- **Estado:** Camilo entregó su paquete completo (`FINAL CAMILO.pkt`) el 21/08. Copiado al repo como `lab-evidencias/pt/diagrama-camilo-final.pkt`; el de Juan David también está (`lab-evidencias/pt/diagrama-juan-primer-paso.pkt`).
- **⚠️ Pendiente:** abrir en PT y verificar que todos los links estén Up (en la versión de Juan, los de Router2 estaban `Down`) + correr la simulación de la sección 2 con capturas.
- **Respuesta links negros sólidos:** enlaces físicos Ethernet directos (cable cobre) entre dispositivos — la conexión de capa física real que transporta tramas (L1/L2).
- **Respuesta links negros punteados:** conexiones lógicas o virtuales — no hay cable físico directo; representan una relación lógica (ruta a través de la red, enlace inalámbrico o un enlace aún no activo).
- **Cable serial Router0-Router2:** cable Serial DCE/DTE (rojo) entre los puertos seriales de los routers; el extremo DCE define el clock rate.

---

## Estado general del Lab 02 (16/08)

| Sección | Estado |
|---|---|
| 1.1 Versión PT | ✅ 9.0.1 |
| 1.2 Curso + video | ✅ Video grabado y editado (video1-packet-tracer.mp4, 3:42) |
| 1.3 Quiz PT Basics | 🔶 Juan David ✅ — falta Camilo |
| 1.4 Diagrama .pkt | 🔶 Paquete completo de Camilo recibido y en repo (21/08) — falta verificar links Up en PT + capturas |
| 2. Rastreo mensajes PT | 🔶 Documento listo (`PT-LAB02-SECCION2.md`) — falta correr la simulación y pegar capturas |
| 3. Wireshark | ✅ Captura real (scielo.org.co) + análisis + videos 2 y 3 editados (3:37 y 4:29) |
| 4. Tarjetas de red | 🔶 Host completo (SSID EVANGELIO_5G, 866.7 Mbps) — falta: 3 dispositivos por integrante + PCs de la escuela |
| 5. Shell scripts 1.1-1.4 | ✅ Documentados con salidas reales (17/08) |
| 6. Editor VI | ✅ Ejercicio completo y documentado (17/08) |
| 7. Clonar VMs (2 por SO) | ✅ Pings entre las 3 VMs verificados en la red de casa (21/08): Slackware .13 ↔ Solaris .11 ↔ Windows GUI .14, todos 0% loss + internet. Evidencia: `lab-evidencias/red/pings-vms-lab02.txt`. En la uni usan IPs estáticas .74/.75/.76 |
| 8. SAMBA en Solaris | ✅ Funcionando con evidencia (17/08) |

**Evidencias clave (rutas):**
- Shell scripts: `lab-evidencias/shell-scripts-lab02-documentacion.md` (mi_ls.sh probado en /etc, buscar.sh con /etc/fstab, revisar_logs.sh con filtro sshd, newgroup/newuser con alice + permisos 700/770/755 y errores por duplicado probados).
- VI: `lab-evidencias/vi-lab02-evidencias.md` (himno.txt 16 líneas, 13 operaciones, tabla resumen de comandos).
- SAMBA: `lab-evidencias/red/samba-lab02-evidencias.txt` + captures (Samba clásico en Solaris compartiendo `compartido` en 445, usuarios claudia/admin, probado desde Slackware con smbclient put/get y Windows con net use).
- VMs: snapshots `estado-final-2026-08-17` en cada clon; auto-detección de red al boot (uni .74/.75/.76 estáticas, casa DHCP).

---

## 5.3 Respuestas conceptuales — Logs (para el informe)

1. **¿Qué son los archivos de log?** → Registros donde el SO y los servicios guardan eventos (fecha, origen, mensaje). Sirven para diagnóstico, auditoría y seguridad.
2. **¿Qué tipos de logs hay en los SO instalados?** → Slackware: `syslog`, `messages`, `secure` (+ dmesg/kernel). Solaris: `/var/adm/messages`. Windows: Visor de eventos (System, Security, Application — eventos 4624/4625 del Lab 01).
3. **¿Qué es syslog y qué define el estándar?** → Protocolo/estándar de logging (RFC 5424): define formato (facilidad + severidad), transporte (UDP 514) y el servicio; centraliza logs de distintos dispositivos.
4. **¿Los logs encontrados siguen el estándar?** → Sí: Slackware/Solaris usan formato syslog (`facilidad.severidad`, timestamp, host, proceso[pid]: mensaje). Windows usa Event Log propio — no es syslog nativo (requiere agente para enviarlo).