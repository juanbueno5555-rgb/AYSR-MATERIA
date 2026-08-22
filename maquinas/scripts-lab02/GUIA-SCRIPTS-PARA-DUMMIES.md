# Scripts de Shell para Dummies — Lab 02

> Los 5 scripts en su versión MÁS simple. Cada línea explicada en criollo.
> Archivos: `scripts-lab02/simples/` (repo) y `/root/scripts/simples/` (VM Slackware).

## Mini-diccionario (lo único que necesitás saber)

| Comando | Qué hace |
|---|---|
| `#!/bin/bash` | Primera línea SIEMPRE: dice "ejecutame con bash" |
| `# texto` | Comentario: la máquina lo ignora, es para vos |
| `echo "..."` | Escribe texto en pantalla |
| `read -p "..." x` | Pregunta Y espera que escribas; guarda la respuesta en `x` |
| `$x` | "El valor que guardaste en x" |
| `if` / `then` / `else` / `fi` | "Si pasa esto... hacé esto... si no... fin" |
| `[ "$x" = "1" ]` | Compara si x es igual a "1" (los espacios importan) |
| `case` / `;;` / `esac` | Menú: según el número, hace algo distinto |
| `2>/dev/null` | Esconde los mensajes de error |
| `||` | "Si lo anterior falló, entonces..." |

---

## 1. mi_ls.sh — listar con menú

```bash
#!/bin/bash
# Muestra un directorio de 3 formas distintas

read -p "Que directorio? " dir

echo "1) Normal   2) Con detalle   3) Con ocultos"
read -p "Opcion: " op

case $op in
  1) ls "$dir" ;;
  2) ls -l "$dir" ;;
  3) ls -a "$dir" ;;
esac
```

| # | Línea | Qué hace (criollo) |
|---|---|---|
| 1 | `#!/bin/bash` | aviso de que es un script |
| 3 | `read -p "Que directorio? " dir` | pregunta y guarda la respuesta en `dir` |
| 5-6 | `echo` + `read -p "Opcion: " op` | muestra el menú y guarda la elección en `op` |
| 8 | `case $op in` | "según lo que eligió..." |
| 9 | `1) ls "$dir" ;;` | opción 1 = listado normal |
| 10 | `2) ls -l "$dir" ;;` | opción 2 = con detalle (permisos, tamaño, fecha) |
| 11 | `3) ls -a "$dir" ;;` | opción 3 = con ocultos incluidos |
| 12 | `esac` | fin del menú |

**Para sustentar:** "`read -p` pregunta y guarda; `case` elige qué `ls` ejecutar. `-l` es detalle, `-a` muestra ocultos."

---

## 2. buscar.sh — buscar archivos o palabras

```bash
#!/bin/bash
# Busca un archivo por nombre o una palabra dentro de un archivo

echo "1) Buscar archivo por nombre   2) Buscar palabra en archivo"
read -p "Opcion: " op

if [ "$op" = "1" ]; then
  read -p "Nombre (o parte): " nombre
  find . -name "*$nombre*" 2>/dev/null

elif [ "$op" = "2" ]; then
  read -p "En que archivo? " archivo
  read -p "Que palabra? " palabra
  grep -n "$palabra" "$archivo"

else
  echo "Opcion no valida"
fi
```

| # | Línea | Qué hace (criollo) |
|---|---|---|
| 4 | `echo` | muestra las 2 opciones |
| 5 | `read -p "Opcion: " op` | guarda la elección |
| 7 | `if [ "$op" = "1" ]; then` | "¿eligió 1?" |
| 8-9 | `read` + `find . -name "*$nombre*"` | pide el nombre y busca archivos que lo CONTENGAN (los `*` son "cualquier cosa") |
| 9 | `2>/dev/null` | esconde errores de carpetas sin permiso |
| 11 | `elif [ "$op" = "2" ]; then` | "¿no fue 1, pero sí 2?" |
| 12-14 | `read archivo` + `read palabra` + `grep -n` | pide archivo y palabra; grep busca la palabra DENTRO del archivo y `-n` dice en qué línea está |
| 16-17 | `else` + `echo` | si no fue ni 1 ni 2, avisa |
| 18 | `fi` | fin del if |

**Para sustentar:** "`find` busca archivos por nombre; `grep` busca texto dentro de un archivo. El `if/elif/else` elige cuál de las dos."

---

## 3. revisar_logs.sh — ver los logs

```bash
#!/bin/bash
# Muestra las ultimas 15 lineas de los 3 logs del sistema

tail -15 /var/log/syslog
echo "-----"
tail -15 /var/log/messages
echo "-----"
tail -15 /var/log/secure 2>/dev/null || echo "(no hay log secure)"
```

| # | Línea | Qué hace (criollo) |
|---|---|---|
| 4 | `tail -15 /var/log/syslog` | `tail` = muestra el FINAL del archivo (lo más nuevo); `-15` = las últimas 15 líneas |
| 5 | `echo "-----"` | separador visual |
| 6 | `tail -15 /var/log/messages` | lo mismo con el log "messages" |
| 8 | `tail -15 /var/log/secure` | lo mismo con "secure" |
| 8 | `2>/dev/null || echo "(...)"` | si ese log NO existe, no rompe: esconde el error y avisa |

**Para sustentar:** "Los logs están en `/var/log/` y `tail` muestra lo más reciente. El `||` es para no romper si falta un log."

---

## 4. newgroup.sh — crear grupo

```bash
#!/bin/bash
# Crea un grupo si todavia no existe

read -p "Nombre del grupo: " nombre

if getent group "$nombre" > /dev/null; then
  echo "Ese grupo ya existe"
else
  groupadd "$nombre"
  echo "Grupo $nombre creado"
fi
```

| # | Línea | Qué hace (criollo) |
|---|---|---|
| 4 | `read -p "Nombre del grupo: " nombre` | pregunta y guarda el nombre |
| 6 | `if getent group "$nombre" > /dev/null; then` | `getent group` le pregunta al sistema si ese grupo YA existe (`> /dev/null` esconde su respuesta: solo importa si acertó o no) |
| 7 | `echo "Ese grupo ya existe"` | si existe → avisa |
| 9-10 | `groupadd "$nombre"` + `echo` | si no existe → `groupadd` lo crea y confirma |
| 11 | `fi` | fin del if |

**Para sustentar:** "Primero valido con `getent` que no exista (para no duplicar) y después `groupadd` lo crea."

---

## 5. newuser.sh — crear usuario

```bash
#!/bin/bash
# Crea un usuario con su grupo y su carpeta home

read -p "Usuario: " usuario
read -p "Grupo: " grupo

groupadd "$grupo" 2>/dev/null

useradd -m -g "$grupo" "$usuario"

passwd "$usuario"

echo "Listo: $usuario en el grupo $grupo"
```

| # | Línea | Qué hace (criollo) |
|---|---|---|
| 4-5 | `read -p` ×2 | pregunta usuario y grupo, y los guarda |
| 7 | `groupadd "$grupo" 2>/dev/null` | crea el grupo; si ya existía, esconde el error y sigue (no rompe) |
| 9 | `useradd -m -g "$grupo" "$usuario"` | `useradd` crea el usuario; `-m` = le crea su carpeta home; `-g` = lo mete en ese grupo |
| 11 | `passwd "$usuario"` | pide la contraseña (interactivo) |
| 13 | `echo "Listo..."` | confirma |

**Para sustentar:** "`useradd -m -g`: `-m` hace el home y `-g` asigna el grupo primario. Antes aseguro el grupo con `groupadd`, y al final `passwd` pone la contraseña."

---

## Dónde están y cómo se corren

- **VM Slackware** (la del lab): `/root/scripts/`
- **Repo:** `scripts-lab02/simples/`

```bash
cd /root/scripts
chmod +x mi_ls.sh        # permiso de ejecucion (una vez por script)
./mi_ls.sh               # correr
```

> Sin `chmod +x` también corre con: `bash mi_ls.sh`

---

## 6. Comandos de Packet Tracer (CLI de routers y switches)

En PT abrís un router/switch y vas a la pestaña **CLI**. Todo arranca así:

| Comando | Qué hace (criollo) |
|---|---|
| `enable` | Entra al modo privilegiado (modo admin); el prompt cambia a `Router#` |
| `configure terminal` | Entra al modo de configuración; prompt: `Router(config)#` |
| `hostname X` | Le pone nombre al dispositivo (ej. `hostname Router0`) |
| `interface g0/0` | Entra a la configuración de un puerto; prompt: `Router(config-if)#` |
| `ip address 10.0.10.1 255.255.255.0` | Le asigna IP y máscara a la interfaz |
| `no shutdown` | PRENDE la interfaz (por defecto está apagada) |
| `clock rate 64000` | En el cable serial: el extremo DCE marca la velocidad |
| `exit` | Sale un nivel (de la interfaz a config global) |
| `end` | Sale de todo el modo config de una vez |
| `ping 10.0.20.10` | Prueba de conectividad hacia otra IP |
| `show ip interface brief` | Muestra todas las interfaces con IP y estado (Up/Down) |
| `show running-config` | Muestra la configuración actual del dispositivo |
| `write` | GUARDA la config (igual que `copy running-config startup-config`) |
| `show version` | Muestra versión de IOS, hardware y tiempo encendido |

**Modo simulación (para ver los paquetes):**
1. Clic en el botón **Simulation** (abajo a la derecha).
2. Clic en **Edit Filters** → marcar solo **ICMP** (y ARP para ver la resolución de MAC).
3. Ir a un server → **Desktop** → **Command Prompt** → `ping <IP destino>`.
4. Los eventos aparecen en la lista; clic en **Auto Capture / Play**.
5. Clic en un paquete → **PDU Information**: encapsulación capa por capa (Ethernet → IP → ICMP).

---

## 7. Comandos de VIM (el editor)

VIM tiene 3 modos: **Normal** (navegar, borrar, copiar — es el inicial), **Inserción** (escribir, se entra con `i` o `a`, se sale con `Esc`) y **Comando** (guardar/salir/buscar, se entra con `:`).

| Comando | Qué hace (criollo) |
|---|---|
| `vi archivo.txt` | Abre el editor con ese archivo |
| `i` | Modo inserción: escribís ANTES del cursor |
| `a` | Modo inserción: escribís DESPUÉS del cursor (append) |
| `Esc` | Vuelve al modo Normal |
| `x` | Borra el carácter bajo el cursor |
| `dw` | Borra una palabra (`d`=delete, `w`=word) |
| `dd` | Borra la línea entera |
| `5dd` | Borra 5 líneas |
| `u` | Deshace (undo) |
| `Ctrl+r` | Rehace (redo) |
| `yy` | Copia la línea (yank) |
| `p` | Pega lo copiado DESPUÉS de la línea actual (`P` pega antes) |
| `G` | Va a la última línea |
| `5G` | Va a la línea 5 |
| `gUU` | La línea actual a MAYÚSCULAS |
| `/palabra` | Busca hacia adelante; `n` = siguiente coincidencia |
| `:w` | Guarda sin salir (`w`=write) |
| `:q` | Sale sin guardar si no hay cambios |
| `:wq` | Guarda Y sale |
| `:q!` | Sale SIN guardar (el `!` fuerza y descarta) |
| `:1,4s/a/-/g` | Reemplaza en las líneas 1-4: `s`=substitute, `a`→`-`, `g`=todas las de cada línea |
| `:%s/al/##/g` | Reemplaza en TODO el archivo (`%` = todo el archivo) |
| `:13,16d` | Borra las líneas 13 a 16 |
| `:set number` | Muestra los números de línea |

---

## 8. Comandos de SAMBA / SMB

### Conceptos (criollo)

| Concepto | Qué es |
|---|---|
| **SMB** | Protocolo de Windows para compartir archivos en la red |
| **SAMBA** | Implementación libre de SMB para que un Unix "hable Windows" |
| **Share** | La carpeta publicada para la red |
| **Puerto 445** | Donde escucha SMB |
| **smbpasswd / tdbsam** | Usuarios SMB, con contraseña APARTE de la del sistema |

### Servidor (en Solaris)

| Comando | Qué hace (criollo) |
|---|---|
| `pkg list samba` | Confirma el paquete instalado |
| `svcadm enable svc:/network/smb/server` | Enciende el servidor SMB nativo (SMF) |
| `netstat -an \| grep .445` | Verifica que el puerto 445 esté en LISTEN |
| `smbpasswd -a claudia` | Agrega usuario a la base SMB (`-a`=add) — la contraseña SMB es INDEPENDIENTE de la del sistema |
| `pdbedit -L` | Lista los usuarios SMB registrados |
| `/usr/sbin/smbd -D` | Levanta el daemon Samba en segundo plano (`-D`=daemon) |
| `testparm` | Valida la sintaxis de `/etc/samba/smb.conf` antes de usarlo |
| `smbstatus` | Muestra quién está conectado ahora (sesiones activas) |

### Cliente (Slackware y Windows)

| Comando | Qué hace (criollo) |
|---|---|
| `smbclient -L //10.2.78.75 -U claudia` | `-L` lista los shares del servidor (el "menú") |
| `smbclient //IP/compartido -U usuario -c 'put x; get y'` | `-c` ejecuta comandos sin entrar a la consola: `put` sube, `get` baja |
| `net use \\10.2.78.75\compartido /user:claudia claudia123` | Windows: mapea el recurso (ruta UNC) |
| `dir \\10.2.78.75\compartido` | Windows: ver el contenido del share |
| `echo test > \\10.2.78.75\compartido\archivo.txt` | Windows: crear archivo dentro del share |

### Configuración clave de `/etc/samba/smb.conf`

| Parámetro | Qué hace (criollo) |
|---|---|
| `workgroup = WORKGROUP` | Grupo de trabajo estilo Windows al que se anuncia |
| `security = user` | Cada conexión exige usuario y contraseña (nada anónimo) |
| `passdb backend = tdbsam` | Las contraseñas SMB se guardan en base local |
| `valid users = claudia admin` | Lista blanca: SOLO estos usuarios entran |
| `writable = yes` | Se puede escribir en el share |
| `path = /export/compartido` | La carpeta REAL del disco que se comparte |
| `create mask = 0660` | Permisos de archivos nuevos (dueño y grupo rw, otros nada) |
| `directory mask = 0770` | Permisos de carpetas nuevas (dueño y grupo rwx, otros nada) |
