# Architecture

`Refugee-G2P-Bridge` is a standalone Docker Compose stack (`COMPOSE_PROJECT_NAME=refugee-g2p-bridge`) with its own network (`refugee_bridge_net`) and volumes (`refugee_bridge_postgres_data`, `refugee_bridge_redis_data`).

```mermaid
flowchart LR
  PBMS["Refugee-PBMS (:8369/:8350)"] -->|"create_disbursement_envelopes / create_disbursements / status (:8395)"| BridgeAPI["bridge-partner-api (:8395)"]
  BridgeAPI --> BridgeDB[("g2pbridgedb (:5736)")]
  BridgeBeat["bridge-celery-beat + worker"] --> BridgeDB
  BridgeBeat -->|"POST /mapper/resolve (:8390)"| SPAR["Refugee-SPAR (:8390)"]
  BridgeBeat -->|"check_funds / block_funds / initiate_payment"| BankAPI["example-bank-api (:8396)"]
  BankAPI --> BankDB[("examplebankdb (:5736)")]
  BankBeat["example-bank-celery-beat + worker"] --> BankDB
  BankBeat -->|"POST /upload_mt940 (internal net)"| BridgeAPI
```
