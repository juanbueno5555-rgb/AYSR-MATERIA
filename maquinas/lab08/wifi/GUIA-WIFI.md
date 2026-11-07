# WiFi (Lab 8, puntos 5 a 8 de la parte de redes)

> Estado: guía escrita a partir del enunciado. **No se ha ejecutado**: los puntos 5 y 6 son proyectos de Packet Tracer
> que cada estudiante arma, y los puntos 7 y 8 requieren el router físico, el celular y la app WiFi Analyzer.
> Los datos que dependen del diagrama (colores, qué equipo va en qué red) están en el PDF de la guía.

## Datos de configuración (del enunciado)

### Punto 5: WiFi básico (Packet Tracer, individual)
| Dato | Valor |
|---|---|
| LAN cableada | 65.148.77.1 a 65.148.77.20, máscara 255.255.255.0 (Server0, PC1, Smartphone1, Laptop1) |
| Acceso web del router wireless | usuario `admin`, clave `admin` (desde un laptop) |
| IP del router hacia la LAN cableada | 65.148.77.200, máscara 255.255.255.0 |
| Red wireless | 192.168.0.0/24; router en 192.168.0.1 |
| DHCP de los móviles | Estudiante 1: 192.168.0.10 a .50 · Estudiante 2: .60 a .100 · Estudiante 3: .110 a .150 |
| Seguridad | WPA2-PSK con AES; SSID = nombre del estudiante; clave `SECURITY R` |
| Canal | uno específico (en Packet Tracer: 1, 6 u 11 en 2.4 GHz) |
| Access Point | SSID = "Apellido Estudiante"; clave `SECURITY AP`; equipos conectados con IP 65.148.77.100 a .120 / 255.255.255.0 |

Preguntas que hay que responder:
- **¿Qué canales se pueden configurar?** En 2.4 GHz los canales 1 a 11 (en Colombia/EE. UU.); solo 1, 6 y 11 no se pisan entre sí.
- **¿Qué dispositivos se hacen ping y por qué?** Los de la misma red ven a los de su red. Los de la red wireless 192.168.0.0/24 salen a la LAN cableada a través del router (que hace NAT), pero desde la LAN cableada no se puede iniciar conexión hacia 192.168.0.x porque esas direcciones no son visibles hacia afuera. Los equipos del Access Point están en la red 65.148.77.x, la misma de la LAN cableada, y se ven directamente. Comprobar con ping real en Packet Tracer antes de afirmarlo.

### Punto 6: LAN cableada y wireless con VLAN (Packet Tracer, individual)
| Dato | Valor |
|---|---|
| IP cableadas | Estudiante 1: 171.18.100.50 a .80 · Estudiante 2: 171.18.110.50 a .80 · Estudiante 3: 171.18.120.50 a .80; máscara 255.0.0.0 |
| Red verde (rectángulos) | SSID `Rectangle`, 192.168.0.0/24, router 192.168.0.1, mismos rangos DHCP del punto 5, WPA2-PSK/AES |
| Red morada (círculos) | SSID `Circle`, WPA2-PSK/AES, clave `Circle`, IP según el rango cableado |
| Red naranja (irregular) | SSID `Irregular`, WPA2-PSK/AES, clave `Irregular`, IP según el rango cableado |

Pasos: armar el diagrama con los marcos y colores, verificar conectividad (qué se puede y qué no), luego configurar las VLAN
por colores (ver `../switches/switch-vlan.txt`) y comprobar que cada color solo se comunica con su color. Unir los proyectos del equipo.

### Punto 7: router wireless físico (en grupo)
| Dato | Valor |
|---|---|
| SSID | `Lab8 apellido` (apellido de un integrante) |
| IP del router (lado wireless) | 192.168.0.1 |
| DHCP | 192.168.0.20 a 192.168.0.30 |
| Puerto Internet (WAN) | la IP del PC que se desconectó |
| Seguridad | WPA2-PSK con AES; clave `WiFi Seg` |
| Canal | cambiar el de fábrica; dos routers del salón no pueden usar el mismo |

Pruebas con el celular:
1. Apagar datos móviles, activar WiFi, conectarse al router y navegar.
2. Instalar una app de ping y probar equipos del diagrama y de Internet. **Anotar qué pings funcionan y cuáles no.**
   Explicación probable de los que fallan: el router hace **NAT**; los equipos de la red 192.168.0.x salen a Internet con la IP del router,
   pero un equipo de afuera no puede iniciar conexión hacia ellos.
3. WiFi Analyzer: listar las redes del salón con su canal y nivel de señal.
4. Desactivar el **beacon** en el router (opción "Enable SSID broadcast" o "Visibility" = off). El beacon es la trama que el router envía
   unas 10 veces por segundo anunciando su SSID. Sin ella la red no aparece en la lista, pero el celular se puede conectar escribiendo el SSID a mano.
   Mirar en WiFi Analyzer si sigue visible (suele seguir apareciendo como red oculta, porque el tráfico de los equipos conectados delata su existencia).

### Punto 8: redes cerca de la casa
Con WiFi Analyzer: tabla con **nombre, banda (2.4 / 5 GHz), canal y señal**. Preguntas de la guía: ¿hay redes en 2.4 GHz, 5 GHz y 60 GHz?
Lo normal en una casa es 2.4 y 5 GHz; 60 GHz (WiGig, 802.11ad) casi no aparece en celulares comunes.

## Resultados (completar en la práctica)
| Prueba | Resultado |
|---|---|
| Ping celular → equipos del diagrama | _pendiente_ |
| Ping celular → Internet | _pendiente_ |
| Redes y canales en el salón | _pendiente_ |
| Red visible con el beacon desactivado | _pendiente_ |
| Redes cerca de la casa | _pendiente_ |
