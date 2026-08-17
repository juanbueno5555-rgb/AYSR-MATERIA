#!/bin/bash
# ============================================================
# newuser.sh — Laboratorio 02, ejercicio 1.4 (usuario)
# Automatiza la creacion de usuario + grupo + home + permisos
# del Laboratorio 01.
# Uso:
#   ./newuser.sh <usuario> <grupo> "<nombre completo>" <home> <shell> <perm_home> <perm_dir1> <perm_dir2>
# Ejemplo:
#   ./newuser.sh alice developers "Alice Developer" /home/alice /bin/bash 700 770 755
# ============================================================

if [ $# -ne 8 ]; then
    echo "Uso: $0 <usuario> <grupo> \"<nombre completo>\" <home> <shell> <perm_home> <perm_dir1> <perm_dir2>"
    echo "Ejemplo: $0 alice developers \"Alice Developer\" /home/alice /bin/bash 700 770 755"
    exit 1
fi

USER="$1"
GRUPO="$2"
NOMBRE="$3"
HOME_DIR="$4"
SHELL="$5"
P1="$6"
P2="$7"
P3="$8"

# 1) Crear el grupo si no existe
if ! getent group "$GRUPO" > /dev/null 2>&1; then
    echo "Creando grupo $GRUPO..."
    groupadd "$GRUPO"
fi

# 2) Crear el usuario con su home y shell
#    -d: home  -m: crear el home  -c: comentario (nombre)  -g: grupo  -s: shell
if id "$USER" > /dev/null 2>&1; then
    echo "ERROR: el usuario $USER ya existe."
    exit 1
fi
useradd -d "$HOME_DIR" -m -c "$NOMBRE" -g "$GRUPO" -s "$SHELL" "$USER"
echo "Usuario $USER creado (home: $HOME_DIR, grupo: $GRUPO, shell: $SHELL)"

# 3) Crear subdirectorios de trabajo y aplicar permisos
mkdir -p "$HOME_DIR/documentos" "$HOME_DIR/scripts"
chmod "$P1" "$HOME_DIR"
chmod "$P2" "$HOME_DIR/documentos"
chmod "$P3" "$HOME_DIR/scripts"

echo "Permisos aplicados: $HOME_DIR=$P1, documentos=$P2, scripts=$P3"
echo "Listo."
