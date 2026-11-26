#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: ./scripts/smoke-test.sh

Checks all 8 Refugee-G2P-Bridge containers, API health endpoints, Celery worker
pings, and runs an end-to-end 3-beneficiary disbursement flow (Envelope ->
Disbursements -> SPAR resolve -> Example Bank -> MT940 reconciliation).
Prints a PASS/FAIL table and exits non-zero on failure.
EOF
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "ERROR: .env not found." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

FAILURES=0
record() {
  local status="$1" name="$2" detail="$3"
  printf "%-6s | %-38s | %s\n" "$status" "$name" "$detail"
  if [[ "$status" == "FAIL" ]]; then
    FAILURES=$((FAILURES + 1))
  fi
}

printf "%-6s | %-38s | %s\n" "STATUS" "CHECK" "DETAIL"
printf "%-6s-+-%-38s-+-%s\n" "------" "--------------------------------------" "------------------------------"

# 1. Containers running
for svc in postgres redis bridge-partner-api bridge-celery-worker bridge-celery-beat example-bank-api example-bank-celery-worker example-bank-celery-beat; do
  cid="$(docker compose ps -q "$svc")"
  if [[ -n "$cid" && "$(docker inspect -f '{{.State.Status}}' "$cid")" == "running" ]]; then
    record PASS "container:$svc" "running"
  else
    record FAIL "container:$svc" "not running"
  fi
done

# 2. HTTP /ping & /docs
bridge_url="http://localhost:${BRIDGE_API_PORT:-8395}"
bank_url="http://localhost:${EXAMPLE_BANK_PORT:-8396}"
if curl -sf "${bridge_url}/ping" | grep -q "pong"; then
  record PASS "http:bridge-partner-api:/ping" "pong"
else
  record FAIL "http:bridge-partner-api:/ping" "ping failed"
fi
if [[ "$(curl -s -o /dev/null -w '%{http_code}' "${bridge_url}/docs")" == "200" ]]; then
  record PASS "http:bridge-partner-api:/docs" "HTTP 200"
else
  record FAIL "http:bridge-partner-api:/docs" "failed"
fi
if curl -sf "${bank_url}/ping" | grep -q "pong"; then
  record PASS "http:example-bank-api:/ping" "pong"
else
  record FAIL "http:example-bank-api:/ping" "ping failed"
fi

# 3. Celery workers ping
for worker_svc in bridge-celery-worker example-bank-celery-worker; do
  ok=0
  for _ in $(seq 1 5); do
    if docker compose exec -T "$worker_svc" celery -A main.celery_app inspect ping -t 5 >/dev/null 2>&1; then
      ok=1
      break
    fi
    sleep 2
  done
  if [[ "$ok" == "1" ]]; then
    record PASS "celery:$worker_svc" "pong"
  else
    record FAIL "celery:$worker_svc" "ping failed"
  fi
done

# 4. End-to-end disbursement flow (requires SPAR seeded with 00000000-0000-4000-8000-000000000001..3)
echo ""
echo "[smoke-test] Running end-to-end 3-beneficiary disbursement test ..."
if python3 - "$bridge_url" <<'PY'
import json
import sys
import time
import urllib.request
import uuid

bridge_url = sys.argv[1]
env_id = f"smoke-env-{uuid.uuid4().hex[:8]}"
batch_id = f"smoke-batch-{uuid.uuid4().hex[:8]}"
beneficiary_ids = [
    "00000000-0000-4000-8000-000000000001",
    "00000000-0000-4000-8000-000000000002",
    "00000000-0000-4000-8000-000000000003",
]


def post(path, body):
    req = urllib.request.Request(
        f"{bridge_url}{path}",
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode())


def header(action):
    return {
        "sender_app_mnemonic": "refugee-pbms",
        "sender_app_url": "",
        "request_id": f"req-{uuid.uuid4().hex[:8]}",
        "request_timestamp": "2026-11-26T00:00:00Z",
        "action": action,
    }


env_req = {
    "request_header": header("create_disbursement_envelopes"),
    "request_body": {
        "request_payload": [
            {
                "id": env_id,
                "benefit_program_id": 1,
                "benefit_program_mnemonic": "UG_REF_CBI",
                "benefit_program_description": "Uganda Refugee Cash-Based Intervention",
                "target_registry": "refugees",
                "benefit_code_id": 1,
                "benefit_code_mnemonic": "UGX_CASH",
                "benefit_code_description": "UGX Cash",
                "benefit_type": "CASH_DIGITAL",
                "disbursement_cycle_id": 1,
                "disbursement_frequency": "Monthly",
                "cycle_code_mnemonic": "Cycle-1",
                "number_of_beneficiaries": 3,
                "number_of_disbursements": 3,
                "total_disbursement_quantity": 300000.0,
                "measurement_unit": "UGX",
                "disbursement_schedule_date": "2026-11-26",
            }
        ]
    },
}
env_resp = post("/create_disbursement_envelopes", env_req)
print("POST /create_disbursement_envelopes ->", json.dumps(env_resp))

disb_req = {
    "request_header": header("create_disbursements"),
    "request_body": {
        "disbursement_batch_control_id": batch_id,
        "request_payload": [
            {
                "disbursement_id": f"disb-{uuid.uuid4().hex[:8]}",
                "disbursement_envelope_id": env_id,
                "beneficiary_id": bid,
                "beneficiary_name": f"Demo Refugee {i+1}",
                "disbursement_quantity": 100000.0,
                "narrative": "UGX Refugee CBI Smoke Test",
                "disbursement_cycle_id": 1,
                "disbursement_batch_control_id": batch_id,
            }
            for i, bid in enumerate(beneficiary_ids)
        ],
    },
}
disb_resp = post("/create_disbursements", disb_req)
print("POST /create_disbursements ->", json.dumps(disb_resp))

final_status = None
for attempt in range(24):
    time.sleep(5)
    status_req = {
        "request_header": header("get_disbursement_envelope_status"),
        "request_body": {"request_payload": env_id},
    }
    status_resp = post("/get_disbursement_envelope_status", status_req)
    payload = status_resp.get("response_body", {}).get("response_payload", {})
    final_status = payload
    recon = payload.get("number_of_disbursements_reconciled", 0) or 0
    fa_succ = payload.get("number_of_disbursements_fa_resolution_succ", 0) or 0
    print(f"Poll {attempt+1}: fa_succ={fa_succ}/3, reconciled={recon}/3")
    if recon >= 3:
        print("POST /get_disbursement_envelope_status ->", json.dumps(status_resp))
        break
else:
    raise AssertionError(f"Timed out waiting for reconciliation of {env_id}: {final_status}")
PY
then
  record PASS "e2e:envelope->spar->bank->mt940" "3 disbursements reconciled"
else
  record FAIL "e2e:envelope->spar->bank->mt940" "e2e disbursement check failed"
fi

echo ""
if [[ "$FAILURES" -gt 0 ]]; then
  echo "[smoke-test] FAILED (${FAILURES} check(s) failed)."
  exit 1
fi
echo "[smoke-test] All checks passed!"
