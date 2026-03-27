@echo off
echo Compilando servidor Outbreak...

REM Crea carpeta bin si no existe
if not exist bin mkdir bin

REM Compila todos los .java en bioserver/ y los pone en bin/
javac -d bin -cp "lib\mysql-connector-5.1.49.jar" bioserver\*.java

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Error de compilación.
    pause
    exit /b
)

echo ✅ Compilación exitosa.
pause