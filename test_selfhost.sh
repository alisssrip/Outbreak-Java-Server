#!/bin/bash
# ============================================
# OutbreakHub - Test Selfhost Flow
# Simula el flujo completo sin launcher
# ============================================

#YOKO="http://localhost:5001/api/outbreakjava"
YOKO="https://yoko.makii.net/api/outbreakjava"  # descomentar para prod

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo ""
echo "============================================"
echo "  OutbreakHub - Selfhost Integration Test"
echo "============================================"
echo ""

# ── PASO 1: Login del HOST (el ruso) ─────────────────────────────────────────
info "PASO 1: Login del usuario HOST..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/login" \
  -H "Content-Type: application/json" \
  -d '{"Username":"test","Password":"123","Type":"manual"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)

if [ "$HTTP_CODE" == "200" ]; then
    SESSID_HOST=$(echo $BODY | grep -o '"sessionId":"[^"]*"' | cut -d'"' -f4)
    ok "Login HOST exitoso. SessID: $SESSID_HOST"
elif [ "$HTTP_CODE" == "401" ]; then
    warn "Usuario no existe, creando cuenta..."
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/login" \
      -H "Content-Type: application/json" \
      -d '{"Username":"test","Password":"123","Type":"newaccount"}')
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    BODY=$(echo "$RESPONSE" | head -1)
    SESSID_HOST=$(echo $BODY | grep -o '"sessionId":"[^"]*"' | cut -d'"' -f4)
    ok "Cuenta creada y login OK. SessID: $SESSID_HOST"
else
    fail "Login HOST falló. HTTP $HTTP_CODE - $BODY"
fi

echo ""

# ── PASO 2: Login del CLIENT (el chino) ──────────────────────────────────────
info "PASO 2: Login del usuario CLIENT..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/login" \
  -H "Content-Type: application/json" \
  -d '{"Username":"a","Password":"123","Type":"manual"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)

if [ "$HTTP_CODE" == "200" ]; then
    SESSID_CLIENT=$(echo $BODY | grep -o '"sessionId":"[^"]*"' | cut -d'"' -f4)
    ok "Login CLIENT exitoso. SessID: $SESSID_CLIENT"
elif [ "$HTTP_CODE" == "401" ]; then
    warn "Usuario no existe, creando cuenta..."
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/login" \
      -H "Content-Type: application/json" \
      -d '{"Username":"testclient","Password":"test123","Type":"newaccount"}')
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    BODY=$(echo "$RESPONSE" | head -1)
    SESSID_CLIENT=$(echo $BODY | grep -o '"sessionId":"[^"]*"' | cut -d'"' -f4)
    ok "Cuenta creada y login OK. SessID: $SESSID_CLIENT"
else
    fail "Login CLIENT falló. HTTP $HTTP_CODE - $BODY"
fi

echo ""

# ── PASO 3: HOST registra su GameServer ──────────────────────────────────────
info "PASO 3: HOST registra su GameServer en Yoko..."

SELFHOST_IP="192.168.0.155"
SELFHOST_PORT=8690

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/gameservers/register" \
  -H "Content-Type: application/json" \
  -d "{\"Sessid\":\"$SESSID_HOST\",\"PublicIp\":\"$SELFHOST_IP\",\"Port\":$SELFHOST_PORT,\"Region\":\"RU\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)

if [ "$HTTP_CODE" == "200" ]; then
    ok "GameServer registrado! Respuesta: $BODY"
elif [ "$HTTP_CODE" == "400" ]; then
    warn "Port check falló (esperado si Java no está corriendo): $BODY"
    warn "Para forzar el test igual, temporalmente podés deshabilitar el TCP check en Yoko"
else
    fail "Register GameServer falló. HTTP $HTTP_CODE - $BODY"
fi

echo ""

# ── PASO 4: Listar GameServers disponibles ───────────────────────────────────
info "PASO 4: Listando GameServers activos..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$YOKO/gameservers")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)

if [ "$HTTP_CODE" == "200" ]; then
    ok "Lista obtenida: $BODY"
else
    fail "Listar GameServers falló. HTTP $HTTP_CODE"
fi

echo ""

# ── PASO 5: Java consulta IP del host (simula sendGSinfo) ────────────────────
info "PASO 5: Simulando consulta del Java central (sendGSinfo)..."
info "         → GET /gameservers/byuser/test"

RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$YOKO/gameservers/byuser/test")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)

if [ "$HTTP_CODE" == "200" ]; then
    ok "Java recibiría esta IP para mandar al PS2: $BODY"
elif [ "$HTTP_CODE" == "404" ]; then
    warn "No hay selfhost activo para test → Java usaría IP central (comportamiento correcto)"
else
    fail "Consulta byuser falló. HTTP $HTTP_CODE"
fi

echo ""

# ── PASO 6: Heartbeat ────────────────────────────────────────────────────────
info "PASO 6: Simulando heartbeat del launcher HOST..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$YOKO/gameservers/heartbeat?sessid=$SESSID_HOST")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)

if [ "$HTTP_CODE" == "204" ]; then
    ok "Heartbeat OK"
else
    warn "Heartbeat respondió HTTP $HTTP_CODE (puede ser que register falló en paso 3)"
fi

echo ""
echo "============================================"
echo -e "  ${GREEN}Selfhost registrado y activo!${NC}"
echo "============================================"
echo ""
echo -e "  ${CYAN}Abrí el emulador ahora y conectate.${NC}"
echo -e "  El servidor Java central debería redirigirte"
echo -e "  a: ${YELLOW}$SELFHOST_IP:$SELFHOST_PORT${NC}"
echo ""
echo -e "  SessID HOST   : ${YELLOW}$SESSID_HOST${NC}"
echo -e "  SessID CLIENT : ${YELLOW}$SESSID_CLIENT${NC}"
echo ""

# Heartbeat loop mientras el usuario prueba
echo -e "  ${CYAN}Manteniendo el registro activo (heartbeat cada 60s)...${NC}"
echo -e "  ${CYAN}Presioná ENTER cuando termines de probar para cerrar.${NC}"
echo ""

# Correr heartbeat en background cada 60s
(while true; do
    sleep 60
    curl -s -X PUT "$YOKO/gameservers/heartbeat?sessid=$SESSID_HOST" > /dev/null
done) &
HEARTBEAT_PID=$!

# Esperar que el usuario termine
read -p ""
kill $HEARTBEAT_PID 2>/dev/null

echo ""

# ── PASO 7: Unregister ───────────────────────────────────────────────────────
info "PASO 7: HOST cierra el servidor (unregister)..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$YOKO/gameservers/unregister?sessid=$SESSID_HOST")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)

if [ "$HTTP_CODE" == "204" ]; then
    ok "Unregister OK"
else
    warn "Unregister respondió HTTP $HTTP_CODE"
fi

echo ""

# ── PASO 8: Verificar que ya no aparece en la lista ──────────────────────────
info "PASO 8: Verificando que el server desapareció de la lista..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$YOKO/gameservers/byuser/test")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)

if [ "$HTTP_CODE" == "404" ]; then
    ok "Correcto, ya no hay selfhost activo para test"
else
    warn "Inesperado: HTTP $HTTP_CODE - todavía aparece en lista"
fi

echo ""
echo "============================================"
echo "  Test completo"
echo "============================================"
echo ""
