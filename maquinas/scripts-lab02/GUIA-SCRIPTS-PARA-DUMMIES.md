# Guía para Dummies — Scripts de Shell del Lab 02

> Versiones simples: `scripts-lab02/simples/` — pensadas para aprender desde cero.
> Cada script está en su versión más simple posible y cada línea está explicada.

## 0. Conceptos base (léelo una vez)

Un **script** es un archivo de texto con comandos que la terminal ejecuta uno detrás de otro, como una receta.

| Cosa | Qué es | Ejemplo |
|---|---|---|
| `#!/bin/bash` | Primera línea SIEMPRE: le dice al sistema "ejecutá esto con bash" | `#!/bin/bash` |
| `#` | Comentario: la terminal lo IGNORA. Sirve para anotar | `# esto es una nota` |
| `echo` | Imprime texto en pantalla (como un `print`) | `echo "hola"` → `hola` |
| `read` | Se detiene y espera a que ESCRIBAS algo; lo guarda en una variable | `read nombre` |
| Variable | Una cajita con nombre donde guardamos un valor; se usa con `$` | `$nombre` = lo que escribiste |
| `if` | "SI pasa esto, HACÉ aquello" | `if [ "$a" = "1" ]` |
| `case` | Un `if` con varias opciones, como un menú | `case $opcion in` |
| `||` | "O si falló lo anterior, entonces..." | `ls || echo falló` |
| `2>/dev/null` | Esconde los mensajes de ERROR (los manda a la nada) | para no ensuciar la pantalla |

---

## 1. `mi_ls.sh` — listar con menú

### Código completo (versión simple)

```bash
#!/bin/bash
# mi_ls.sh - Lista un directorio de la forma que elijas (version simple)

echo "Que directorio queres listar?"
read directorio

echo "Como lo queres ver?"
echo "1) Normal"
echo "2) Con detalle (permisos, tamano, fecha)"
echo "3) Incluyendo archivos ocultos"
read opcion

case $opcion in
  1) ls "$directorio" ;;
  2) ls -l "$directorio" ;;
  3) ls -a "$directorio" ;;
  *) echo "Esa opcion no existe" ;;
esac
```

### Bitácora línea por línea

| Línea | Código | Qué hace | Traducción humana |
|---|---|---|---|
| 1 | `#!/bin/bash` | Marca el archivo como script de bash | "esto se ejecuta con bash" |
| 2 | `# mi_ls.sh - ...` | Comentario, se ignora | nota para acordarme qué es |
| 4 | `echo "Que directorio..."` | Muestra la pregunta | "preguntá el directorio" |
| 5 | `read directorio` | Se detiene y espera; guarda lo escrito en `directorio` | "capturá la respuesta" |
| 7-10 | `echo "1) Normal"` etc. | Imprime cada opción del menú | "opción 1, 2 y 3" |
| 11 | `read opcion` | Espera y guarda el número elegido | "capturá la elección" |
| 13 | `case $opcion in` | Abre el menú: compara `$opcion` con cada caso | "según lo que eligió..." |
| 14 | `1) ls "$directorio" ;;` | Si eligió 1: lista normal. `;;` = fin del caso | "caso 1: ls simple" |
| 15 | `2) ls -l "$directorio" ;;` | Si eligió 2: lista largo (permisos, dueño, tamaño, fecha) | "caso 2: ls con detalle" |
| 16 | `3) ls -a "$directorio" ;;` | Si eligió 3: lista todo, incluyendo ocultos (empiezan con `.`) | "caso 3: ls con ocultos" |
| 17 | `*) echo "Esa opcion no existe" ;;` | `*` = cualquier otra cosa → error amable | "caso comodín: inválida" |
| 18 | `esac` | Cierra el `case` (es "case" al revés) | "fin del menú" |

### Cómo explicarlo en la sustentación (2 frases)

"El script pregunta el directorio con `echo`+`read` y, según la opción elegida, ejecuta un `ls` distinto usando `case`. Las flags del `ls` son `-l` para detalle y `-a` para incluir ocultos."

---

## 2. `buscar.sh` — búsqueda de archivos y palabras

### Código completo (versión simple)

```bash
#!/bin/bash
# buscar.sh - Busca un archivo por nombre o una palabra dentro de un archivo (version simple)

echo "Que queres buscar?"
echo "1) Un archivo por su nombre"
echo "2) Una palabra dentro de un archivo"
read opcion

if [ "$opcion" = "1" ]; then
  echo "Que nombre tiene (o parte del nombre)?"
  read nombre
  find . -name "*$nombre*" 2>/dev/null

elif [ "$opcion" = "2" ]; then
  echo "En que archivo?"
  read archivo
  echo "Que palabra?"
  read palabra
  grep -n "$palabra" "$archivo"

else
  echo "Opcion no valida"
fi
```

### Bitácora línea por línea

| Línea | Código | Qué hace | Traducción humana |
|---|---|---|---|
| 1-2 | `#!/bin/bash` + comentario | Cabecera | — |
| 4-6 | `echo` ×3 | Muestra el menú de 2 opciones | "preguntá qué busca" |
| 7 | `read opcion` | Guarda la elección | "capturá la respuesta" |
| 9 | `if [ "$opcion" = "1" ]; then` | Compara: ¿la variable opcion es igual a "1"? (los espacios dentro de `[ ]` son OBLIGATORIOS) | "si eligió 1..." |
| 10-11 | `echo` + `read nombre` | Pregunta y guarda el nombre a buscar | "¿qué nombre?" |
| 12 | `find . -name "*$nombre*"` | find busca archivos desde `.` (carpeta actual); `-name` = por nombre; los `*` son comodín ("que CONTENGA ese texto") | "buscar archivos por nombre" |
| 12 | `2>/dev/null` | Esconde los errores (carpetas sin permiso) | "no muestres errores" |
| 14 | `elif [ "$opcion" = "2" ]; then` | "Si NO era 1 pero SÍ es 2..." | "segunda opción" |
| 15-18 | `echo` + `read archivo` + `read palabra` | Pregunta en qué archivo y qué palabra | "datos de la búsqueda 2" |
| 19 | `grep -n "$palabra" "$archivo"` | grep busca texto DENTRO del archivo; `-n` = muestra el número de línea | "buscar la palabra y decir en qué línea" |
| 21 | `else` | Lo que queda: no fue 1 ni 2 | "si fue otra cosa..." |
| 22 | `echo "Opcion no valida"` | Mensaje de error amable | "avisar" |
| 23 | `fi` | Cierra el `if` ("if" al revés) | "fin del if" |

### Cómo explicarlo en la sustentación (2 frases)

"`find` busca archivos por nombre y `grep` busca texto dentro de un archivo. El script deja elegir cuál de las dos búsquedas hacer con un `if/elif/else`."

---

## 3. `revisar_logs.sh` — revisión de logs

### Código completo (versión simple)

```bash
#!/bin/bash
# revisar_logs.sh - Muestra las ultimas lineas de los logs del sistema (version simple)

echo "Cuantas lineas de cada log queres ver?"
read lineas

echo "===== syslog ====="
tail -n "$lineas" /var/log/syslog

echo "===== messages ====="
tail -n "$lineas" /var/log/messages

echo "===== secure ====="
tail -n "$lineas" /var/log/secure 2>/dev/null || echo "(el log secure no existe)"
```

### Bitácora línea por línea

| Línea | Código | Qué hace | Traducción humana |
|---|---|---|---|
| 1-2 | cabecera | — | — |
| 4 | `echo "Cuantas lineas..."` | Pregunta la cantidad | "¿cuántas líneas?" |
| 5 | `read lineas` | Guarda la cantidad | "capturá" |
| 7 | `echo "===== syslog ====="` | Título/separador para saber qué log sigue | "etiqueta" |
| 8 | `tail -n "$lineas" /var/log/syslog` | `tail` muestra el FINAL del archivo (lo más reciente); `-n` = cuántas líneas | "últimas N líneas de syslog" |
| 10-11 | `echo` + `tail ... messages` | Lo mismo con el log `messages` | "ídem messages" |
| 13 | `echo "===== secure ====="` | Etiqueta | "etiqueta" |
| 14 | `tail -n "$lineas" /var/log/secure` | Lo mismo con `secure` | "ídem secure" |
| 14 | `2>/dev/null || echo "(...)"` | Si el archivo no existe, tail falla: se esconde el error y el `||` ejecuta el aviso | "si no existe, avisar sin romper" |

### Cómo explicarlo en la sustentación (2 frases)

"Los logs viven en `/var/log/` y `tail` muestra lo más reciente, que es lo que importa para diagnóstico. El `2>/dev/null || echo` hace que el script no se rompa si un log no existe."

---

## 4. `newgroup.sh` — crear grupo

### Código completo (versión simple)

```bash
#!/bin/bash
# newgroup.sh - Crea un grupo nuevo (version simple)

echo "Que nombre le pones al grupo?"
read nombre

if getent group "$nombre" > /dev/null; then
  echo "Ese grupo ya existe"
else
  groupadd "$nombre"
  echo "Grupo $nombre creado"
fi
```

### Bitácora línea por línea

| Línea | Código | Qué hace | Traducción humana |
|---|---|---|---|
| 1-2 | cabecera | — | — |
| 4 | `echo "Que nombre..."` | Pregunta el nombre | "¿nombre del grupo?" |
| 5 | `read nombre` | Lo guarda | "capturá" |
| 7 | `if getent group "$nombre" > /dev/null; then` | `getent group` pregunta al sistema si ese grupo ya existe; `> /dev/null` esconde su respuesta (solo importa si tuvo éxito o no) | "¿ya existe el grupo?" |
| 8 | `echo "Ese grupo ya existe"` | Si existe → aviso | "sí existe: avisar" |
| 9 | `else` | Si no existe... | "si no..." |
| 10 | `groupadd "$nombre"` | `groupadd` = crear grupo | "crearlo" |
| 11 | `echo "Grupo $nombre creado"` | Confirma | "confirmar" |
| 12 | `fi` | Cierra el if | "fin" |

### Cómo explicarlo en la sustentación (2 frases)

"Antes de crear, el script valida con `getent` si el grupo ya existe para no fallar por duplicado. `groupadd` es el comando que lo crea de verdad."

---

## 5. `newuser.sh` — crear usuario

### Código completo (versión simple)

```bash
#!/bin/bash
# newuser.sh - Crea un usuario con su grupo y su home (version simple)

echo "Que nombre de usuario?"
read usuario

echo "A que grupo pertenece?"
read grupo

groupadd "$grupo" 2>/dev/null

useradd -m -g "$grupo" "$usuario"

passwd "$usuario"

echo "Listo: usuario $usuario creado en el grupo $grupo"
```

### Bitácora línea por línea

| Línea | Código | Qué hace | Traducción humana |
|---|---|---|---|
| 1-2 | cabecera | — | — |
| 4-5 | `echo` + `read usuario` | Pregunta y guarda el usuario | "¿usuario?" |
| 7-8 | `echo` + `read grupo` | Pregunta y guarda el grupo | "¿grupo?" |
| 10 | `groupadd "$grupo" 2>/dev/null` | Crea el grupo; si YA existe, el error se esconde y el script sigue (no rompe) | "asegurar que el grupo exista" |
| 12 | `useradd -m -g "$grupo" "$usuario"` | `useradd` crea el usuario; `-m` = crea su carpeta home automáticamente; `-g` = lo mete en el grupo indicado | "crear usuario con home y grupo" |
| 14 | `passwd "$usuario"` | Pide y asigna la contraseña del usuario (interactivo) | "ponerle contraseña" |
| 16 | `echo "Listo: ..."` | Confirma el resultado | "confirmar" |

### Cómo explicarlo en la sustentación (2 frases)

"El script asegura que el grupo exista con `groupadd` (tolerando el error si ya estaba), y después crea el usuario con `useradd -m -g`: `-m` hace el home y `-g` asigna el grupo primario. Al final `passwd` pide la contraseña."

---

## ¿En qué máquina se guardan?

- **Máquina real del lab: Slackware 15.0** (la VM), en `/root/scripts/` — ahí se ejecutan porque el lab pide los scripts en Unix.
- **Copia de estudio:** en el repo, carpeta `scripts-lab02/simples/` (estos archivos), para leerlos sin prender la VM.

## ¿Cómo se ejecutan?

```bash
# entrar a la carpeta
cd /root/scripts

# darle permiso de ejecución (una sola vez por script)
chmod +x mi_ls.sh

# ejecutar
./mi_ls.sh
```

> Si no le das `chmod +x`, se puede ejecutar igual con `bash mi_ls.sh`.
