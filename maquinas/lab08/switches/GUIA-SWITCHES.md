# Switches, Ethernet y VLAN (Lab 8, puntos 1 a 4 de la parte de redes)

> Estado: la **captura de Wireshark** se hizo de verdad (`../evidencias/captura-ping-trama.txt`). Los puntos 2, 3 y 4 están **armados y verificados en Packet Tracer**
> (`../packet-tracer/`), salvo el análisis en modo simulación y el experimento de spanning tree del punto 3, que quedan por hacer.
> Con los switches físicos del salón nada se ha ejecutado todavía.

> Direcciones: punto 1 y 4 → estudiante 1: 183.24.30.A a .D con máscara 255.255.0.0 (en el proyecto A..D = 11..14, gateway 183.24.30.1); estudiante 2 usa 183.24.50.x y el 3 usa 183.24.70.x. Punto 3 → 65.148.77.x/24, gateway 65.148.77.1, estudiante 1 .100 a .120.

## Conceptos mínimos
- **Switch:** reenvía tramas según la **dirección MAC**. Aprende en qué puerto está cada MAC mirando la MAC de origen de cada trama.
- **Tabla de reenvío (tabla MAC):** lista MAC → puerto. Al principio está vacía, por eso las primeras tramas salen por todos los puertos (broadcast/inundación); después solo salen por el puerto correcto.
- **Spanning tree (STP):** si hay un bucle entre switches, bloquea un enlace para que las tramas no den vueltas para siempre. Si el enlace activo cae, desbloquea el otro.
- **VLAN:** divide un switch en redes lógicas separadas. Los equipos de VLAN distintas no se ven aunque estén en el mismo switch.
- **Trunk:** enlace entre switches que lleva varias VLAN por el mismo cable, marcando cada trama con una etiqueta 802.1Q (el número de VLAN).

## Punto 1: switch en grupo y Wireshark
1. Conectar cada PC al switch con cable directo y poner IP en la misma red (la letra del grupo la da el profesor).
2. `ping` entre los dos PC.
3. Abrir Wireshark en uno de los PC, elegir la tarjeta de red, filtrar por `icmp` y hacer un ping.
4. Abrir un paquete y mirar la trama Ethernet II:
   - **Destination / Source:** MAC de destino y de origen (6 bytes cada una).
   - **Type:** 0x0800 significa que dentro va IPv4.
   - **Frame check sequence (FCS):** el control de errores. Wireshark casi nunca lo muestra porque la tarjeta de red lo quita antes de entregar la trama.
5. Conectar los switches de todo el grupo y hacer ping entre todos los PC.

## Punto 2: configuración por consola
Usar `switch-basico.txt`. Pasos de la guía, en orden: modo privilegiado, modo de configuración global, nombre, banner,
sincronización de pantalla y claves, desactivar búsqueda externa (`no ip domain-lookup`), descripción de interfaces,
clave del modo privilegiado, revisar (`show running-config`) y guardar (`copy running-config startup-config`).

## Punto 3: red grande en Packet Tracer
1. Cada estudiante arma su proyecto con el diagrama de la guía y aplica la configuración básica a TODOS los switches.
2. Poner IP a PC, servidores y laptops con la tabla de la guía; verificar con ping.
3. **Modo simulación** y enviar tramas de PC1 a PC7, PC0 a PC9, Server0 a Server1 y Laptop0 a Laptop1:
   - La primera trama se **inunda** por todos los puertos (el switch no conoce el destino).
   - Cuando el destino responde, el switch aprende su MAC. Las siguientes van solo por el puerto correcto.
   - Ver la tabla en cada switch: `show mac address-table`.
4. **Spanning tree:** conectar el switch 0 con el switch 1 formando un bucle. Se ve un enlace en ámbar (bloqueado) y otro en verde. Comando: `show spanning-tree`.
5. Unir los proyectos del equipo (si se está solo, pedir uno a otro grupo e indicar quién lo dio).

## Punto 4: VLAN
Usar `switch-vlan.txt` (puertos del proyecto: Fa0/1 y Fa0/2 para los PC, Fa0/3 trunk). Comprobar con `show vlan brief` y `show interfaces trunk`.
**Comprobado:** ping PC1→PC3 (VLAN 50, cruza el trunk) responde 4/4; ping PC1→PC0 (VLAN 55) se queda sin respuesta. Ojo: `show vlan brief` no lista el puerto trunk.
- PC1 y PC3 (systems, VLAN 50) se ven entre sí. PC2 y PC0 (others, VLAN 55) se ven entre sí.
- Un PC de systems **no** debe poder hacer ping a uno de others.
- Sin trunk, los PC de la misma VLAN en switches distintos no se ven; con trunk sí.
- Al final: desconectar, dejar los PC en los puertos D del cableado estructurado y borrar la configuración (`erase startup-config`, `delete vlan.dat`, `reload`).
