#!/bin/bash

cd "$(dirname "$0")"

echo "Starting BioServer..."

javac --release 17 -cp "lib/gson-2.10.1.jar:bin" -d bin bioserver/*.java
