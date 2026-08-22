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
