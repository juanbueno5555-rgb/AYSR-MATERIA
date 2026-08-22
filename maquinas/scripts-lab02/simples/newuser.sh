#!/bin/bash
# Crea un usuario con su grupo y su carpeta home

read -p "Usuario: " usuario
read -p "Grupo: " grupo

groupadd "$grupo" 2>/dev/null

useradd -m -g "$grupo" "$usuario"

passwd "$usuario"

echo "Listo: $usuario en el grupo $grupo"
