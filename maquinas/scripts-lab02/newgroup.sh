#!/bin/bash
# ============================================================
# newgroup.sh — Laboratorio 02, ejercicio 1.4 (grupo)
# Crea un grupo con GID explicito.
# Uso: ./newgroup.sh <nombre_grupo> <gid>
# Ejemplo: ./newgroup.sh developers 1001
# ============================================================

if [ $# -ne 2 ]; then
    echo "Uso: $0 <nombre_grupo> <gid>"
    echo "Ejemplo: $0 developers 1001"
    exit 1
fi

GRUPO="$1"
GID="$2"

# Verificar que el GID no este en uso
if getent group "$GID" > /dev/null 2>&1; then
    echo "ERROR: el GID $GID ya existe en el sistema."
    exit 1
fi

groupadd -g "$GID" "$GRUPO" && echo "Grupo $GRUPO creado (GID $GID)" \
    || echo "ERROR: no se pudo crear el grupo (¿ya existe?)"
