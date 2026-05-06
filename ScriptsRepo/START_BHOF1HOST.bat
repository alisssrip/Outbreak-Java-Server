@echo off
setlocal

set "JAVA_FOLDER=winpath"
set "JAVA_EXE=%JAVA_FOLDER%\java.exe"
set "JAVAC_EXE=%JAVA_FOLDER%\javac.exe"
set "BASE_DIR=%~dp0"

echo.
echo ------------------------------
echo -        BHOF1-Host          -
echo ------------------------------

if not exist "%BASE_DIR%lib\gson-2.10.1.jar" (
    echo [ERROR] lib\gson-2.10.1.jar not found
    pause
    exit /b 1
)

if not exist "%BASE_DIR%bin" mkdir "%BASE_DIR%bin"

echo [..] Compiling...
pushd "%BASE_DIR%bioserver"
"%JAVAC_EXE%" --release 17 ^
    -cp "..;..\lib\gson-2.10.1.jar;..\lib\mysql-connector-java-5.1.49.jar" ^
    -d "..\bin" ^
    *.java
if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed
    popd
    pause
    exit /b 1
)
popd

echo [..] Starting BHOF1-Host...
echo.
"%JAVA_EXE%" -cp "lib\gson-2.10.1.jar;lib\mysql-connector-java-5.1.49.jar;bin" ^
    bioserver.ServerMainSlim
pause
