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

- **VM Slackware** (la del lab): `/root/scripts/simples/`
- **Repo:** `scripts-lab02/simples/`

```bash
cd /root/scripts/simples
chmod +x mi_ls.sh        # permiso de ejecucion (una vez por script)
./mi_ls.sh               # correr
```

> Sin `chmod +x` también corre con: `bash mi_ls.sh`
