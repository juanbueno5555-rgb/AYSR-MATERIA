# Guion — Video 1 Wireshark: interfaz y filtros (Lab 02, sección 3.2)

> Grupo: Camilo Aguirre (CA) y Juan David Rangel (JD) — Curso AYSR
> Duración objetivo: ~5 minutos | Herramienta: Wireshark
> Reparto 50/50 en 2 tomas: **Mitad 1 (0:00–2:30): CA** | **Mitad 2 (2:30–5:00): JD**
> Temas: ventana principal (packet list, packet details, packet bytes), barra de
> filtros (ip.addr, tcp.port, http.request.method, icmp), iniciar/detener captura,
> guardar captura .pcapng.
> Base técnica: sección 3.2 del lab + WIRESHARK-LAB02.md.
> Guion: texto para LEER EN VOZ ALTA (natural), no para copiar textual en ningún
> informe. Cada mitad es UN SOLO TAKE continuo; las indicaciones de pantalla son notas
> de la toma, no cortes de edición.

---

## Estructura y tiempos (total ~5:00)

| Mitad | Quién | Horario | Temas cubiertos |
|---|---|---|---|
| **Mitad 1 — un solo take** | **CA** | **0:00–2:30** | Presentación del grupo; qué es Wireshark; ventana principal (packet list, packet details, packet bytes); barra de filtros (ip.addr, tcp.port, http.request.method, icmp) |
| **Mitad 2 — un solo take** | **JD** | **2:30–5:00** | Handoff; iniciar/detener captura (interfaz, tiburón azul, cuadrado rojo; modo promiscuo); guardar captura .pcapng; cierre y adelanto del video de hallazgos |
| **TOTAL** | **CA + JD** | **0:00–5:00** | Reparto 50/50: CA 2:30 / JD 2:30 |

---

## Mitad 1 [CA] — 0:00–2:30 (un solo take)

**(En pantalla: portada del video + Wireshark abierto con la pantalla de interfaces.
Después abrir una captura y señalar cada panel con el mouse; al hablar de filtros,
escribir cada uno en la barra y mostrar el resultado.)**

**CA:** "Hola, somos Camilo Aguirre y Juan David Rangel. En este primer video de
Wireshark les mostramos la interfaz del programa y sus filtros. Wireshark es un
analizador de protocolos: captura paquetes en vivo desde una interfaz de red y los
decodifica capa por capa —Ethernet, IP, TCP, HTTP, DNS—. Con él vamos a analizar, en el
siguiente video, la captura real de nuestra visita a scielo.org.co.

Primero, la ventana principal de Wireshark se divide en tres paneles. Arriba está la
**lista de paquetes**: cada fila es un paquete capturado, con su número, el tiempo, la IP
de origen y destino, el protocolo y un resumen de la información. En el medio está el
**detalle del paquete**: al hacer clic en un paquete se despliega su contenido en forma de
árbol, protocolo por protocolo. Y abajo están los **bytes del paquete**: el contenido
crudo en hexadecimal y ASCII, tal como viaja por la red. Con los tres paneles pasamos de
la vista general al byte exacto en tres clics.

Segundo, la barra de filtros está justo debajo de la barra de herramientas. Los filtros no
borran paquetes: ocultan los que no cumplen la condición, y es fácil deshacerlos. Veamos
ejemplos. `ip.addr == 192.168.1.6` muestra todo el tráfico de nuestra dirección IP.
`tcp.port == 443` muestra solo el tráfico HTTPS, el de los sitios seguros.
`http.request.method == "GET"` deja ver únicamente las peticiones GET, las que usan los
navegadores para pedir páginas. Y `icmp` muestra los pings, como el comando ping del video
de Packet Tracer. Escribimos el filtro, Enter, y abajo a la izquierda la barra se pone
verde si la sintaxis es válida, o roja si hay un error. Ahora, Juan David les muestra
cómo se inicia y se detiene una captura y cómo se guarda."

## Mitad 2 [JD] — 2:30–5:00 (un solo take)

**(En pantalla: hacer doble clic en la interfaz Wi-Fi; después el cuadrado rojo, el
tiburón azul y el ícono de limpiar. Luego menú File → Save As → formato .pcapng. Al
final, la captura con un filtro aplicado.)**

**JD:** "Ahora les muestro el flujo completo de trabajo. Para capturar, al abrir
Wireshark aparece la lista de interfaces de red. Hacemos doble clic en la interfaz activa
—en nuestro caso el Wi-Fi— y la captura arranca de inmediato. Para detenerla usamos el
cuadrado rojo. Si queremos empezar de nuevo está el tiburón azul, que inicia una captura
nueva, y el ícono de limpiar, que vacía la lista y vuelve a capturar. Un detalle
importante: Wireshark pone la tarjeta de red en **modo promiscuo**, así que captura todo
el tráfico que pasa por el medio físico, no solo el que va dirigido a nuestra máquina. Por
eso vemos tantos paquetes que no son nuestros.

Cuando la captura está lista, la guardamos con **File, Save As**. El formato estándar de
Wireshark es **.pcapng**, que conserva todos los paquetes y los metadatos de la captura.
La nuestra quedó como *wireshark-scielo.pcapng*: 30 segundos de tráfico guardados para
analizar con calma, abrir más adelante o compartir con el profesor. También se puede
exportar a otros formatos, pero para este laboratorio el .pcapng es el indicado. Ese
archivo es la evidencia que analizamos en el próximo video.

Resumen: la ventana de Wireshark tiene tres paneles —lista de paquetes, detalle y bytes—;
la barra de filtros nos deja aislar tráfico por IP, puerto, protocolo o método HTTP; y la
captura se inicia con el tiburón azul y se guarda como .pcapng. En el próximo video usamos
la captura real de scielo.org.co para explicar los hallazgos: la encapsulación capa por
capa y las diferencias entre los paquetes. ¡Gracias por vernos!"

---

## Notas

- **Reparto 50/50:** CA 2:30 (mitad 1) y JD 2:30 (mitad 2), cada uno en un solo take.
- **Filtros:** el lab usa `ip.addr == 10.2.78.69` como ejemplo genérico; en el video se
  usa la IP real de la captura (192.168.1.6). Mantener la IP de la captura del día.
- **Idioma:** español neutro, sin tecnicismos innecesarios; quedan bien las secciones
  donde se ve la herramienta mientras se explica.

## Cómo grabar

- Grabar la **mitad 1 (CA)** y la **mitad 2 (JD)** en **UN SOLO TAKE** cada una, sin
  pausas ni cortes internos.
- Dejar **1–2 segundos de silencio** al inicio y al final de cada toma (facilita el
  recorte en la edición).
- Grabar ambas tomas con la **misma resolución y fps** (recomendado 1080p / 30 fps),
  preferentemente el mismo día y con la misma luz.
- Guardar como archivos separados: `video2-mitad1.mp4` (CA) y `video2-mitad2.mp4` (JD).
- Juntarlas después en ese orden siguiendo `GUIA-EDICION-VIDEOS-LAB02.md`.
- Duración máxima del video final: **5:00** (mitad 1 ≈ 2:30 + mitad 2 ≈ 2:30).