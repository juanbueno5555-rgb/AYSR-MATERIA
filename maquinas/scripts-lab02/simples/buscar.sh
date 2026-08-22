#!/bin/bash
# buscar.sh - Busca un archivo por nombre o una palabra dentro de un archivo (version simple)

# 1. Preguntamos que tipo de busqueda quiere
echo "Que queres buscar?"
echo "1) Un archivo por su nombre"
echo "2) Una palabra dentro de un archivo"
read opcion

# 2. Si eligio 1, buscamos por nombre
if [ "$opcion" = "1" ]; then
  echo "Que nombre tiene (o parte del nombre)?"
  read nombre
  find . -name "*$nombre*" 2>/dev/null

# 3. Si eligio 2, buscamos la palabra dentro del archivo
elif [ "$opcion" = "2" ]; then
  echo "En que archivo?"
  read archivo
  echo "Que palabra?"
  read palabra
  grep -n "$palabra" "$archivo"

# 4. Si eligio otra cosa, avisamos
else
  echo "Opcion no valida"
fi
