#!/bin/bash
# newuser.sh - Crea un usuario con su grupo y su home (version simple)

# 1. Preguntamos los datos del usuario
echo "Que nombre de usuario?"
read usuario

echo "A que grupo pertenece?"
read grupo

# 2. Creamos el grupo si no existe (el 2>/dev/null esconde el error si ya esta)
groupadd "$grupo" 2>/dev/null

# 3. Creamos el usuario:
#    -m = crea su carpeta home automaticamente
#    -g = lo mete en el grupo que dijimos
useradd -m -g "$grupo" "$usuario"

# 4. Le ponemos contrasena (la pide en el momento)
passwd "$usuario"

echo "Listo: usuario $usuario creado en el grupo $grupo"
