# Refugee-G2P-Bridge

Standalone OpenG2P Bridge + Example Bank Simulator (`EXAMPLE-BANK` in `UGX`) for the Refugee project.

> **Demo Notice**: All bank accounts, treasury balances (`1000000001`, `UGX`), and disbursements processed by `EXAMPLE-BANK` are **100% fictional**. No real bank, mobile wallet, or payment network is connected.

## Quick Start

1. Ensure `Refugee-SPAR` is running and seeded (`:8390`).
2. Start `Refugee-G2P-Bridge`:

```bash
./scripts/init-env.sh
./scripts/up.sh
./scripts/seed-demo.sh
./scripts/smoke-test.sh
```

## Endpoints & Ports

| Service | Host Port | URL |
|---|---|---|
| Bridge Partner API | `8395` | `http://localhost:8395/docs` |
| Example Bank Simulator API | `8396` | `http://localhost:8396/docs` |
| Postgres (`g2pbridgedb`, `examplebankdb`) | `5736` | `localhost:5736` |
| Redis | `6681` | `localhost:6681` |

## Bridge Endpoints Called by PBMS
- `POST /create_disbursement_envelopes`
- `POST /create_disbursements`
- `POST /get_disbursement_envelope_status`
- `POST /get_disbursement_batch_control`

## Operations

- `./scripts/status.sh` — container status and endpoints
- `./scripts/logs.sh [service]` — tail service logs
- `./scripts/down.sh` — stop containers (preserves volumes)
- `./scripts/reset.sh [--yes]` — stop containers and delete `refugee_bridge_*` volumes only
