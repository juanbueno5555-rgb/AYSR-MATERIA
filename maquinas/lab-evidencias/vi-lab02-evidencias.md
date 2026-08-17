# Ejercicio VI — Lab 02, sección 6 (evidencia con salidas reales)

> Entorno: Slackware 15.0, archivo `/root/lab6/himno.txt` (16 líneas, 4 estrofas).
> Los comandos de modo comando (`:...`) se aplicaron con `ex -s`; los de modo normal con `vim -Es` (misma sintaxis que en la terminal).

## Archivo de trabajo (himno.txt, 16 líneas)
```
 1  Estudiante, maestro la conquista
 2  Sera hacer con amor nuestra labor
 3  Cultores de espiritu humanista
 4  Unidad de intelecto y corazon.
 5  Escuela de ingenio es nuestra casa
 6  Libro abierto a nuestra universidad
 7  Aqui perdura mientras todo pasa
 8  Cimiento de la fe y la integridad.
 9  Ofrecemos la mano al que tropieza
10  La hidalguia del dialogo al rival
11  Ofrecemos la duda y la certeza
12  Mediamos entre hierro y el cristal.
13  Escuela de ingenio es nuestra casa
14  Libro abierto a nuestra universidad
15  Aqui perdura mientras todo pasa
16  Cimiento de la fe y la integridad.
```

## Resultado de cada operación

### Paso 2 — `:1,4s/a/-/g` (todas las 'a' de las líneas 1-4 → '-')
```
 1  Estudi-nte, m-estro l- conquist-
 2  Ser- h-cer con -mor nuestro l-bor
 3  Cultores de espiritu hum-nist-
 4  Unid-d de intelecto y cor-zon.
```
`1,4` = rango de líneas · `s` = substitute · `a`→`-` = qué→por cuál · `g` = global (todas las del renglón).

### Paso 3 — `:%s/al/##/g` ('al' por '##' en TODO el archivo)
Se reemplazó en 3 líneas (el `%` significa "todo el archivo").

### Paso 4 — `dw` (borrar palabra bajo el cursor)
Línea 1 quedó: `, maestro la conquista` (borró "Estudiante").
`d`=delete, `w`=word → "borrar palabra".

### Paso 5 — `:13,16d` (borrar las últimas 4 líneas de una)
`13,16` = rango · `d` = delete. Elimina las líneas 13-16.

### Paso 6 — `u` (deshacer)
Tras borrar 5 líneas y ejecutar `u`, el archivo volvió a su estado anterior (las líneas 1-5 intactas). VI mantiene un historial de cambios.

### Paso 7 — `G` + `gUU` (ir al final + línea en mayúsculas)
```
16  CIMIENTO DE LA FE Y LA INTEGRIDAD.
```
`G` = ir a la última línea · `gUU` = convertir la línea actual a mayúsculas.

### Paso 8 — `7G yy yy G p` (copiar 2 líneas del 2º párrafo al final)
```
16  Aqui perdura mientras todo pasa
17  Cimiento de la fe y la integridad.
```
`7G` = a la línea 7 · `yy` = copiar línea (×2) · `G` = al final · `p` = pegar.

### Paso 9 — `/Escuela` (buscar)
`Escuela` aparece en las líneas 5 y 13. `/palabra` busca hacia adelante; `n` va a la siguiente coincidencia.

### Paso 10 — `5G` (ir a la línea 5)
Cursor en la línea 5: `Escuela de ingenio es nuestra casa`.

### Paso 12 — `:wq` (guardar y salir)
Escribe el archivo y cierra VI.

### Paso 13 — `vi himno.txt` + `:1,5d` (reabrir y borrar las primeras 5 líneas)
```
 1  Libro abierto a nuestra universidad
 2  Aqui perdura mientras todo pasa
 3  Cimiento de la fe y la integridad.
...
```

## Tabla resumen de comandos VI (para el informe)
| Modo | Comando | Qué hace |
|---|---|---|
| Normal | `i` / `a` | Insertar antes / después del cursor |
| Normal | `Esc` | Volver al modo normal desde inserción |
| Normal | `x` / `dw` | Borrar carácter / palabra |
| Normal | `dd` / `5dd` | Borrar línea / 5 líneas |
| Normal | `u` / `Ctrl+r` | Deshacer / rehacer |
| Normal | `yy` / `p` | Copiar línea / pegar |
| Normal | `G` / `5G` | Ir al final / a la línea 5 |
| Normal | `gUU` | Línea actual a MAYÚSCULAS |
| Normal | `/palabra` | Buscar palabra (`n` siguiente) |
| Comando | `:w` | Guardar sin salir |
| Comando | `:q` / `:wq` / `:q!` | Salir / guardar+y salir / salir sin guardar |
| Comando | `:%s/old/new/g` | Reemplazar en todo el archivo |
| Comando | `:1,4s/a/-/g` | Reemplazar en rango de líneas |
| Comando | `:13,16d` | Borrar rango de líneas |
| Comando | `:set number` | Mostrar números de línea |
