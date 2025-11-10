# DaoSYS

DaoSYS is a Foundry-first Solidity workspace with Diamond/Crane-style examples, deployment scripts, and small frontend tooling used by the examples.

## What this repo contains

- `contracts/`: Solidity contracts and example building blocks.
- `test/`: Foundry tests.
- `scripts/`: Foundry scripts and helpers.
- `example/`: runnable tutorial examples (deploy + test + UI).
- `lib/`: supporting JS/TS packages used by examples (including a Next.js demo frontend and `wagmi-declare`).

## Prerequisites

- Foundry (`forge`, `anvil`, `cast`)
- Node.js (v18+ recommended)

## Install

From this folder:

```bash
npm install
```

## Build & test

```bash
forge build
forge test
```

## Examples (how to run)

The canonical per-example walkthroughs live in `example/README.md`.

### 1) Greeter Diamond (demo pipeline)

Terminal 1:

```bash
anvil
```

Terminal 2:

```bash
cd example
./scripts/run-demo.sh
```

Manual deploy (alternative):

```bash
cd example
forge script script/DeployGreeter.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

Frontend (Next.js demo):

```bash
cd example
./scripts/bundle-abis.sh

cd ../lib/daosys_frontend
npm install
npm run dev
```

### 2) Permissioned Greeter

Deploy:

```bash
cd example
forge script script/DeployPermissionedGreeter.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

Test:

```bash
cd example
forge test --match-path test/PermissionedGreeter.t.sol -vvv
```

### 3) Counter (Phase 4)

Deploy:

```bash
anvil

cd example
forge script script/DeployCounter.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

Counter UI (Vite, contractlist-driven):

```bash
cd example
bash scripts/start_counter_ui.sh
```

Stop it:

```bash
cd example
bash scripts/stop_counter_ui.sh
```

One-command verification (build + test + regenerate/validate contractlist + UI build):

```bash
cd example
bash scripts/phase4_smoke.sh
```

Notes:

- Counter UI docs (including wallet connection options) are in `example/counter_ui/README.md`.
- Example overview and deeper explanations are in `example/README.md`.
