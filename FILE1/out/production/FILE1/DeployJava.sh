#!/bin/bash

# 1. Borramos la carpeta bin local para no dejar rastros del Java 26
rm -rf bin/
mkdir bin/

# 2. Compilamos forzando la compatibilidad con Java 17 (versión 61.0)
javac --release 17 -cp "lib/gson-2.10.1.jar" -d bin bioserver/*.java

# 3. Borramos la carpeta bin en Rebecca para que no queden fantasmas viejos
ssh alicia@192.168.0.104 "rm -rf /home/alicia/OutbreakServer/FILE1/bin/*"

# 4. Enviamos los archivos recién salidos del horno
rsync -avz --no-o --no-g -e "ssh" ./bin/ alicia@192.168.0.104:/home/alicia/OutbreakServer/FILE1/bin/
