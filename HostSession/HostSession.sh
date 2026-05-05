#!/bin/bash
set -euo pipefail

YOKO_URL="https://yoko.makii.net"
CREDS_FILE="${1:-./creds}"

if [ ! -f "$CREDS_FILE" ]; then
    echo "creds file not found: $CREDS_FILE" >&2
    exit 1
fi

USERNAME=$(grep -E '^username=' "$CREDS_FILE" | cut -d= -f2-)
PASSWORD=$(grep -E '^password=' "$CREDS_FILE" | cut -d= -f2-)

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "missing username/password in $CREDS_FILE" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq not installed" >&2
    exit 1
fi

SESSION_ID=""
YOKO_TOKEN=""

cleanup() {
    if [ -z "$SESSION_ID" ]; then
        return
    fi
    echo ""
    echo "cleaning up..."
    curl -sS -X DELETE "$YOKO_URL/api/outbreakjava/sessions/$SESSION_ID" \
        -H "Authorization: Bearer $YOKO_TOKEN" >/dev/null 2>&1 || true
    curl -sS -X DELETE "$YOKO_URL/api/outbreakjava/users/$USERNAME" \
        -H "Authorization: Bearer $YOKO_TOKEN" >/dev/null 2>&1 || true
    echo "done."
}

trap cleanup EXIT HUP INT TERM

LOGIN_RESPONSE=$(curl -sS -X POST "$YOKO_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}")

REDEYE_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // empty')

if [ -z "$REDEYE_TOKEN" ]; then
    echo "login failed" >&2
    echo "$LOGIN_RESPONSE" >&2
    exit 1
fi

HUB_RESPONSE=$(curl -sS -X POST "$YOKO_URL/auth/outbreak-hub" \
    -H "Content-Type: application/json" \
    -d "{\"token\":\"$REDEYE_TOKEN\"}")

SESSION_ID=$(echo "$HUB_RESPONSE" | jq -r '.sessionId // empty')
USER_ID=$(echo "$HUB_RESPONSE" | jq -r '.userId // empty')
NICKNAME=$(echo "$HUB_RESPONSE" | jq -r '.nickname // empty')
YOKO_TOKEN=$(echo "$HUB_RESPONSE" | jq -r '.token // empty')

if [ -z "$SESSION_ID" ]; then
    echo "outbreak-hub failed" >&2
    echo "$HUB_RESPONSE" >&2
    exit 1
fi

echo "session ready"
echo "  sessionId: $SESSION_ID"
echo "  userId: $USER_ID"
echo "  username: $USERNAME"
echo "  nickname: $NICKNAME"
echo "  yokoToken: $YOKO_TOKEN"
echo ""
echo "alive. Ctrl+C to exit."

while true; do
    sleep 60
done
