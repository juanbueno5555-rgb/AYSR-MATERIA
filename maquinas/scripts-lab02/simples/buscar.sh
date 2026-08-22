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
