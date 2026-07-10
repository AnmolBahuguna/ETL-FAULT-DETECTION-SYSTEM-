# Fraud Trail System (ETH Fraud Detection)

End-to-end **fraud investigation + fund tracing** system that connects three worlds:

1. **Bank layer (off-chain)**
   - UTR / account identifiers
   - “hold/freeze” style actions (PoC)
2. **Blockchain layer (on-chain)**
   - Ethereum wallet-to-wallet transfers
   - Optional on-chain ingestion via Moralis
3. **Exchange layer**
   - Crypto-to-fiat conversion touchpoints (mocked for demo)

The system is built for an **investigator workflow**:

- Investigator enters a seed (wallet / case id)
- Backend builds or fetches a transaction graph
- Tracer discovers money-flow paths
- UI visualizes the trail as an interactive graph
- Evidence bundle can be created (hash + signature) and (optionally) anchored to a permissioned ledger

If you want a deep-dive design walkthrough, read:

- `WHAT_WE_BUILT.md`
- `RUNBOOK_COMPLETE.md`
- `QUICK_START.md`
- `WINDOWS_SETUP.md` (Windows PowerShell workflow)

---

## What this repo contains

### Core applications

- `frontend/`
  - React Investigator UI (Ant Design + `react-force-graph-2d`)
- `backend/`
  - Fraud Trail backend API (Express) used by the UI
  - Entry: `backend/src/index.js` (port `4000`)

### Supporting services and infrastructure

- `tools/mock_bank/`
  - Mock bank API (port `4001`)
- `tools/mock_exchange/`
  - Mock exchange / LEA endpoints (port `4002`)
- `docker-compose.yml`
  - Optional local infra: Neo4j, Kafka, Zookeeper, MinIO (+ backend container)

### Optional / separate modules

- `fabric/`
  - Hyperledger Fabric chaincode + PoC integration (evidence anchoring / freeze approvals)
- `blockchain/`
  - Hardhat + Solidity local contract testing (`FraudLedger.sol`)

---

## High-level architecture

### Services and default ports

- **Frontend (React)**: `http://localhost:3000`
- **Fraud Trail Backend (Express)**: `http://localhost:4000`
- **Mock Bank**: `http://localhost:4001`
- **Mock Exchange**: `http://localhost:4002`
- **Neo4j Browser**: `http://localhost:7474` (Bolt `7687`) (optional)
- **MinIO**: `http://localhost:9000` (console `9001`) (optional)
- **Kafka**: `localhost:9092` (optional)

### Data flow (investigation trace)

1. Investigator enters a **seed** in the UI (example: `chain:0x...`).
2. Backend fetches / prepares graph data:
   - In PoC mode: uses an **in-memory graph** + auto-seeds a synthetic dataset.
   - In infra mode: stores data in **Neo4j** (graph DB).
   - Optionally: calls **Moralis** to fetch real ETH transfers and ingests them.
3. Tracer runs a **path finding** search (depth/time/min-amount filters).
4. UI renders nodes/edges as a **force-directed graph**.
5. Investigator can generate an **evidence bundle** (hash + signature) and optionally submit evidence hash to Fabric.

---

## Tech stack (as implemented in this repo)

### Frontend (`frontend/`)

- **React 18** (`react`, `react-dom`)
- **Ant Design 5** (`antd`)
- **Graph visualization** (`react-force-graph-2d`)
- **HTTP client** (`axios`)
- **Real-time client** (`socket.io-client`)
- **Build tooling**: Create React App (`react-scripts`)

### Fraud Trail Backend (`backend/src/index.js` on port `4000`)

- **Node.js + Express** (`express`, `cors`, `body-parser`)
- **Neo4j driver** (`neo4j-driver`) + **in-memory fallback graph**
- **Moralis integration** (via `axios` + `MORALIS_API_KEY`)
- **Kafka client** (`kafkajs`) (optional)
- **Object storage** (`minio`) (optional)
- **Evidence signing / hashing**
  - Node crypto / file-based keys (PoC)
- **Auth primitives (PoC)** (`jsonwebtoken`)

### Local infra (optional via Docker)

- **Neo4j 5.15 community** (with APOC enabled)
- **Kafka + Zookeeper** (Confluent images)
- **MinIO**

### Smart contract dev (optional)

- **Hardhat** + `@nomicfoundation/hardhat-toolbox`

---

## Important note: there are two different backends

This repo includes:

- **Fraud Trail Backend (main for UI + graph + tracer + evidence)**
  - `backend/src/index.js`
  - Port: `4000`
- **Blockchain Monitoring Service (separate)**
  - `backend/server.js`
  - WebSocket-based monitoring service (ports/config differ)

For the Investigator UI + tracing system, use **`backend/src/index.js`**.

---

## Prerequisites

- Node.js **18+**
- npm
- Docker + Docker Compose (recommended for Neo4j/Kafka/MinIO mode)
- Neo4j (only if running without Docker but with Neo4j)

---

## Environment configuration

1. Create `.env` in repo root:

```bash
cp .env.example .env
```

2. Minimal fields for first PoC run:

- `PORT=4000`
- `USE_MEMORY_GRAPH=true`

3. If using Neo4j:

- `NEO4J_URI=bolt://localhost:7687`
- `NEO4J_USER=neo4j`
- `NEO4J_PASSWORD=...`

4. If using Moralis for real on-chain ingestion:

- `MORALIS_API_KEY=...`

---

## Run modes

### Mode A: PoC mode (recommended first run)

This mode is fastest because it does **not** depend on Neo4j; it uses an **in-memory graph** and auto-seeds synthetic data on backend startup.

1. Install dependencies:

```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install

# Mock services
cd ../tools/mock_bank
npm install

cd ../mock_exchange
npm install
```

2. Start services (4 terminals) or use the helper script.

Manual:

```bash
# Terminal 1
cd backend
npm start

# Terminal 2
cd tools/mock_bank
npm start

# Terminal 3
cd tools/mock_exchange
npm start

# Terminal 4
cd frontend
npm start
```

3. Open UI: `http://localhost:3000`

Trace seed examples:

- `0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb`
- `chain:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb`

### Mode B: Docker infra mode (Neo4j + Kafka + MinIO)

Bring infra up:

```bash
docker compose up -d
docker compose ps
```

Notes:

- Neo4j auth in compose defaults to `neo4j/fraud-trail-password`.
- Backend container runs `npm run dev`.
- Fabric in compose is only a placeholder.

---

## Health checks

```bash
curl http://localhost:4000/health
curl http://localhost:4001/api/bank/health
curl http://localhost:4002/api/exchange/health
```

If using docker infra:

```bash
curl http://localhost:7474
curl http://localhost:9000/minio/health/live
```

---

## Key API endpoints (Fraud Trail Backend on port `4000`)

### Tracing

- `GET /api/tracer/trace?seed=chain:0x...&depth=6&hours=168&minAmt=0.01`

### Moralis (real chain data)

- `GET /api/moralis/address/:address/transfers?chain=eth`
- `POST /api/moralis/trace-from-address`

### Graph ingestion and stitching

- `POST /api/graph/ingest`
- `POST /api/graph/stitch/bank`
- `POST /api/graph/stitch/exchange`
- `GET /api/graph/debug/stats`

### Evidence / Fabric (PoC)

- `POST /api/fabric/submit-evidence`
- `POST /api/fabric/request-freeze`
- `POST /api/fabric/approve-freeze`

### Freeze + bank hold (PoC workflow)

- `POST /api/freeze/...`
- `POST /api/bank-hold/place`

---

## Demo runner (E2E)

Run:

```bash
node demo/runner.js
```

This runner executes a full PoC chain:

- bank UTR fetch
- exchange LEA query
- on-chain ingestion
- identity stitching
- path tracing
- evidence submit
- freeze request/approval
- bank hold

---

## Troubleshooting

### “No paths found” in UI

- Increase `hours` (try `168` = 7 days)
- Reduce `minAmt` (try `0.01`)
- In PoC mode, ensure `USE_MEMORY_GRAPH=true` so auto-seeding runs

### Neo4j auth issues

- Compose default: `neo4j/fraud-trail-password`
- Update `.env` to match your Neo4j password
- For first demo, use `USE_MEMORY_GRAPH=true`

### Moralis not working

- Set `MORALIS_API_KEY` in `.env`
- Without Moralis, PoC still works using the seeded synthetic dataset

---

## Security notes (production hardening)

- Do **not** commit `.env` or private keys
- PoC uses file-based RSA keys; production should use **KMS/HSM**
- Real bank/exchange integrations should use **mTLS**, strict IAM, and audit logging
- PII should be tokenized/encrypted before storing in any graph DB

---

## License

Internal/educational PoC. Validate legal/compliance requirements before production use.
