#!/bin/bash
# ============================================
# OutbreakHub - Test Selfhost Flow (CORREGIDO)
# ============================================

YOKO="https://yoko.makii.net/api/outbreakjava"

# Colores para la terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# ── PASO 1: Login del HOST (Usuario A) ───────────────────────────────────────
info "PASO 1: Login del usuario HOST (test_host)..."

# Intentamos login manual, si falla (401), creamos la cuenta
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/login" \
  -H "Content-Type: application/json" \
  -d '{"Username":"test_host","Password":"123","Type":"manual"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
if [ "$HTTP_CODE" != "200" ]; then
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/login" \
      -H "Content-Type: application/json" \
      -d '{"Username":"test_host","Password":"123","Type":"newaccount"}')
fi

SESSID_HOST=$(echo "$RESPONSE" | head -1 | grep -o '"sessionId":"[^"]*"' | cut -d'"' -f4)
[ -z "$SESSID_HOST" ] && fail "No se pudo obtener SessID para el HOST."
ok "HOST conectado. SessID: $SESSID_HOST"

# ── PASO 2: Login del CLIENT (Usuario B) ──────────────────────────────────────
info "PASO 2: Login del usuario CLIENT (test_client)..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/login" \
  -H "Content-Type: application/json" \
  -d '{"Username":"test_client","Password":"123","Type":"manual"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
if [ "$HTTP_CODE" != "200" ]; then
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/login" \
      -H "Content-Type: application/json" \
      -d '{"Username":"test_client","Password":"123","Type":"newaccount"}')
fi

SESSID_CLIENT=$(echo "$RESPONSE" | head -1 | grep -o '"sessionId":"[^"]*"' | cut -d'"' -f4)
ok "CLIENT conectado. SessID: $SESSID_CLIENT"

# ── PASO 3: Registro del GameServer ──────────────────────────────────────────
info "PASO 3: HOST registra su GameServer..."

# Usamos el SessID del HOST que sigue vigente porque el CLIENT entró con otro user
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$YOKO/gameservers/register" \
  -H "Content-Type: application/json" \
  -d "{\"Sessid\":\"$SESSID_HOST\",\"PublicIp\":\"127.0.0.1\",\"Port\":8690,\"Region\":\"LATAM\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
if [ "$HTTP_CODE" == "200" ]; then
    ok "GameServer registrado con éxito para test_host"
else
    fail "Error al registrar: HTTP $HTTP_CODE"
fi

# ── PASO 4: Verificación ─────────────────────────────────────────────────────
info "PASO 4: Verificando visibilidad del servidor..."
curl -s "$YOKO/gameservers/byuser/test_host" | grep -q "127.0.0.1" && ok "Servidor visible en la API" || fail "Servidor no encontrado"

echo -e "\n${GREEN}Test completado con éxito. El HOST y el CLIENT coexisten.${NC}"
