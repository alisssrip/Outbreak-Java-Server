#!/bin/bash

cd "$(dirname "$0")"

JAVA_PORTABLE_PATH="linux/jdk/path"
JAVA_EXEC="$JAVA_PORTABLE_PATH/java"
JAVAC_EXEC="$JAVA_PORTABLE_PATH/javac"
CLASSPATH="lib/gson-2.10.1.jar:lib/mysql-connector-java-5.1.49.jar:lib/weupnp-0.1.4.jar:lib/WaifUPnP.jar:bin"

if [ ! -f "$JAVA_EXEC" ]; then
    echo "[ERROR] Java not found at: $JAVA_EXEC"
    exit 1
fi

echo "------------------------------"
echo "-        BHOF1-Host          -"
echo "------------------------------"

JAVA_VER=$("$JAVA_EXEC" -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VER" -lt 17 ] 2>/dev/null; then
    echo "[ERROR] Java 17+ required. Found: $JAVA_VER"
    exit 1
fi

if [ ! -f "config.properties" ]; then
    echo "[ERROR] config.properties not found"
    exit 1
fi

echo "[..] Compiling..."
mkdir -p bin
"$JAVAC_EXEC" -d bin -cp "$CLASSPATH" bioserver/*.java
if [ $? -ne 0 ]; then echo "[ERROR] Compilation failed"; exit 1; fi

echo "[..] Starting BHOF1-Host..."
echo ""
"$JAVA_EXEC" -cp "$CLASSPATH" bioserver.ServerMainSlim
