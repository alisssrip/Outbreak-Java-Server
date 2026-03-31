#!/bin/bash
# ============================================
# BHOF1-Host - Selfhost GameServer
# Biohazard Outbreak File #1
# ============================================
# Solo arranca el GameServer (:8690)
# Sin Lobby, sin matchmaking.
# Los jugadores se loguean en el servidor
# central y el juego los redirige acá.
# ============================================

cd "$(dirname "$0")"

echo ""
echo "------------------------------"
echo "-        BHOF1-Host          -"
echo "-  Selfhost GameServer :8690 -"
echo "------------------------------"
echo ""

# Verificar Java 17+
JAVA_VER=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VER" -lt 17 ] 2>/dev/null; then
    echo "[ERROR] Se requiere Java 17 o superior."
    echo "        Versión actual: $(java -version 2>&1 | head -1)"
    exit 1
fi

# Verificar config.properties
if [ ! -f "config.properties" ]; then
    echo "[ERROR] No se encontró config.properties"
    echo "        Copiá config.example.properties y completá los datos."
    exit 1
fi

echo "[INFO] Compilando..."
mkdir -p bin

javac --release 17 \
    -cp "lib/gson-2.10.1.jar:lib/mysql-connector-java-5.1.49.jar" \
    -d bin \
    bioserver/*.java

if [ $? -ne 0 ]; then
    echo "[ERROR] Compilación fallida."
    exit 1
fi

echo "[INFO] Iniciando BHOF1-Host..."
echo ""

java -cp "lib/gson-2.10.1.jar:lib/mysql-connector-java-5.1.49.jar:bin" \
    bioserver.ServerMainSlim
