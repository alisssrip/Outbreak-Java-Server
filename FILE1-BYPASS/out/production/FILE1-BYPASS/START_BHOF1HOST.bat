@echo off
setlocal

set "JAVA_FOLDER=D:\Descargas\java\OpenJDK\bin"
set "JAVA_EXE=%JAVA_FOLDER%\java.exe"
set "JAVAC_EXE=%JAVA_FOLDER%\javac.exe"

set "BASE_DIR=%~dp0"

echo.
echo ------------------------------
echo -        BHOF1-Host          -
echo -  Usando JDK 17 Portable    -
echo ------------------------------

if not exist "%BASE_DIR%lib\gson-2.10.1.jar" (
    echo [ERROR] No se encuentra lib\gson-2.10.1.jar
    pause
    exit /b 1
)

echo [INFO] TE VOY A MATAR...
if not exist "%BASE_DIR%bin" mkdir "%BASE_DIR%bin"

pushd "%BASE_DIR%bioserver"

"%JAVAC_EXE%" --release 17 ^
    -cp "..;..\lib\gson-2.10.1.jar;..\lib\mysql-connector-java-5.1.49.jar" ^
    -d "..\bin" ^
    *.java

if %errorlevel% neq 0 (
    echo [ERROR] La compilacion fallo.
    popd
    pause
    exit /b 1
)
popd

echo [INFO] Iniciando BHOF1-Host...
echo.

:: TE MATARE...
"%JAVA_EXE%" -cp "lib\gson-2.10.1.jar;lib\mysql-connector-java-5.1.49.jar;bin" ^
    bioserver.ServerMainSlim

pause