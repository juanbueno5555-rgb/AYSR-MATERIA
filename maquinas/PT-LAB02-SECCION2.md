# Sección 2 — Tracking Messages with Packet Tracer (Lab 02)

> Simulación: ping desde `Server-PT RADIUS` hacia `Server-PT DHCP`, con las PDUs analizadas capa por capa.
> Archivo usado: `lab-evidencias/pt/diagrama-camilo-final.pkt` (topología completa del grupo).

---

## 2.1 Procedimiento

1. Abrir el diagrama en Packet Tracer.
2. Activar **Simulation Mode** (botón abajo a la derecha, cambia de Realtime a Simulation).
3. **Edit Filters** → marcar únicamente **ICMP** y **ARP**.
4. Doble clic en `Server-PT RADIUS` → pestaña **Desktop** → **Command Prompt**.
5. Ejecutar: `ping <IP-del-DHCP>` (IP por confirmar del diagrama: `___`)
6. **Auto Capture / Play** → dejar correr hasta que aparezca "No More Events".
7. Capturar evidencia (screenshots):
   - Lista de eventos de la simulación.
   - Ventana **PDU Information** de un paquete ICMP echo request (capa 2, 3 y 4).
   - Ventana **PDU Information** del ARP request (si quedó en el filtro).

---

## 2.2 Secuencia de eventos esperada

| # | Evento | Tipo | Qué muestra |
|---|---|---|---|
| 1 | ARP Request (broadcast) | Capa 2 | RADIUS pregunta "¿quién tiene la IP del DHCP? Dame tu MAC" |
| 2 | ARP Reply | Capa 2 | El DHCP responde con su MAC |
| 3 | ICMP Echo Request | Capa 3/4 | ping: "¿estás vivo?" |
| 4 | ICMP Echo Reply | Capa 3/4 | respuesta del DHCP |

> Si RADIUS y DHCP están en **subredes distintas**, entre el ARP y el ICMP aparecen además los saltos del router (el ICMP viaja con la MAC del router en cada enlace, pero la IP origen/destino NO cambia — enrutamiento capa 3).

---

## 2.3 Análisis de PDUs capa por capa

### Paquete ICMP Echo Request (RADIUS → DHCP)

**Capa 2 — Ethernet (trama):**
| Campo | Valor |
|---|---|
| MAC origen | `__:__:__:__:__:__` (NIC del RADIUS) |
| MAC destino | `__:__:__:__:__:__` (MAC del DHCP o del gateway) |
| EtherType | `0x0800` (IPv4) |

**Capa 3 — IP (paquete):**
| Campo | Valor |
|---|---|
| IP origen | `___.___.___.___` (RADIUS) |
| IP destino | `___.___.___.___` (DHCP) |
| Protocolo | `1` (ICMP) |
| TTL | 128 (disminuye 1 por cada salto de router) |

**Capa 4 — ICMP (mensaje):**
| Campo | Valor |
|---|---|
| Type | 8 (Echo Request) |
| Code | 0 |
| Datos | secuencia del ping (Sequence Number) |

### Paquete ICMP Echo Reply (DHCP → RADIUS)

- Mismo camino invertido: MACs intercambiadas, IPs intercambiadas, **Type 0 (Echo Reply)**.

### Paquete ARP Request (si se captura)

- **Ethernet**: MAC destino `FF:FF:FF:FF:FF:FF` (broadcast), EtherType `0x0806` (ARP).
- **ARP**: "Who has `<IP-DHCP>`? Tell `<IP-RADIUS>`".

---

## 2.4 Respuestas conceptuales

1. **¿Qué se observa en la simulación?**
   Antes del primer ping, el servidor RADIUS no conoce la MAC del DHCP, así que genera un **ARP request en broadcast**. Una vez que el DHCP responde con su MAC, los mensajes **ICMP echo request/reply** viajan encapsulados.

2. **¿Qué demuestra esto sobre la encapsulación?**
   Cada capa agrega su encabezado a los datos: los datos del ping (ICMP) se encapsulan en un paquete IP, y el paquete IP en una trama Ethernet. En el destino se hace el proceso inverso (desencapsulación). Es exactamente el modelo que se ve en Wireshark con tráfico real (sección 3) y corresponde al concepto de **encapsulación/desencapsulación del Módulo 3 del curso ITN**.

3. **¿Por qué cambia la MAC destino pero no la IP en un salto de router?**
   La IP es la dirección **lógica** de extremo a extremo (capa 3): no cambia. La MAC es la dirección **física** de salto a salto (capa 2): en cada enlace se reemplaza por la MAC del siguiente dispositivo. Por eso Ethernet es "local" e IP es "global".

---

## 2.5 Evidencia

- [SCREENSHOT pendiente: Simulation mode con Event List (ARP + ICMP)]
- [SCREENSHOT pendiente: PDU Information — capa 2 Ethernet del ICMP]
- [SCREENSHOT pendiente: PDU Information — capa 3 IP del ICMP]
- [SCREENSHOT pendiente: PDU Information — capa 4 ICMP]
