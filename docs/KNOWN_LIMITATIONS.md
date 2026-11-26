# Known Limitations

1. **Authentication Disabled (Demo Mode)**: `G2P_BRIDGE_AUTH_ENABLED=false`, `G2P_BRIDGE_OAUTH_ENABLED=false`, and `G2P_BRIDGE_SIGNATURE_VALIDATION_ENABLED=false`. Partner API accepts unauthenticated calls from any host reaching `:8395`. Run only on a trusted local network.
2. **Mock Bank Only (`EXAMPLE-BANK`)**: Uses `openg2p-example-bank` with a fictional `UGX` treasury account (`1000000001`). No real bank or mobile money network is connected.
3. **SPAR Dependency**: FA resolution requires `Refugee-SPAR` running on `SPAR_MAPPER_PORT` (default `8390`) and seeded with matching beneficiary IDs.
