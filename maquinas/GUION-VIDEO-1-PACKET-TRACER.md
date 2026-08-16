# Guion — Video curso "Getting Started with Cisco Packet Tracer" (Lab 02, 1.2)

> Grupo: Camilo Aguirre (CA) y Juan David Rangel (JD) — Curso AYSR
> Duración objetivo: ~5 minutos | Herramienta: Packet Tracer 9.0.1
> Temas: primeros 4 capítulos del curso (qué es PT, interfaz, modos Lógico/Físico,
> agregar/conectar dispositivos, red simple + verificación).
> Base técnica: contenido ITN v7 capturado (secciones 1.0.x, 1.5.5) + lab.
> Guion: texto para LEER EN VOZ ALTA (natural), no para copiar textual en ningún
> informe. Reemplazar CONSEJOS con la demo real que muestren.

---

## Estructura y tiempos (total ~5:00)

| Bloque | Quién | Tiempo | Tema |
|---|---|---|---|
| 1. Intro | JD | 0:00–0:25 | Qué es Packet Tracer y por qué lo usamos |
| 2. Interfaz y menús | CA | 0:25–1:40 | Espacio de trabajo, menús, cargar/guardar |
| 3. Modos Lógico y Físico | JD | 1:40–2:40 | Diferencias y para qué sirve cada uno |
| 4. Dispositivos y cables | CA | 2:40–3:45 | Agregar dispositivos, conectarlos, tipos de cable |
| 5. Red simple + verificación | JD | 3:45–4:40 | IPs, ping, la idea de la simulación |
| 6. Cierre | JD + CA | 4:40–5:00 | Resumen y para qué se conecta con el lab |

---

## 1. Intro [JD] — 0:00–0:25

**(En pantalla: portada del video + Packet Tracer abierto)**

**JD:** "Hola, somos Camilo y Juan David. En este video les contamos qué aprendimos en los
primeros capítulos del curso *Getting Started with Cisco Packet Tracer* de Cisco Networking
Academy. Packet Tracer es un simulador de redes que nos permite armar y probar redes
virtuales —routers, switches, PCs, servidores— sin necesidad de tener el hardware físico.
Lo usamos a lo largo de nuestro laboratorio y del curso de redes."

## 2. Interfaz y menús [CA] — 0:25–1:40

**(En pantalla: recorrer la interfaz de PT 9.0.1 con el mouse)**

**CA:** "La interfaz de Packet Tracer es muy parecida a la de cualquier programa. Arriba
tenemos la barra de menús y la barra de herramientas. En el menú File encontramos los
comandos clásicos, como abrir, guardar y guardar como, pero hay dos especiales:
**Open Samples**, que abre ejemplos ya armados con distintas configuraciones, y
**Exit and Logout**, que cierra la sesión de nuestra cuenta en este equipo.

Por defecto usamos la **Lógica**..." (corto, se engancha con el bloque 3)

**CA:** "...En la parte de abajo tenemos el panel de dispositivos, organizados por categorías:
routers, switches, dispositivos finales —como PC y servidores— y conexiones. Con el mouse
arrastramos un dispositivo al área de trabajo, y ahí empieza la magia: podemos seleccionar,
mover, eliminar, inspeccionar, etiquetar y agrupar los componentes de nuestra red."

## 3. Modos Lógico y Físico [JD] — 1:40–2:40

**(En pantalla: pulsar el ícono Físico/Lógico y mostrar ambos modos)**

**JD:** "Packet Tracer tiene dos modos de ver la red. En la vista **Lógica** vemos el esquema
conceptual: los dispositivos y cómo están conectados entre sí. Es la vista que usamos para
armar y configurar la red. En la vista **Física** vemos dónde están los equipos en el espacio
real: edificios, rack, wiring closet, ciudades. La actividad *Logical and Physical Mode
Exploration* del curso muestra una oficina y un centro de datos; ahí se ve cómo en el modo
físico los dispositivos se ubican geográficamente, mientras que en el modo lógico lo que
importa es la relación lógica entre ellos."

**CA:** (interrumpe breve, opcional) "O sea, lo lógico es el *cómo se conectan*; lo físico es
el *dónde están*."

## 4. Dispositivos y cables [CA] — 2:40–3:45

**(En pantalla: arrastrar un PC, un switch y un router; conectarlos)**

**CA:** "Para armar la red, arrastramos los dispositivos desde el panel. Cuando los agregamos,
aparecen puntos verdes en los puertos: eso indica que el equipo está encendido. Después los
conectamos con el cable correcto. En las conexiones tenemos varios tipos: el cable **Copper
Straight-Through**, que es el Ethernet normal, se usa por ejemplo entre un PC y un switch, y
entre un switch y un router. Para conexiones WAN entre routers se usa el cable **Serial**,
que aparece en rojo y tiene un extremo DCE y otro DTE. Elegir el cable correcto es clave para
que la red funcione, tal como vemos en la actividad *Connect a Wired and Wireless LAN*."

## 5. Red simple + verificación [JD] — 3:45–4:40

**(En pantalla: configurar IP en un servidor y hacer ping desde el Command Prompt)**

**JD:** "Una vez conectados, a los dispositivos finales les configuramos la dirección IP desde
la pestaña Desktop, en IP Configuration: ahí van la IP, la máscara y el gateway. Para
verificar que dos equipos se comunican usamos el comando **ping** desde el Command Prompt.
Y esto es lo interesante: cuando hacemos ping por primera vez, antes del mensaje ICMP el
origen envía un **ARP request** para resolver la dirección IP del destino a su dirección MAC
de capa 2. Eso lo vemos clarísimo con el modo **Simulation** de Packet Tracer, que nos deja
ver los paquetes viajando paso a paso, y es exactamente lo que hicimos en la actividad del
curso y lo que después repetimos en el laboratorio con Wireshark."

## 6. Cierre [JD + CA] — 4:40–5:00

**(En pantalla: red armada o portada)**

**JD:** "En resumen: Packet Tracer nos deja simular redes, la interfaz es amigable, la vista
lógica nos muestra la topología y la física el emplazamiento, y con unos pocos dispositivos,
cables e IPs podemos verificar conectividad con ping."

**CA:** "Y entender cómo los paquetes viajan capa por capa es la base del resto del curso."

**JD:** "¡Gracias por vernos!"

---

## Notas de producción

- **Total aproximado con cortes: 4:50–5:10.** Ajustar por tiempos muertos; si excede los
  5 min, recortar el bloque 4 (lo más técnico-visual) o acelerar la toma del bloque 2.
- **Pantalla recomendada:** grabar la pantalla con PT abierto mientras se lee; alternar
  Lógica/Física al llegar al bloque 3; mostrar el ping + Simulation en el bloque 5.
- **Idioma:** español neutro, sin tecnicismos innecesarios; quedan bien las secciones donde
  se ve la herramienta mientras se explica.
- **Evidencia del curso:** además del video, cada uno rinde el quiz "PT Basics Quiz" y sube
  screenshot (paso 1.3 del lab — anotado en NOTAS-LAB02.md).