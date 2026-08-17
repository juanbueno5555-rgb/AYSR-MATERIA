# Wireshark — Análisis de captura real (Lab 02, sección 3)

> Grupo de 2 estudiantes: Camilo Aguirre y Juan David Rangel
> Fecha: 16/08/2026 — Captura real desde el PC (Wi-Fi, interfaz NPF Wi-Fi)

## 1. ¿Qué es Wireshark?

Analizador de protocolos de red (sniffer). Captura paquetes en vivo desde una interfaz de red,
los decodifica capa por capa (Ethernet, IP, TCP/UDP, HTTP, DNS, etc.) y los muestra en tres
paneles: lista de paquetes, detalle del paquete y bytes. Es multiplataforma (Windows, Linux, macOS).

## 2. ¿Qué significa que una tarjeta de red esté en modo promiscuo?

Normalmente la NIC solo procesa las tramas dirigidas a su propia MAC (o broadcast/multicast).
En **modo promiscuo**, la NIC captura TODAS las tramas que pasan por el medio físico aunque no
vayan dirigidas a ella. Wireshark necesita este modo para poder ver todo el tráfico del segmento.

## 3. Captura realizada

- **Sitio consultado:** `http://www.scielo.org.co` (HTTP, no HTTPS — para poder ver el GET en claro)
- **Duración de captura:** 30 segundos
- **Total capturado:** 1691 paquetes (1.558.566 bytes)
- **Peticiones GET capturadas:** 4 (todas hacia `168.176.28.57` — servidor de SciELO)
- **Archivo de evidencia:** `lab-evidencias/wireshark-scielo.pcapng`

## 4. Análisis del paquete GET — encapsulación capa por capa

Paquete analizado: **frame #211** (216 bytes) — `GET / HTTP/1.1`

| Capa | Protocolo | Datos del paquete |
|---|---|---|
| 1. Física/Enlace | Frame (Ethernet II) | 216 bytes en el cable · tipo Ethernet (1) |
| 2. Enlace | Ethernet II | MAC destino `e0:a1:ce:d2:85:76` (zte, router) · MAC origen `08:f9:7e:9e:25:03` (CloudNetwork) · EtherType IPv4 (0x0800) |
| 3. Red | IPv4 | IP origen `192.168.1.10` (nuestro PC) → IP destino `168.176.28.57` (scielo.org.co) · TTL 128 · no fragmentar |
| 4. Transporte | TCP | Puerto origen `60427` (efímero) → puerto destino `80` (HTTP) · flags PSH+ACK · seq 1 |
| 5. Aplicación | HTTP | `GET / HTTP/1.1` — petición de la página principal |

**Observación clave (encapsulación):** cada capa agrega su encabezado a los datos de la capa
superior. Los datos del usuario (la petición HTTP) van envueltos en TCP (capa 4), luego en IP
(capa 3), luego en Ethernet (capa 2). Al llegar al servidor, se desencapsula en orden inverso.

## 5. Resumen de protocolos vistos en la captura

| Protocolo | Paquetes | Nota |
|---|---|---|
| QUIC (UDP 443) | 1266 | Tráfico HTTPS moderno (Chrome/YouTube de fondo) |
| TCP | 168 | Incluye la conexión HTTP a SciELO |
| HTTP | 17 | Las 4 peticiones GET + respuestas a SciELO |
| TLS | 41 | Handshakes HTTPS |
| DNS | 9 | Resolución de nombres (IPv4 + IPv6) |
| mDNS | 4 | Descubrimiento local |
| ICMPv6 | 4 | Vecindario IPv6 |

**Conclusión:** se observa el comportamiento mixto de una navegación real: HTTP en claro hacia
scielo.org.co (visible el GET), HTTPS/QUIC cifrado hacia Google (172.217.x.x — tráfico de fondo),
y protocolos auxiliares (DNS, mDNS). La encapsulación HTTP→TCP→IP→Ethernet se ve clara en el
paquete GET analizado.

## 6. Para el video (máx. 7 min)

- Mostrar la captura abierta en Wireshark con el filtro `http.request.method == "GET"`
- Expandir el paquete GET capa por capa (Frame → Ethernet → IP → TCP → HTTP)
- Explicar qué es Wireshark y el modo promiscuo
- Explicar los paneles: packet list, packet details, packet bytes
- Ejemplos de filtros: `ip.addr == 168.176.28.57`, `tcp.port == 80`, `http.request.method == "GET"`, `icmp`

## 7. Figuras para el informe LaTeX

### Figura 1 — Captura en Wireshark del tráfico a scielo.org.co

- **Archivo:** `lab-evidencias/wireshark-captura-scielo.png`
- **Qué muestra:** ventana de Wireshark (interfaz Wi-Fi) con la lista de paquetes HTTP
  entre `192.168.1.10` (PC) y `168.176.28.57` (scielo.org.co), puerto 80.
  Se ven los tres paneles: lista de paquetes (arriba), detalle del paquete TCP (medio) y
  bytes hex/ASCII (abajo). Entre los paquetes: `GET / HTTP/1.1`, `GET /css/scielo.css`,
  `GET /img/en/scielobre.gif`, respuestas `200 OK`, `301 Moved Permanently`, etc.
- **Sugerencia LaTeX:**
```latex
\begin{figure}[H]
  \centering
  \includegraphics[width=0.9\textwidth]{../lab-evidencias/wireshark-captura-scielo.png}
  \caption{Captura en Wireshark del tráfico HTTP hacia scielo.org.co.}
  \label{fig:wireshark-scielo}
\end{figure}
```
- **Pie de figura propuesto:** "Captura de Wireshark mostrando las peticiones GET hacia
  www.scielo.org.co (168.176.28.57) desde el host 192.168.1.10. Se observa la encapsulación
  en los tres paneles de la interfaz."

### Figura 2 (opcional) — Paquete GET expandido capa por capa

- Captura desde Wireshark: clic en un paquete `GET / HTTP/1.1` → expandir las secciones
  Frame, Ethernet II, Internet Protocol, Transmission Control Protocol, Hypertext Transfer Protocol.
- Guardar como `lab-evidencias/wireshark-paquete-get.png` cuando se genere.
