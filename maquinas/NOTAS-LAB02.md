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

- **Estado:** En progreso — topología armada (Router0 1941, Router1 1841, Router2 1841, Switch1 2950-24, Server0/1/2, laptops) + IPs configuradas.
- **Esquema de IPs aplicado:**
  - WAN R0-R1: `7.0.0.0/30` (R0=.1, R1=.2)
  - WAN R1-R2: `8.0.0.0/30` (R1=.1, R2=.2)
  - LAN Router0 VLAN10: `10.0.10.0/24` (gw 10.0.10.1) — Server0 `.10`, Server1 `.11`, Switch1 `.2`
  - LAN Router0 VLAN30: `10.0.30.0/24` (gw 10.0.30.1)
  - LAN Router2: `10.0.20.0/24` (gw 10.0.20.1) — Server2 `.10`
- **⚠️ Pendiente:** links de Router2 en `Down` — revisar cables físicos (borrar/reconectar Router1↔Router2) y verificar pings.
- **Evidencia:** `lab-evidencias/simulacion-de-red.png` (subida a rama juan, commit 138d100).
- **Respuesta links negros sólidos:** [PENDIENTE]
- **Respuesta links negros punteados:** [PENDIENTE]
- **Cable serial Router0-Router2:** [PENDIENTE]

---

## Estado general del Lab 02 (16/08)

| Sección | Estado |
|---|---|
| 1.1 Versión PT | ✅ 9.0.1 |
| 1.2 Curso + video | 🔶 Guion listo — falta GRABAR video |
| 1.3 Quiz PT Basics | 🔶 Juan David ✅ — falta Camilo |
| 1.4 Diagrama .pkt | 🔶 En progreso (IPs ok, cables/serial pendiente) |
| 2. Rastreo mensajes PT | ❌ Pendiente |
| 3. Wireshark | 🔶 Captura real hecha (1691 paq, 4 GETs a scielo.org.co, paquete #211 analizado capa por capa) + análisis en `WIRESHARK-LAB02.md` + pcapng en lab-evidencias — **faltan los 2 videos (5 y 7 min)** |
| 4. Tarjetas de red | 🔶 Casi listo (datos VMs Lab 01) |
| 5. Shell scripts 1.1-1.4 | ❌ Pendiente (Slackware) |
| 6. Editor VI | ❌ Pendiente |
| 7. Clonar VMs (2 por SO) | ❌ Pendiente |
| 8. SAMBA en Solaris | ❌ Pendiente |