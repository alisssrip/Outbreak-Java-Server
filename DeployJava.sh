#!/bin/bash

# --- Configuración ---
CARPETA_LOCAL="./"                              # Carpeta en tu Arch que quieres enviar (ej. "./bin/" o "./")
TARGET_USER="alicia"                           # Tu usuario en Rebecca
TARGET_IP="192.168.0.104"                       # La IP de Rebecca
TARGET_DIR="/home/alicia/OutbreakServer"      # Carpeta de destino (¡recuerda la / al final!)
SSH_KEY="~/.ssh/id_ed25519_deploy"

echo "Enviando archivos a Rebecca ($TARGET_IP)..."

rsync -avz --no-o --no-g -e "ssh -i $SSH_KEY" "$CARPETA_LOCAL" "${TARGET_USER}@${TARGET_IP}:${TARGET_DIR}"

echo "¡Archivos transferidos con éxito! 🚀"
