#!/bin/bash
# Crea un grupo si todavia no existe

read -p "Nombre del grupo: " nombre

if getent group "$nombre" > /dev/null; then
  echo "Ese grupo ya existe"
else
  groupadd "$nombre"
  echo "Grupo $nombre creado"
fi
