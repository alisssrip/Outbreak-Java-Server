#!/bin/bash

cd "$(dirname "$0")"

echo "Compiling BioServer source files..."

mkdir -p bin
javac --release 17 -cp "lib/gson-2.10.1.jar" -d bin bioserver/*.java

echo "Compilation finished."
