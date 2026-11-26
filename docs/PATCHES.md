# Patches

No source code patches were required in the vendored `g2p-bridge`, `g2p-bridge-connectors`, or `example-bank` packages for `UGX` treasury support:
- `vendor/bridge/example-bank/openg2p-example-bank-api/src/openg2p_example_bank_api/config.py` exposes `treasury_account_currency` via `EXAMPLE_BANK_TREASURY_ACCOUNT_CURRENCY`, which is set to `UGX` in `docker-compose.yml` / `.env.example`.
- `scripts/seed-demo.sh` idempotently ensures the seeded `accounts` row for `1000000001` has `account_currency = 'UGX'`.
