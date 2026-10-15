# GUIÓN VIDEO NSLOOKUP — LAB 03 (máximo 5:00)

**Tema:** Pruebas de funcionamiento del servicio DNS con nslookup
**Edición:** MITADES-MONÓLOGO (1 take por persona, sin bloques intercalados)
**Mitad 1:** CA | **Mitad 2:** JD
**Dónde grabar:** consola de la VM **Slackware** (usuario vagrant), en casa o la uni.
**Material de referencia para el editor:** salidas reales en `evidencias/video-nslookup-BDE.txt` y `video-nslookup-FGC.txt` (los comandos de abajo ya fueron ejecutados y verificados el 29/08).

---

## MITAD 1 — CA (0:00 – 2:30)

### Bloque A — ¿Para qué sirve nslookup? (0:00 – 0:35)
| Campo | Texto |
|---|---|
| Pantalla | Consola de Slackware, cursor limpio |
| CA | "nslookup es la herramienta de diagnóstico del DNS: sirve para consultar servidores de nombres y ver qué responde cada dominio, nombre o registro. Se puede usar interactivamente o pasándole el servidor DNS al final del comando, como vamos a ver ahora." |

### Bloque B — Probar su funcionamiento (0:35 – 1:20)
| Campo | Texto |
|---|---|
| Comando | `nslookup srv1.juan.com.it 10.2.78.74` |
| CA | "Probamos contra nuestro servidor DNS principal, Slackware en 10.2.78.74, y resolvemos srv1.juan.com.it. El servidor nos devuelve su dirección IPv4, 10.2.78.74: es un registro A dentro de la zona juan.com.it que creamos en el laboratorio." |

### Bloque C — Cambiar el DNS al de la escuela y repetir (1:20 – 2:30)
| Campo | Texto |
|---|---|
| Pantalla | **FOTO** sobreimpresa: `evidencias/foto-7c-escuela.png` (salida real tomada en la red de la uni el 29/08) — NO se graba en vivo, ya no se depende de la red de la escuela |
| CA | "Ahora cambiamos el servidor DNS al de la escuela, 10.2.65.1, y repetimos la misma consulta. La respuesta es NXDOMAIN: el servidor de la escuela no conoce nuestro dominio de prueba, porque es un dominio interno del laboratorio que solo existe en nuestros servidores. Esto demuestra por qué la empresa necesita su propio DNS: los nombres internos no están publicados en Internet. El servidor de la escuela sí resuelve dominios externos, como www.google.com y www.escuelaing.edu.co, que se ven al final de esta captura real." |

## MITAD 2 — JD (2:30 – 5:00)

### Bloque D — set type=NS (2:30 – 3:00)
| Campo | Texto |
|---|---|
| Comando | `nslookup -type=NS juan.com.it 10.2.78.74` |
| JD | "Con el tipo de registro NS consultamos los servidores de nombres autoritativos de la zona. La respuesta es dns1.juan.com.it: nuestro servidor DNS se declara a sí mismo como name server autoritativo de la zona juan.com.it." |

### Bloque E — set debug (3:00 – 3:50)
| Campo | Texto |
|---|---|
| Comando | `nslookup -debug srv1.juan.com.it 10.2.78.74` |
| JD | "Con la depuración activada, nslookup muestra el detalle interno de la respuesta: la sección QUESTIONS con la consulta enviada (tipo A y luego AAAA), y la sección ANSWERS con el registro resuelto. También vemos que pide la dirección IPv6 y la autoridad responde con el SOA de la zona, dns1.juan.com.it." |

### Bloque F — set type=A (3:50 – 4:20)
| Campo | Texto |
|---|---|
| Comando | `nslookup -type=A srv2.juan.com.it 10.2.78.74` |
| JD | "Limitamos la consulta al registro A, es decir solo IPv4. srv2.juan.com.it corresponde a 10.2.78.76, que es la dirección de Windows Server en nuestra red." |

### Bloque G — set q=MX (4:20 – 5:00)
| Campo | Texto |
|---|---|
| Comando | `nslookup -type=MX juan.com.it 10.2.78.74` |
| JD | "El tipo MX consulta los servidores de correo del dominio. La respuesta es 'No answer': la zona no tiene registros MX definidos, porque en este laboratorio no configuramos servidor de correo. Si la empresa lo tuviera, acá aparecería con su prioridad, por ejemplo mail.juan.com.it prioridad 10." |

---
**Notas de producción:** un solo take por persona; máx 5:00 total; se puede grabar el comando en pantalla antes de hablar; al final un corte simple entre mitades.