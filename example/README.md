# Hello Diamond Example

This example demonstrates how to deploy and interact with a Diamond proxy using the Crane framework.

## What You'll Learn

1. How Crane's factory infrastructure works (Create3Factory + DiamondPackageCallBackFactory)
2. How to deploy a Diamond using a DFPkg (Diamond Factory Package)
3. How to interact with the deployed Diamond via the frontend
4. How wagmi-declare contract lists enhance the UI experience

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- [Node.js](https://nodejs.org/) (v18+ recommended)
- A browser wallet (MetaMask, Rainbow, etc.)

## Quick Start (Automated)

Run the full demo pipeline with one script:

```bash
# Terminal 1: Start Anvil
anvil

# Terminal 2: Run the demo
cd example
./scripts/run-demo.sh
```

The script will:
1. Build contracts
2. Run tests
3. Deploy to Anvil
4. Bundle ABIs for the frontend
5. Print the Greeter Diamond address and next steps

## Manual Step-by-Step

### 1. Build and Test

```bash
cd example
forge build
forge test -vvv
```

All 6 tests should pass.

### 2. Start Anvil

In a separate terminal:

```bash
anvil
```

Note the first test account:
- **Address**: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`
- **Private Key**: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

### 3. Deploy Greeter Diamond

```bash
forge script script/DeployGreeter.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

Output:
```
=== Deployment Summary ===
Create3Factory:         0x...
DiamondFactory:         0x...
GreeterPackage:         0x...
GreeterDiamond:         0x5FbDB2315678afecb367f032d93F642f64180aa3  <-- Save this!
```

### 4. Bundle ABIs for Frontend

```bash
# From the example directory
./scripts/bundle-abis.sh

# Or manually:
cd ../lib/daosys_frontend
node scripts/bundle-local-abis.js --out-dir="../../example/out"
```

This bundles the compiled contract ABIs into the frontend's `public/local-abis.json`.

### 5. Start the Frontend

```bash
cd ../lib/daosys_frontend
npm install   # First time only
npm run dev
```

Open http://localhost:3000

### 6. Configure Wallet

1. **Add Anvil Network** to your wallet:
   - Network Name: `Anvil Local`
   - RPC URL: `http://127.0.0.1:8545`
   - Chain ID: `31337`
   - Currency Symbol: `ETH`

2. **Import Test Account**:
   - Private Key: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

### 7. Interact with Greeter Diamond

1. Connect wallet to the frontend
2. Enter the **GreeterDiamond address** from step 3
3. The frontend will load the ABI and show available functions:
   - `getMessage()` - Read the current greeting
   - `setMessage(string)` - Update the greeting (requires transaction)

## Understanding the Code

### Deployment Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     DeployGreeter.s.sol                         │
├─────────────────────────────────────────────────────────────────┤
│ 1. InitDevService.initEnv(deployer)                             │
│    └─> Creates Create3Factory + DiamondPackageCallBackFactory   │
│                                                                 │
│ 2. factory.deployPackage(GreeterFacetDiamondFactoryPackage)     │
│    └─> Deploys the package via CREATE3 (deterministic address)  │
│                                                                 │
│ 3. diamondFactory.deploy(greeterPkg, pkgArgs)                   │
│    └─> Creates Diamond proxy                                    │
│    └─> Calls initAccount() to set initial message               │
│    └─> Installs GreeterFacet functions                          │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Purpose |
|-----------|---------|
| `Create3Factory` | Deploys contracts with deterministic addresses |
| `DiamondPackageCallBackFactory` | Creates Diamond proxy instances |
| `GreeterFacetDiamondFactoryPackage` | Bundles GreeterFacet + initialization logic |
| `IGreeter` | Interface for getMessage/setMessage |

### Why Use This Pattern?

1. **Deterministic Addresses**: CREATE3 gives the same address across all chains
2. **Upgradeable**: Diamond proxies can add/replace facets later
3. **Modular**: Facets can be shared across multiple Diamonds
4. **Gas Efficient**: Facets are deployed once, proxies are lightweight

## Contract List Schema (Wagmi-Declare)

The `schema/greeter.contractlist.json` file provides UI metadata for the frontend:

```
┌──────────────────────────────────────────────────────────────────┐
│                    Two-Layer Architecture                        │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Contract List (wagmi-declare)     ABI (Foundry out/)            │
│  ────────────────────────────      ─────────────────             │
│  • HOW to present functions        • WHAT functions exist        │
│  • Labels, descriptions            • Function signatures         │
│  • Widget types (text, select)     • Input/output types          │
│  • Validation rules                • Used for actual calls       │
│  • Help text for users                                           │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Example: setMessage Function

**ABI (technical):**
```json
{
  "name": "setMessage",
  "inputs": [{"name": "message", "type": "string"}],
  "outputs": [{"type": "bool"}]
}
```

**Contract List (UX):**
```json
{
  "setMessage": "Update Greeting",
  "arguments": [{
    "name": "message",
    "type": "string",
    "description": "The new greeting message to store on-chain",
    "ui": {
      "widget": "text",
      "placeholder": "Enter your greeting message...",
      "validation": {
        "regex": "^.{1,256}$",
        "errorMessage": "Message must be between 1 and 256 characters"
      }
    }
  }]
}
```

The frontend uses **both**:
- ABI to encode/send the actual transaction
- Contract list to render a user-friendly form with validation

### Intentional ABI-Only Example (Greeter)

The basic Greeter example is intentionally usable *without* a contract list so it can serve as the baseline “ABI-driven UI” example.
Other examples (like Permissioned Greeter) are expected to default to contractlists when available.

### Future: Linking Contractlists via NatSpec

In the future we can link a contractlist from contract metadata (e.g. custom NatSpec tag) so the UI can auto-discover it.
Example idea:

```solidity
/// @daosys:contractlist ./schema/permissioned-greeter.contractlist.json
/// @daosys:contractlist-ipfs ipfs://<CID>
```

This would be an optional hint: UI should still fall back to ABI when unavailable.

## Next Steps

## Permissioned Greeter (Operator-Gated Writes)

The Permissioned Greeter example extends the basic Greeter by composing in access-control facets:

- `OperableGreeterFacet`: `getMessage()` (public) and `setMessage()` (restricted)
- `OperableFacet`: `isOperator()` and `setOperator()` (owner-managed operators)
- `MultiStepOwnableFacet`: ERC-8023 ownership management (owner can be transferred via a 3-step flow)

### Deploy

```bash
cd example
forge script script/DeployPermissionedGreeter.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

### Test

```bash
cd example
forge test --match-path test/PermissionedGreeter.t.sol -vvv
```

### UI (Contractlist-first)

The UI metadata for the Permissioned Greeter lives in `schema/permissioned-greeter.contractlist.json` and is intended to be used as the default UI (with ABI fallback when contractlists are missing).

- **Tutorial 02**: Learn the Repo-Target-Facet pattern by building Counter
- **Tutorial 03**: Combine multiple facets (Counter + Greeter) in one Diamond
- **Reference**: See the `reference/` directory for production-quality examples

## Counter (Phase 4)

The Counter tutorial builds a simple Diamond using the Repo → Target → Facet → DFPkg pattern.

- Contracts live in `contracts/counter/`
- Deploy script: `script/DeployCounter.s.sol`
- Tests: `test/CounterDiamond.t.sol`

### Contractlist + Custom UI (no DaoSYS frontend)

This repo includes a **separate** Counter-only UI at `counter_ui/` that renders its controls from:

- `schema/counter.contractlist.json` (generated by `wagmi-declare generate`)
- `schema/counter.abi.json` (ABI extracted from the `CounterTarget` artifact so it matches Diamond surface area)

Run it:

```bash
cd example/counter_ui
npm install
npm run dev
```

### Phase 4 Smoke Test (one command)

This script re-verifies Phase 4 end-to-end:

- `forge build` + `forge test`
- build `@daosys/wagmi-declare` (for `dist/cli.mjs`)
- regenerate + validate `schema/counter.contractlist.json`
- build the Counter UI

```bash
cd example
bash scripts/phase4_smoke.sh
```

## Troubleshooting

### "Stack too deep" errors
Make sure `viaIR = true` is set in `foundry.toml`

### Tests fail with "EvmError: Revert"
Run with `-vvvv` for full traces: `forge test -vvvv`

### Frontend can't find ABI
The ABI is bundled from the `out/` directory after compilation. Make sure you've run `forge build` first.
