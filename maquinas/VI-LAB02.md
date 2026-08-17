# VI Editor — Guía de referencia (Lab 02, sección 6)

> Material de apoyo para el ejercicio del Himno de la Escuela.
> Este archivo es de referencia; no necesariamente va al informe final.

## Los 3 modos de VI

| Modo | Qué hace | Cómo entrás |
|---|---|---|
| Normal | Navegar, copiar, borrar | `Esc` |
| Inserción | Escribir texto | `i` (insertar) / `a` (agregar) |
| Comando | Guardar, salir, buscar, reemplazar | `:` |

## Secuencia exacta del ejercicio (himno.txt)

```bash
vi himno.txt          # 1. crear/abrir el archivo
i                     #    modo inserción → escribir el himno línea por línea
Esc                   #    volver a modo normal
:w                    # 2. guardar SIN salir
:1,4s/a/-/g           # 3. todas las 'a' del 1er párrafo (líneas 1-4) → -
:%s/al/##/g           # 4. todas las "al" de todo el texto → ##
dw                    # 5. borrar una palabra (respuesta del lab)
:13,16d               # 6. borrar las últimas 4 líneas de una
u                     # 7. deshacer (undo)
G                     # 8a. ir al final
gUU                   # 8b. convertir la línea actual a MAYÚSCULAS
7G                    # 9a. ir a línea 7 (inicio 2º párrafo)
yy                    # 9b. copiar línea
yy                    # 9c. copiar la siguiente
G                     # 9d. ir al final
p                     # 9e. pegar
/Escuela              # 10. buscar "Escuela" (n = siguiente)
5G                    # 11. ir a la línea 5
:wq                   # 12. guardar y salir
vi himno.txt          # 13a. reabrir
:1,5d                 # 13b. borrar las primeras 5 líneas
:q!                   # 14. salir SIN guardar
```

## Tabla resumen de comandos VI (para el informe si hace falta)

| Modo | Comando | Qué hace |
|---|---|---|
| Normal | `i` / `a` | Insertar antes / después del cursor |
| Normal | `Esc` | Volver al modo normal |
| Normal | `x` / `dw` | Borrar carácter / palabra |
| Normal | `dd` / `5dd` | Borrar línea / 5 líneas |
| Normal | `u` / `Ctrl+r` | Deshacer / rehacer |
| Normal | `yy` / `p` | Copiar línea / pegar |
| Normal | `G` / `5G` | Ir al final / línea 5 |
| Normal | `/palabra` | Buscar palabra (n = siguiente) |
| Comando | `:w` / `:q` / `:wq` / `:q!` | Guardar / salir / guardar+salir / salir sin guardar |
| Comando | `:%s/old/new/g` | Reemplazar en todo el archivo |
| Comando | `:1,4s/a/-/g` | Reemplazar en rango de líneas |
| Comando | `:13,16d` | Borrar rango de líneas |
| Comando | `:set number` | Mostrar números de línea |
