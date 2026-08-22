#!/bin/bash
# mi_ls.sh - Lista un directorio de la forma que elijas (version simple)

# 1. Preguntamos QUE directorio quiere ver
echo "Que directorio queres listar?"
read directorio

# 2. Mostramos el menu de opciones
echo "Como lo queres ver?"
echo "1) Normal"
echo "2) Con detalle (permisos, tamano, fecha)"
echo "3) Incluyendo archivos ocultos"
read opcion

# 3. Segun la opcion, ejecutamos un ls distinto
case $opcion in
  1) ls "$directorio" ;;
  2) ls -l "$directorio" ;;
  3) ls -a "$directorio" ;;
  *) echo "Esa opcion no existe" ;;
esac
