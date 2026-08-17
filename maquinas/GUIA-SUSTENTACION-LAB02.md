# Guía de Sustentación — VI y SAMBA (Lab 02)

> Chuleta para defender el lab en la sustentación: cada comando desglosado
> parámetro por parámetro, con la lógica de por qué funciona así.
> Estudiá la columna "Cómo explicarlo" y vas a poder responder cualquier pregunta.

---

# PARTE 1 — EDITOR VI

## 1. Estructura mental (lo más importante)

VI tiene **3 modos**. Si el profe pregunta "¿por qué no escribo directo?":

| Modo | Sirve para | Cómo se entra | Cómo se sale |
|---|---|---|---|
| **Normal** | Navegar, borrar, copiar | es el inicial | — |
| **Inserción** | Escribir texto | `i` (insertar) o `a` (append/agregar) | `Esc` |
| **Comando** | Guardar, salir, buscar, reemplazar | `:` | `Enter` o `Esc` |

**Regla de oro:** las teclas significan *verbos* (borrar, copiar, mover), no letras que se escriben.

---

## 2. Comando por comando, parámetro por parámetro

### `vi himno.txt`
- `vi` = **V**isual **I**nterface: abre el editor.
- `himno.txt` = el archivo. Si no existe, VI lo crea al guardar.
- Explicación: "vi recibe el nombre del archivo como argumento; si no lo pasás, abre un buffer vacío".

### `i` (modo inserción)
- `i` = **i**nsert → el texto que escribas entra **antes** del cursor.
- `a` = **a**ppend → entra **después** del cursor.
- Explicación: "VI separa el momento de *editar* del momento de *comandar*; `i` y `a` son las puertas al modo de escritura".

### `Esc`
- Escape del modo inserción → vuelve al modo **Normal**.
- Explicación: "si no salís del modo inserción, los comandos de navegación se escribirían como texto".

### `:w`
- `:` = abre la línea de **comando** de VI.
- `w` = **w**rite (escribir/guardar).
- Explicación: "guarda los cambios **sin salir** del editor; se usa para no perder el trabajo mientras seguís editando".

### `:1,4s/a/-/g`
Desglose de TODOS los parámetros:
| Parte | Significado |
|---|---|
| `1,4` | **Rango de líneas**: de la 1 a la 4 (el primer párrafo). Sin rango, aplica solo a la línea actual |
| `s` | **s**ubstitute = sustituir/reemplazar |
| `/a/` | el patrón a buscar (la letra `a`) |
| `-` | el texto de reemplazo (un guion) |
| `g` | **g**lobal = todas las coincidencias **de cada línea** (sin `g`, solo la primera por línea) |

> Explicación de memoria: "`1,4` limita el alcance a las líneas 1 a 4, `s` indica reemplazo, busco `a`, lo cambio por `-`, y `g` hace que se reemplacen TODAS las `a` de cada línea, no solo la primera".

### `:%s/al/##/g`
| Parte | Significado |
|---|---|
| `%` | **Todo el archivo** (equivalente a `1,$`: primera a última línea) |
| `s` | substitute |
| `/al/` | patrón: la secuencia "al" |
| `##` | reemplazo |
| `g` | global (todas las de cada línea) |

> Explicación: "el `%` es un atajo que significa todo el documento; el resto es igual al anterior, pero cambiando el patrón y el reemplazo".

### `dw`
- `d` = **d**elete (borrar).
- `w` = **w**ord (una palabra).
- Explicación: "en modo normal, `d` es el verbo 'borrar' y `w` el objeto 'palabra'. VI combina verbos+objetos: `dw` = borrar palabra, `dd` = borrar línea, `5dd` = borrar 5 líneas".

### `:13,16d`
| Parte | Significado |
|---|---|
| `13,16` | rango: líneas 13 a 16 |
| `d` | **d**elete |

> Explicación: "borra de una el bloque de líneas 13 a 16; en modo comando, `d` borra el rango completo sin mover el cursor".

### `u`
- `u` = **u**ndo (deshacer).
- Explicación: "VI guarda un historial de cambios en memoria; `u` revierte el último cambio. Es el 'Ctrl+Z' de VI. `Ctrl+r` lo rehace".

### `G`
- `G` = **G**o to end → salta a la **última** línea del archivo.
- Explicación: "mayúscula = salto al final; en minúscula `g` repetida o con número hace saltos relativos".

### `gUU`
| Parte | Significado |
|---|---|
| `gU` | **U**ppercase (mayúsculas) |
| `gUU` | la `g` repetida + `U` + `U` = aplica mayúsculas a la **línea completa actual** |

> Explicación: "con el cursor en la última línea (por el `G` anterior), `gUU` convierte toda esa línea en mayúsculas. `guu` haría lo contrario (minúsculas). `gUw` = mayúsculas en la palabra".

### `7G`
- `7` = número de línea.
- `G` = go to.
- Explicación: "un número antes de `G` salta a esa línea exacta: `7G` = a la línea 7. Es el 'ir a línea' de VI".

### `yy`
- `y` = **y**ank (copiar, "sacar una copia").
- `yy` = copia la **línea completa** donde está el cursor.
- Explicación: "yank es el verbo 'copiar' de VI; `yy` (repetido) copia la línea; `y` + movimiento copia lo que abarque el movimiento".

### `p`
- `p` = **p**aste (pegar).
- Explicación: "pega lo que copiaste (`yy`) o borraste (`dd`) DESPUÉS de la línea actual. `P` mayúscula pega ANTES".

### `/Escuela`
- `/` = abre el **modo búsqueda** hacia adelante.
- `Escuela` = el texto a buscar.
- Explicación: "VI busca hacia adelante desde el cursor; `n` = siguiente coincidencia, `N` = anterior. `?palabra` busca hacia atrás".

### `5G`
- Igual que `7G`: salta a la línea 5.
- Explicación: "`5G` = ir a la línea 5; sirve para posicionarse rápido en un archivo largo".

### `:wq`
| Parte | Significado |
|---|---|
| `w` | write (guardar) |
| `q` | **q**uit (salir) |

> Explicación: "guarda y cierra en un solo paso. Es el cierre normal de sesión en VI. `ZZ` hace lo mismo sin los dos puntos".

### `:q!`
| Parte | Significado |
|---|---|
| `q` | quit |
| `!` | fuerza (ignore los cambios sin guardar) |

> Explicación: "sale **descartando** los cambios. El `!` es el 'forzar' de VI: sin él, VI te avisa que hay cambios sin guardar y no te deja salir".

### `:1,5d`
- `1,5` = rango de líneas.
- `d` = delete.
- Explicación: "al reabrir el archivo, borra las primeras 5 líneas de una".

### `:set number`
| Parte | Significado |
|---|---|
| `set` | cambia una opción de VI en vivo |
| `number` | muestra los números de línea a la izquierda |

> Explicación: "útil para saber en qué línea estás; `:set nonumber` lo oculta".

---

## 3. Preguntas típicas de sustentación (VI)

1. **¿Por qué no puedo escribir cuando abro VI?** → Estás en modo Normal; hay que pulsar `i` para entrar a modo Inserción.
2. **¿Qué diferencia hay entre `i` y `a`?** → `i` inserta antes del cursor, `a` después (append).
3. **¿Qué significa la `g` al final de `:1,4s/a/-/g`?** → Global: reemplaza todas las coincidencias de cada línea; sin `g` solo la primera.
4. **¿Qué es `%` en `:%s/al/##/g`?** → Todo el archivo.
5. **¿Cómo deshago un cambio?** → `u` (undo) en modo normal.
6. **¿Cómo guardo sin salir? ¿Y guardando y saliendo?** → `:w` y `:wq`.
7. **¿Cómo salgo sin guardar?** → `:q!` (el `!` fuerza y descarta).
8. **¿Qué hace `5G`?** → Ir a la línea 5.
9. **¿Cómo copio una línea y la pego?** → `yy` copia, `p` pega.
10. **¿Cómo busco una palabra?** → `/palabra`, `n` para la siguiente.

---

# PARTE 2 — SAMBA / SMB

## 1. Estructura mental

| Concepto | Explicación para la sustentación |
|---|---|
| **SMB** | Protocolo de Windows para compartir archivos en red (Server Message Block) |
| **SAMBA** | Implementación libre de SMB para Unix/Linux/Solaris: hace que un sistema Unix "hable Windows" |
| **Share** | Recurso compartido: la carpeta publicada para la red |
| **Puerto 445/TCP** | El "idioma SMB" escucha ahí (Windows también usa 445) |
| **smbpasswd / tdbsam** | Base de usuarios SMB: separada de los usuarios del sistema |
| **security = user** | Modo de seguridad: cada acceso exige usuario+contraseña |

---

## 2. Comando por comando (servidor, en Solaris)

### `ps -ef | grep smbd`
| Parte | Significado |
|---|---|
| `ps` | **p**rocess **s**tatus: lista los procesos |
| `-e` | **e**very: todos los procesos (no solo los míos) |
| `-f` | **f**ull: formato completo (usuario, PID, comando) |
| `\|` | tubería: pasa la salida de un comando a otro |
| `grep smbd` | filtra las líneas que contienen "smbd" (el daemon de Samba) |

> Explicación: "con `-ef` veo todos los procesos en formato completo y filtro con grep los que son de Samba. El `smbd -D` es el daemon".

### `netstat -an | grep .445`
| Parte | Significado |
|---|---|
| `netstat` | **net**work **stat**istics: muestra conexiones y puertos |
| `-a` | **a**ll: todas las conexiones (escuchando y establecidas) |
| `-n` | **n**umeric: muestra números, sin resolver nombres (más rápido) |
| `.445` | el puerto 445 (SMB). El `.` es comodín de cualquier dirección |

> Explicación: "el puerto 445 es la puerta de SMB; `LISTEN` significa que el servidor está esperando clientes, `ESTABLISHED` que hay alguien conectado".

### `testparm`
- `testparm` = **test pa**ra**m**eters: valida la sintaxis de `/etc/samba/smb.conf` y muestra la configuración efectiva.
- Explicación: "si el archivo de configuración tiene un error, testparm lo detecta antes de reiniciar el servicio".

### `cat /etc/samba/smb.conf`
| Parte | Significado |
|---|---|
| `cat` | muestra el contenido del archivo |
| `/etc/samba/smb.conf` | el archivo de configuración de Samba (directorio `/etc`, paquete `samba`) |

> Explicación: "ahí están las secciones `[global]` (opciones del servidor) y `[compartido]` (cada share)".

### `smbpasswd -a claudia`
| Parte | Significado |
|---|---|
| `smbpasswd` | herramienta de contraseñas SMB de Samba |
| `-a` | **a**dd: agrega un usuario nuevo a la base SMB |
| `claudia` | el nombre del usuario (debe existir como usuario Unix) |

> Explicación: "la contraseña SMB es INDEPENDIENTE de la del sistema: `smbpasswd -a` crea la cuenta SMB; después pide la nueva contraseña dos veces".

### `smbpasswd -x claudia`
- `-x` = delete: elimina el usuario de la base SMB (no lo borra del sistema).
- Explicación: "`-a` agrega, `-x` elimina, y sin opción cambia la contraseña".

### `pdbedit -L`
| Parte | Significado |
|---|---|
| `pdbedit` | **p**assword **d**ata**b**ase **edit**: administra la base de usuarios SMB |
| `-L` | **L**ist: lista los usuarios registrados |

> Explicación: "muestra los usuarios SMB con su uid Unix y descripción; así verifico quién puede conectarse".

### `/usr/sbin/smbd -D`
| Parte | Significado |
|---|---|
| `/usr/sbin/smbd` | el binario del daemon (servidor) de Samba |
| `-D` | **D**aemon: corre en segundo plano sin terminal |

> Explicación: "el `-D` lo desprende de la terminal para que siga sirviendo aunque cierre la sesión".

---

## 3. Comando por comando (cliente)

### `smbclient -L //10.2.78.75 -U claudia`
| Parte | Significado |
|---|---|
| `smbclient` | el cliente SMB de línea de comandos |
| `-L` | **L**ist: enumera los shares que ofrece el servidor |
| `//10.2.78.75` | el servidor (notación `//IP`) |
| `-U claudia` | **U**ser: el usuario con el que me conecto |

> Explicación: "con `-L` pido el 'menú' de recursos compartidos del servidor, como un `dir` a la red".

### `smbclient //10.2.78.75/compartido -U claudia -c 'put x; get y'`
| Parte | Significado |
|---|---|
| `//10.2.78.75/compartido` | servidor + nombre del share (`compartido`) |
| `-U claudia` | usuario |
| `-c '...'` | **c**ommand: ejecuta comandos sin entrar a la sesión interactiva (`put` sube, `get` baja) |

> Explicación: "sin `-c` entro a una consola interactiva donde puedo usar `ls`, `put`, `get`, `mkdir`; con `-c` ejecuto todo de una".

### `net use \\10.2.78.75\compartido /user:claudia claudia123`
| Parte | Significado |
|---|---|
| `net use` | comando de Windows para conectar unidades de red |
| `\\10.2.78.75\compartido` | ruta UNC del share (Windows usa `\\` y `\`) |
| `/user:claudia` | usuario con el que autentico |
| `claudia123` | contraseña (en línea, para scripts) |

> Explicación: "esto es lo que hace un usuario de Windows al 'mapear una unidad de red'; Samba lo atiende igual que un Windows real".

### `smbstatus`
- Muestra las **sesiones activas**: quién está conectado, desde qué IP, con qué versión de SMB y qué share usa.
- Explicación: "del lado del servidor, verifico quién está conectado: usuario, máquina, protocolo y firma de cifrado".

---

## 4. Configuración (`/etc/samba/smb.conf`) — parámetro por parámetro

### `[global]`
| Parámetro | Significado |
|---|---|
| `workgroup = WORKGROUP` | grupo de trabajo estilo Windows al que se anuncia el servidor (como un "equipo de oficina") |
| `server string = ...` | descripción que ven los clientes al enumerar |
| `security = user` | cada conexión exige usuario+contraseña (nada anónimo) |
| `passdb backend = tdbsam` | dónde guarda las contraseñas SMB: base de datos local (tdb) |
| `map to guest = Bad User` | si un usuario no existe, NO lo convierte en invitado (más seguro) |
| `server min/max protocol` | versiones de SMB aceptadas (SMB2/SMB3, más seguras que SMB1) |
| `log file = ...` | dónde escribe los logs (uno por máquina: `log.%m`) |

### `[compartido]` (el share)
| Parámetro | Significado |
|---|---|
| `comment` | descripción visible del recurso |
| `path = /export/compartido` | la carpeta REAL del disco que se comparte |
| `browseable = yes` | aparece al enumerar (si fuera `no`, hay que saber el nombre para entrar) |
| `writable = yes` | se puede escribir (si `no` = solo lectura) |
| `valid users = claudia admin` | lista blanca: SOLO estos usuarios pueden entrar |
| `create mask = 0660` | permisos de los archivos nuevos: dueño y grupo rw, otros nada |
| `directory mask = 0770` | permisos de las carpetas nuevas: dueño y grupo rwx, otros nada |

> Los `mask` se leen como octal: `6`=rw (lectura+escritura), `7`=rwx (más ejecución), `0`=sin permisos. El primer dígito = dueño, segundo = grupo, tercero = otros.

---

## 5. Preguntas típicas de sustentación (SAMBA)

1. **¿Qué es Samba?** → Implementación libre del protocolo SMB para que sistemas Unix compartan archivos con Windows.
2. **¿Qué es un share?** → Una carpeta publicada en la red (path + permisos + usuarios).
3. **¿En qué puerto escucha SMB?** → 445/TCP.
4. **¿Por qué `smbpasswd -a`?** → Porque los usuarios SMB tienen su propia contraseña, separada de la del sistema.
5. **¿Qué significa `security = user`?** → Autenticación obligatoria por usuario; sin credenciales no se accede.
6. **¿Qué hace `valid users`?** → Restringe el share solo a esos usuarios.
7. **¿Para qué sirve `testparm`?** → Validar la configuración antes de reiniciar el servicio.
8. **¿Cómo verifico quién está conectado?** → `smbstatus`.
9. **¿Cómo conecto desde Windows?** → `net use \\IP\share /user:usuario password`.
10. **¿Qué es un mask 0770?** → El dueño y el grupo tienen permisos completos; los demás, ninguno.
