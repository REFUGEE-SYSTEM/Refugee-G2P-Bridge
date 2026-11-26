#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: ./scripts/seed-demo.sh

Idempotently verifies/updates the fictional UGX treasury account (1000000001)
in examplebankdb.
EOF
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "ERROR: .env not found. Run ./scripts/init-env.sh first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

ACCT="${EXAMPLE_BANK_TREASURY_ACCOUNT_NUMBER:-1000000001}"
CURR="${EXAMPLE_BANK_TREASURY_ACCOUNT_CURRENCY:-UGX}"
BAL="${EXAMPLE_BANK_TREASURY_AVAILABLE_BALANCE:-1000000000}"

docker compose exec -T postgres psql -v ON_ERROR_STOP=1 \
  -U "${BRIDGE_DB_USER:-bridgeuser}" -d "${EXAMPLE_BANK_DB_NAME:-examplebankdb}" \
  -v acct="$ACCT" -v curr="$CURR" -v bal="$BAL" <<'SQL'
UPDATE accounts
SET account_currency = :'curr',
    available_balance = GREATEST(available_balance, (:'bal')::numeric)
WHERE account_number = :'acct';
SELECT account_number, account_currency, available_balance FROM accounts WHERE account_number = :'acct';
SQL

echo "[seed-demo] Example Bank treasury account '${ACCT}' verified in ${CURR}."
