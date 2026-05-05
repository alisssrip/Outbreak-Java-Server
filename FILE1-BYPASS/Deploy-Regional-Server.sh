#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

REMOTE_HOST="rebecca"
REMOTE_DIR="/root/OutbreakServerRegional"

echo "Compiling..."
rm -rf bin
mkdir -p bin
javac --release 17 -cp "lib/gson-2.10.1.jar" -d bin bioserver/*.java

echo "Deploying to $REMOTE_HOST..."
rsync -avz --delete --no-o --no-g \
    bin/ \
    "$REMOTE_HOST:${REMOTE_DIR}/bin/"

rsync -avz --no-o --no-g \
    lib/ \
    "$REMOTE_HOST:${REMOTE_DIR}/lib/"

echo "Restarting service..."
ssh "$REMOTE_HOST" "systemctl restart OutbreakServerRegional.service && systemctl status OutbreakServerRegional.service --no-pager -l"

echo "Done."
