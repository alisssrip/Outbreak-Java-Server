@echo off
setlocal enabledelayedexpansion

:: ============================================
:: OutbreakHub - Test Selfhost Flow (Windows)
:: ============================================

set "YOKO=https://yoko.makii.net/api/outbreakjava"
set "SELFHOST_IP=999.99.sex"
set "SELFHOST_PORT=8690"

echo.
echo ============================================
echo   OutbreakHub - Selfhost Integration Test
echo ============================================
echo.

:: --- PASO 1: Login del HOST ---
echo [INFO] PASO 1: Login del usuario HOST...

for /f "delims=" %%i in ('curl -s -X POST "%YOKO%/login" -H "Content-Type: application/json" -d "{\"Username\":\"test\",\"Password\":\"123\",\"Type\":\"manual\"}"') do set "BODY=%%i"

:: Extracción rudimentaria de sessionId (busca el valor entre comillas después de "sessionId":)
set "SESSID_HOST=%BODY:*sessionId":"=%"
set "SESSID_HOST=%SESSID_HOST:"=%"
set "SESSID_HOST=%SESSID_HOST:,=%"
set "SESSID_HOST=%SESSID_HOST:}=%"

if not "%SESSID_HOST%"=="" (
    echo [OK] Login HOST exitoso. SessID: %SESSID_HOST%
) else (
    echo [FAIL] No se pudo obtener SessID. Body: %BODY%
    pause
    exit /b 1
)

echo.

:: --- PASO 2: Login del CLIENT ---
echo [INFO] PASO 2: Login del usuario CLIENT...

for /f "delims=" %%i in ('curl -s -X POST "%YOKO%/login" -H "Content-Type: application/json" -d "{\"Username\":\"a\",\"Password\":\"123\",\"Type\":\"manual\"}"') do set "BODY_CLIENT=%%i"

set "SESSID_CLIENT=%BODY_CLIENT:*sessionId":"=%"
set "SESSID_CLIENT=%SESSID_CLIENT:"=%"
set "SESSID_CLIENT=%SESSID_CLIENT:,=%"
set "SESSID_CLIENT=%SESSID_CLIENT:}=%"

echo [OK] Login CLIENT exitoso. SessID: %SESSID_CLIENT%
echo.

:: --- PASO 3: Register GameServer ---
echo [INFO] PASO 3: HOST registra su GameServer en Yoko...

curl -s -X POST "%YOKO%/gameservers/register" ^
  -H "Content-Type: application/json" ^
  -d "{\"Sessid\":\"%SESSID_HOST%\",\"PublicIp\":\"%SELFHOST_IP%\",\"Port\":%SELFHOST_PORT%,\"Region\":\"RU\"}"

echo.
echo [OK] Intento de registro completado.
echo.

:: --- PASO 4: Listar ---
echo [INFO] PASO 4: Listando GameServers activos...
curl -s -X GET "%YOKO%/gameservers"
echo.

:: --- PASO 6: Simulación de Heartbeat ---
echo.
echo ============================================
echo   Selfhost registrado y activo!
echo ============================================
echo.
echo [INFO] Manteniendo el registro activo. 
echo [INFO] Cierra esta ventana para detener el test.
echo.

:loop
curl -s -X PUT "%YOKO%/gameservers/heartbeat?sessid=%SESSID_HOST%" > nul
echo [%TIME%] Heartbeat enviado...
timeout /t 60 > nul
goto loop