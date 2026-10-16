# Lab 6, punto 1: Simulación de routers (Packet Tracer)

Archivos generados por `generar_configs.py`: los comandos de cada integrante van a su carpeta (`D:\LAB 6\camilo\packet-tracer\` y `D:\LAB 6\juan\packet-tracer\`) y `verificacion.txt` queda en `D:\LAB 6\routers\salida\`.

Importante: `verificacion.txt` es una simulación del plan de direcciones y de las rutas hecha con Python. No sustituye la prueba real en Packet Tracer: la evidencia del laboratorio son los `ping` y `tracert` que se hagan dentro de Packet Tracer.

## Plan de direcciones

Supuesto: Student 01 es Juan y Student 02 es Camilo (igual que en el Lab 3). Si el profesor dice lo contrario, se intercambian los dos bloques de redes.

| | Camilo (Student 02) | Juan (Student 01) |
|---|---|---|
| Router0 / Router1 | `Camilo` / `Aguirre` | `Juan` / `Rangel` |
| Red 1 (Router0, PC0) | 72.0.0.0/8 | 132.18.0.0/16 |
| Red 2 (Router0, PC1) | 73.0.0.0/8 | 132.19.0.0/16 |
| Red 3 (Router1, PC2) | 74.0.0.0/8 | 132.20.0.0/16 |
| Red 4 (Router1, PC3) | 75.0.0.0/8 | 132.21.0.0/16 |
| Serial Router0 a Router1 | 20.0.0.0/8 (Router0 `.1`, Router1 `.2`) | 20.0.0.0/8 (igual) |

En cada LAN el router usa la primera dirección (`.1`) y el PC la segunda (`.2`). La guía trae un error de tipeo (`132.19.0..0/16`): se interpretó como 132.19.0.0/16.

Claves: la guía dice "Clave E / Clave C / Clave T". Se usaron literalmente `ClaveE` (modo privilegiado, `enable secret`), `ClaveC` (consola) y `ClaveT` (terminal remota, vty). Si el profesor da otras claves, se cambian en los archivos de `salida`.

## Montaje en Packet Tracer

1. Agrega 2 routers 1941 (`Router0`, `Router1`) y 4 PC (`PC0` a `PC3`) con la disposición del diagrama de la guía.
2. El 1941 no trae puerto serial: apaga el router (botón de encendido de la ventana), arrastra el módulo **HWIC-2T** a una ranura libre y enciéndelo. Debe aparecer `Serial0/0/0`.
3. Cables: cada PC con su router por cable de cobre (`FastEthernet0` del PC a `GigabitEthernet0/0` o `0/1` del router, según el plan). Entre los routers, cable serial DCE: el extremo DCE (el del relojito) va al `Serial0/0/0` de **Router0**, porque ahí se configura `clock rate`.
4. Para configurar, como pide la guía: cable de consola (azul claro) desde `RS232` de un PC al puerto `Console` del router, y en el PC: Desktop > Terminal. Cuando pregunte `Continue with configuration dialog? [yes/no]:` responde `n`.
5. Pega el contenido de `<carpeta del integrante>\packet-tracer\<integrante>-Router0-<nombre>.txt` en Router0 y el de `...-Router1-<apellido>.txt` en Router1. Si pide `Destination filename [startup-config]?`, pulsa Enter.
6. En cada PC: Desktop > IP Configuration, con los valores de `<carpeta del integrante>\packet-tracer\<integrante>-PCs.txt`.

## Pruebas que pide la guía

1. Antes de las rutas estáticas, usa los archivos `...-sin-rutas.txt` en lugar de los normales (o borra las rutas con `no ip route`). Prueba `ping` entre todos los PC y anota **cuáles funcionan y cuáles no**. Resultado esperado: solo los PC de la misma mitad (PC0 con PC1, PC2 con PC3).
2. Con las rutas estáticas (`ip route ... Serial0/0/0`, con interfaz de salida) todos los PC deben verse entre sí.
3. `tracert` desde PC0 hacia PC2 (en Desktop > Command Prompt). Esperado en el plan de Camilo: `72.0.0.1`, `20.0.0.2`, `74.0.0.2`.
4. Comprueba la configuración con `show running-config` y guárdala con `copy running-config startup-config`.
5. Opción multiusuario (conectar las dos simulaciones a través de Router1): se resuelve en la sesión con el profesor, porque depende de cómo se unan los dos Packet Tracer. Pendiente.
6. Muéstraselo al profesor.

Para regenerar los archivos: `python D:\LAB 6\routers\generar_configs.py`.
