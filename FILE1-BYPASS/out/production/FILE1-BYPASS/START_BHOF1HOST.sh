#!/bin/bash
# ============================================
# BHOF1-Host - Selfhost GameServer
# ============================================

cd "$(dirname "$0")"

JAVA_PORTABLE_PATH="/home/nacho/.local/bin/jdk-17.0.12 linux/bin"
JAVA_EXEC="$JAVA_PORTABLE_PATH/java"
JAVAC_EXEC="$JAVA_PORTABLE_PATH/javac"

CLASSPATH="lib/gson-2.10.1.jar:lib/mysql-connector-java-5.1.49.jar:lib/weupnp-0.1.4.jar:lib/WaifUPnP.jar:bin"

if [ ! -f "$JAVA_EXEC" ]; then
    echo "[ERROR] No se encontró el Java portable en: $JAVA_EXEC"
    exit 1
fi

echo "------------------------------"
echo "-        BHOF1-Host          -"
echo "------------------------------"

# Verificación de Versión
JAVA_VER=$("$JAVA_EXEC" -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)

if [ "$JAVA_VER" -lt 17 ] 2>/dev/null; then
    echo "[ERROR] Se requiere Java 17+. Detectado: $JAVA_VER"
    exit 1
fi

# Verificación de archivos necesarios
if [ ! -f "config.properties" ]; then
    echo "[ERROR] No se encontró config.properties"
    exit 1
fi

echo "[INFO] Compilando código fuente..."
mkdir -p bin
"$JAVAC_EXEC" -d bin -cp "$CLASSPATH" bioserver/*.java
if [ $? -ne 0 ]; then echo "[ERROR] Error de compilación"; exit 1; fi

echo "[INFO] Iniciando BHOF1-Host..."
echo ""


"$JAVA_EXEC" -cp "$CLASSPATH" bioserver.ServerMainSlim
