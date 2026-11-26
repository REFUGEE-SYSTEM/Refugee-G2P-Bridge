#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: ./scripts/up.sh

Starts Refugee-G2P-Bridge (Postgres, Redis, DB migrations for g2pbridgedb and
examplebankdb, Partner API, Bridge Celery, Example Bank API & Celery).
EOF
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "[up] .env not found; running ./scripts/init-env.sh ..."
  ./scripts/init-env.sh
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

echo "[up] Starting Postgres and Redis ..."
docker compose up -d --wait postgres redis

echo "[up] Running Bridge and Example Bank DB migrations ..."
docker compose --profile bootstrap run --rm --build bridge-init
docker compose --profile bootstrap run --rm --build example-bank-init

echo "[up] Building and starting all Refugee-G2P-Bridge services ..."
docker compose up -d --build --wait

echo "[up] Refugee-G2P-Bridge is ready!"
echo "  Partner API:   http://localhost:${BRIDGE_API_PORT:-8395}/docs"
echo "  Example Bank:  http://localhost:${EXAMPLE_BANK_PORT:-8396}/docs"
