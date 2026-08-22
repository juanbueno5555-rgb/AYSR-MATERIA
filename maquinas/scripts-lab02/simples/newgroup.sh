#!/bin/bash
# newgroup.sh - Crea un grupo nuevo (version simple)

# 1. Preguntamos el nombre del grupo
echo "Que nombre le pones al grupo?"
read nombre

# 2. Si ya existe, avisamos; si no, lo creamos
if getent group "$nombre" > /dev/null; then
  echo "Ese grupo ya existe"
else
  groupadd "$nombre"
  echo "Grupo $nombre creado"
fi
