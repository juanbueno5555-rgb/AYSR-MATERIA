# Guion — Video curso "Getting Started with Cisco Packet Tracer" (Lab 02, 1.2)

> Grupo: Camilo Aguirre (CA) y Juan David Rangel (JD) — Curso AYSR
> Duración objetivo: ~5 minutos | Herramienta: Packet Tracer 9.0.1
> Reparto 50/50 en 2 tomas: **Mitad 1 (0:00–2:30): JD** | **Mitad 2 (2:30–5:00): CA**
> Temas: primeros 4 capítulos del curso (qué es PT, interfaz, modos Lógico/Físico,
> agregar/conectar dispositivos, red simple + verificación).
> Base técnica: contenido ITN v7 capturado (secciones 1.0.x, 1.5.5) + lab.
> Guion: texto para LEER EN VOZ ALTA (natural), no para copiar textual en ningún
> informe. Cada mitad es UN SOLO TAKE continuo; las indicaciones de pantalla son notas
> de la toma, no cortes de edición.

---

## Estructura y tiempos (total ~5:00)

| Mitad | Quién | Horario | Temas cubiertos |
|---|---|---|---|
| **Mitad 1 — un solo take** | **JD** | **0:00–2:30** | Presentación del grupo; qué es Packet Tracer; interfaz y menús (File, Open Samples, Exit and Logout, panel de dispositivos); modos Lógico y Físico |
| **Mitad 2 — un solo take** | **CA** | **2:30–5:00** | Handoff; dispositivos y cables (Copper Straight-Through, Serial DCE/DTE); red simple + verificación (IP, ping, ARP, Simulation); cierre y despedida |
| **TOTAL** | **JD + CA** | **0:00–5:00** | Reparto 50/50: JD 2:30 / CA 2:30 |

---

## Mitad 1 [JD] — 0:00–2:30 (un solo take)

**(En pantalla: portada del video + Packet Tracer abierto. Mientras se menciona la
interfaz, recorrerla con el mouse; al hablar de los modos, alternar Lógica/Física.)**

**JD:** "Hola, somos Camilo Aguirre y Juan David Rangel. En este video les contamos qué
aprendimos en los primeros capítulos del curso *Getting Started with Cisco Packet Tracer*
de Cisco Networking Academy. Packet Tracer es un simulador de redes: nos permite armar
redes virtuales con routers, switches, PCs y servidores, y probar cómo funcionan, sin
necesidad de tener el hardware físico. Lo usamos a lo largo de todo nuestro laboratorio,
así que conocer su interfaz es el primer paso.

La interfaz de Packet Tracer es muy parecida a la de cualquier programa. Arriba tenemos la
barra de menús y la barra de herramientas. En el menú File están los comandos clásicos
—abrir, guardar, guardar como— pero hay dos especiales: **Open Samples**, que abre ejemplos
ya armados con distintas configuraciones, y **Exit and Logout**, que cierra la sesión de
nuestra cuenta en este equipo. Abajo está el panel de dispositivos, organizado por
categorías: routers, switches, dispositivos finales —como PCs y servidores— y conexiones.
Con el mouse arrastramos un dispositivo al área de trabajo, y ahí podemos seleccionarlo,
moverlo, eliminarlo, inspeccionarlo, etiquetarlo y agruparlo. Es el punto de partida para
armar cualquier red.

Además, Packet Tracer tiene dos modos de ver la red. En la vista **Lógica** vemos el
esquema conceptual: los dispositivos y cómo están conectados entre sí; es la vista que
usamos para armar y configurar la red. En la vista **Física** vemos dónde están los
equipos en el espacio real: edificios, rack, wiring closet, ciudades. La actividad
*Logical and Physical Mode Exploration* del curso muestra una oficina y un centro de
datos: ahí se ve cómo en el modo físico los dispositivos se ubican geográficamente,
mientras que en el modo lógico lo que importa es la relación lógica entre ellos. O sea:
lo lógico es el *cómo se conectan*; lo físico es el *dónde están*. Ahora, Camilo les
cuenta cómo se arma la red y se verifican las comunicaciones."

## Mitad 2 [CA] — 2:30–5:00 (un solo take)

**(En pantalla: arrastrar un PC, un switch y un router; conectarlos. Después configurar
una IP y hacer ping; cambiar a Simulation. Al final, volver a portada o red armada.)**

**CA:** "Ahora les voy a contar cómo se arma la red, cómo se conectan los dispositivos y
cómo verificamos que funcionan. Para armarla, arrastramos los dispositivos desde el
panel. Cuando los agregamos, aparecen puntos verdes en los puertos: eso indica que el
equipo está encendido. Después los conectamos con el cable correcto. En la pestaña de
conexiones hay varios tipos: el cable **Copper Straight-Through**, que es el Ethernet
normal, se usa por ejemplo entre un PC y un switch, y entre un switch y un router. Para
conexiones WAN entre routers se usa el cable **Serial**, que aparece en rojo y tiene un
extremo DCE y otro DTE. Elegir el cable correcto es clave para que la red funcione, tal
como vimos en la actividad *Connect a Wired and Wireless LAN*.

Una vez conectados, a los dispositivos finales les configuramos la dirección IP desde la
pestaña Desktop, en IP Configuration: ahí van la IP, la máscara y el gateway. Para
verificar que dos equipos se comunican usamos el comando **ping** desde el Command
Prompt. Y esto es lo interesante: la primera vez que hacemos ping, antes del mensaje ICMP
el origen envía un **ARP request** para resolver la dirección IP del destino a su
dirección MAC de capa 2. Con el modo **Simulation** de Packet Tracer vemos esos paquetes
viajar paso a paso, y es exactamente lo que hicimos en la actividad del curso y lo que
después repetimos en el laboratorio con Wireshark.

En resumen: Packet Tracer nos deja simular redes sin hardware físico; la interfaz es
amigable; la vista lógica nos muestra la topología y la física el emplazamiento; y con
unos pocos dispositivos, cables e IPs podemos verificar conectividad con ping. Y entender
cómo los paquetes viajan capa por capa —con ARP, ICMP y la simulación— es la base del
resto del curso. Eso fue lo que aprendimos en los primeros capítulos del curso. ¡Gracias
por vernos!"

---

## Notas

- **Reparto 50/50:** JD 2:30 (mitad 1) y CA 2:30 (mitad 2), cada uno en un solo take.
- **Evidencia del curso:** además del video, cada uno rinde el quiz "PT Basics Quiz" y
  sube screenshot (paso 1.3 del lab — anotado en NOTAS-LAB02.md).
- **Idioma:** español neutro, sin tecnicismos innecesarios; quedan bien las secciones
  donde se ve la herramienta mientras se explica.

## Cómo grabar

- Grabar la **mitad 1 (JD)** y la **mitad 2 (CA)** en **UN SOLO TAKE** cada una, sin
  pausas ni cortes internos.
- Dejar **1–2 segundos de silencio** al inicio y al final de cada toma (facilita el
  recorte en la edición).
- Grabar ambas tomas con la **misma resolución y fps** (recomendado 1080p / 30 fps),
  preferentemente el mismo día y con la misma luz.
- Guardar como archivos separados: `video1-mitad1.mp4` (JD) y `video1-mitad2.mp4` (CA).
- Juntarlas después en ese orden siguiendo `GUIA-EDICION-VIDEOS-LAB02.md`.
- Duración máxima del video final: **5:00** (mitad 1 ≈ 2:30 + mitad 2 ≈ 2:30).