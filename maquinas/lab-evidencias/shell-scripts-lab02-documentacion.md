# Shell Scripts — Lab 02, sección 5 (documentación con salidas reales)

> Entorno: Slackware 15.0. Scripts en `/root/scripts/` (copiados también a `scripts-lab02/` del repo).
> Todos fueron ejecutados y verificados el 17/08/2026.

---

## Script 1.1 — `mi_ls.sh` (menú de listado con opciones)

**Función:** lista los archivos de un directorio con menú interactivo: orden por fecha/tamaño, conteo por grupos, filtros por nombre y recursión.

**Uso:** `./mi_ls.sh` (pide el directorio y muestra el menú)

### Ejecución real — opción 5 (contar por tipo) sobre `/etc`
```
======================================
  MENU — Listar archivos de: /etc
======================================
1) Mas recientes (conteo por fecha)
2) Mas antiguos (conteo por fecha)
3) Mayor tamano (conteo por tamano)
4) Menor tamano (conteo por tamano)
5) Por tipo (archivo/directorio)
6) Filtro: empieza con...
7) Filtro: termina con...
8) Filtro: contiene...
9) Incluir subdirectorios (recursivo)
0) Salir
======================================
Directorio: /etc
--- Directorios (con ocultos):
112
--- Archivos (con ocultos):
172
```
**Resultado:** `/etc` tiene 112 directorios y 172 archivos (incluyendo ocultos).

### Ejecución real — opción 6 (filtro: empieza con "rc")
```
/etc/rc_keymaps
/etc/rc3.d
/etc/rc5.d
/etc/rc0.d
/etc/rc1.d
/etc/rc4.d
/etc/rc6.d
/etc/rc_maps.cfg
/etc/rc2.d
/etc/rc.d
```
**Resultado:** encontró los archivos de configuración de arranque (rc = run command).

### Comandos clave dentro del script
| Comando | Para qué |
|---|---|
| `ls -lat` / `ls -latr` | listar ordenado por fecha (nuevos/viejos primero) |
| `ls -laS` / `ls -laSr` | listar por tamaño (grandes/chicos primero) |
| `awk '{print $6, $7}'` | extraer mes y día (columna de fecha) |
| `sort \| uniq -c` | agrupar y contar repetidos |
| `grep "^d"` | detectar directorios en la salida de `ls -la` |
| `find -name "patrón"` | buscar por nombre (con `-maxdepth 1` = solo el directorio) |
| `wc -l` | contar líneas |

---

## Script 1.2 — `buscar.sh` (búsqueda de archivos y palabras)

**Función:** menú de búsqueda: por nombre de archivo, por palabra dentro de archivo, combinado, conteo de líneas, head/tail.

**Uso:** `./buscar.sh`

### Ejecución real — opción 1 (buscar archivos con "rc" en /etc)
```
--- Resultados:
/etc/rc_keymaps
/etc/rc3.d
/etc/rc5.d
/etc/rc0.d
/etc/rc1.d
/etc/rc4.d
/etc/rc6.d
/etc/rc_maps.cfg
/etc/rc2.d
/etc/rc.d
/etc/rc.d/rc.postfix
/etc/rc.d/rc.dovecot
/etc/rc.d/rc.icecream.conf
--- Total de ocurrencias:
```

### Ejecución real — opción 2 (buscar "dev" dentro de /etc/fstab)
```
--- Coincidencias (linea: contenido):
1:/dev/sda3   /         ext4   defaults   1  1
2:/dev/sda1   /boot     ext4   defaults   1  2
3:/dev/sda2   swap      swap   defaults   0  0
--- Total de ocurrencias:
```
**Resultado:** encontró las 3 líneas de fstab que mencionan `/dev/`, con su número de línea (gracias a `grep -n`).

### Comandos clave
| Comando | Para qué |
|---|---|
| `find dir -name "*patrón*"` | buscar por nombre parcial |
| `grep -n patrón archivo` | buscar dentro de archivo mostrando número de línea |
| `grep -c patrón archivo` | contar coincidencias |
| `wc -l archivo` | contar líneas totales |
| `head -n N` / `tail -n N` | primeras/últimas N líneas |
| `2>/dev/null` | silenciar errores de archivos sin permiso |

---

## Script 1.3 — `revisar_logs.sh` (logs del sistema)

**Función:** muestra las últimas 15 líneas de los logs `/var/log/syslog`, `/var/log/messages` y `/var/log/secure`, con filtro opcional por palabra.

**Uso:** `./revisar_logs.sh`

### Ejecución real — opción 1 (últimas 15 líneas de cada log)
```
===== /var/log/syslog =====
Aug 17 21:12:09 slackware gnome-keyring-daemon[1895]: couldn't bind to control socket: ...
Aug 17 21:12:18 slackware gnome-keyring-daemon[1912]: couldn't create socket directory: ...
...
```
Los tres archivos existen (verificados):
```
-rw-r----- 1 root root 1255029 Aug 17 21:13 /var/log/messages
-rw-r----- 1 root root  290449 Aug 17 21:13 /var/log/secure
-rw-r----- 1 root root  402441 Aug 17 21:13 /var/log/syslog
```

### Ejecución real — opción 2 (filtrar por "sshd")
```
===== /var/log/messages (filtro: sshd) =====
Aug 17 21:13:02 slackware sshd[2007]: Received disconnect from 10.0.2.2 port 55807:11: disconnected by user
Aug 17 21:13:02 slackware sshd[2007]: Disconnected from user vagrant 10.0.2.2 port 55807
Aug 17 21:13:12 slackware sshd[2025]: Accepted publickey for vagrant from 10.0.2.2 port 62151 ssh2: RSA SHA256:...
```
**Resultado:** se ven los eventos de SSH del sistema — incluyendo nuestras propias conexiones (Accepted publickey for vagrant).

### Comandos clave
| Comando | Para qué |
|---|---|
| `tail -n 15 archivo` | últimas 15 líneas |
| `grep palabra` | filtrar líneas que contienen la palabra |
| `2>/dev/null \|\| echo "(no existe)"` | tolerar logs ausentes |

---

## Script 1.4 — `newgroup.sh` y `newuser.sh` (usuarios y grupos)

### `newgroup.sh`
**Función:** crea un grupo con GID explícito, validando que no exista.

**Uso:** `./newgroup.sh <nombre_grupo> <gid>`

**Ejecución real:**
```bash
$ sudo bash newgroup.sh ventas 1099
Grupo ventas creado (GID 1099)
$ getent group ventas
ventas:x:1099:
```

**Manejo de errores (probado):**
```bash
$ sudo bash newgroup.sh ventas 1099
ERROR: el GID 1099 ya existe en el sistema.    <- evita duplicados
```

### `newuser.sh`
**Función:** automatiza la creación de usuario + grupo + home + subdirectorios + permisos (como en el Lab 01).

**Uso:** `./newuser.sh <usuario> <grupo> "<nombre completo>" <home> <shell> <perm_home> <perm_dir1> <perm_dir2>`

**Ejecución real:**
```bash
$ sudo bash newuser.sh alice developers "Alice Developer" /home/alice /bin/bash 700 770 755
Creando grupo developers...
Usuario alice creado (home: /home/alice, grupo: developers, shell: /bin/bash)
Permisos aplicados: /home/alice=700, documentos=770, scripts=755
Listo.
```

**Verificación:**
```bash
$ getent passwd alice
alice:x:1005:1004:Alice Developer:/home/alice:/bin/bash
$ sudo ls -la /home/alice/
drwx------ 4 alice developers ...  .          <- 700: solo alice entra
drwxrwx--- 2 root  root      ...  documentos <- 770: grupo puede leer/escribir
drwxr-xr-x 2 root  root      ...  scripts    <- 755: todos pueden leer/ejecutar
```

**Manejo de errores (probado):**
```bash
$ sudo bash newuser.sh alice developers "Alice" /home/alice /bin/bash 700 770 755
ERROR: el usuario alice ya existe.     <- evita duplicados
```

### Parámetros del script (desglose)
| Parámetro | Ejemplo | Significado |
|---|---|---|
| `$1` usuario | `alice` | nombre de cuenta |
| `$2` grupo | `developers` | grupo primario (se crea si falta) |
| `$3` nombre | `"Alice Developer"` | comentario GECOS (campo descriptivo) |
| `$4` home | `/home/alice` | directorio personal |
| `$5` shell | `/bin/bash` | shell de login |
| `$6` perm_home | `700` | permisos del home (solo dueño) |
| `$7` perm_dir1 | `770` | permisos de `documentos/` (dueño+grupo) |
| `$8` perm_dir2 | `755` | permisos de `scripts/` (todos leen/ejecutan) |

### Comandos clave
| Comando | Para qué |
|---|---|
| `getent group` / `getent passwd` | verificar si grupo/usuario existe |
| `groupadd -g GID grupo` | crear grupo con GID fijo |
| `useradd -d -m -c -g -s` | crear usuario: home, crear home, comentario, grupo, shell |
| `mkdir -p` | crear subdirectorios |
| `chmod 700` | aplicar permisos (6=rw, 7=rwx) |
| `id usuario` | verificar UID/GID/grupos |
