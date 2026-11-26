#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: ./scripts/status.sh

Displays container status and HTTP endpoints for Refugee-G2P-Bridge.
EOF
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

docker compose ps
echo ""
echo "Endpoints:"
echo "  Partner API:   http://localhost:${BRIDGE_API_PORT:-8395}/docs"
echo "  Example Bank:  http://localhost:${EXAMPLE_BANK_PORT:-8396}/docs"
echo "  Postgres:      localhost:${BRIDGE_POSTGRES_PORT:-5736}"
echo "  Redis:         localhost:${BRIDGE_REDIS_PORT:-6681}"
