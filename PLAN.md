# DaoSys Sample Project Implementation Plan

## Objective

Create a sample project demonstrating how to use the composed frameworks (Crane, DaoSys Frontend, Wagmi-Declare) together as a reference for other developers.

---

## Composed Dependencies

| Framework | Purpose |
|-----------|---------|
| **Crane** | Diamond-first Solidity framework with Facet-Target-Repo pattern, CREATE3 deterministic deployments |
| **DaoSys Frontend** | Next.js web3 UI for contract interaction, auto-loads ABIs from Foundry artifacts |
| **Wagmi-Declare** | Schema-driven dynamic UI generation from contract list JSON |

---

## Proposed Architecture

```
example/
├── contracts/           # Crane-based smart contracts
│   ├── SimpleVault/     # ERC4626 vault using Crane patterns
│   │   ├── SimpleVaultRepo.sol
│   │   ├── SimpleVaultTarget.sol
│   │   └── SimpleVaultFacet.sol
│   └── deploy/          # CREATE3 deployment scripts
├── schema/              # Wagmi-declare contract lists
│   └── simple-vault.contractlist.json
├── frontend/            # DaoSys Frontend integration
│   └── (extends daosys_frontend)
└── README.md            # Tutorial walkthrough
```

---

## Implementation Options

### Option A: Minimal Counter Example
- Simple counter facet demonstrating Repo→Target→Facet
- Basic UI to increment/decrement/read
- Fastest to implement, clearest teaching example

### Option B: ERC4626 Vault Example
- More realistic DeFi use case
- Demonstrates token handling, deposit/withdraw flows
- Shows real-world wagmi-declare schema complexity

### Option C: Multi-Facet Diamond Example
- Shows Diamond Package composition
- Multiple facets working together
- Best demonstrates Crane's modularity

---

## Selected Approach

**Option B: ERC4626 Vault Example** + **Greeter-Based Examples**

We will implement two example tracks:
1. **ERC4626 Vault** - Realistic DeFi example with deposit/withdraw flows
2. **Greeter Examples** - Progressive complexity using existing Greeter components

---

## Example 1: Hello Diamond (Greeter)

**Purpose:** Simplest possible end-to-end example using existing GreeterFacet

**What it demonstrates:**
- CREATE3 deployment via GreeterFacetDiamondFactoryPackage
- Diamond proxy interaction
- Frontend ABI loading and contract interaction
- Wagmi-declare schema for simple read/write functions

**Contracts:** Uses existing Greeter components (no new contracts needed)

---

## Example 2: Permissioned Greeter

**Purpose:** Show facet composition with access control

**What it demonstrates:**
- Combining GreeterFacet + OperableFacet in one Diamond
- Access control patterns (only operators can setMessage)
- Multi-facet DFPkg creation
- Role management UI via wagmi-declare

**New Components Needed:**
- PermissionedGreeterDFPkg.sol (bundles Greeter + Operable facets)
- Contract list schema with role-aware UI

---

## Example 3: Simple Vault (ERC4626)

**Purpose:** Realistic DeFi vault with token flows

**What it demonstrates:**
- ERC4626 vault implementation using Crane patterns
- Token approval and deposit/withdraw flows
- Share calculation and accounting
- Complex wagmi-declare schema with token lists
- Full DeFi interaction patterns

**New Components Needed:**
- SimpleVaultRepo.sol
- SimpleVaultTarget.sol
- SimpleVaultFacet.sol
- SimpleVaultDFPkg.sol
- Token list JSON for supported assets
- Contract list schema with deposit/withdraw UI

---

## Example 4: Counter + Greeter Diamond (Combined)

**Purpose:** Show multi-facet Diamond composition with two simple features

**What it demonstrates:**
- Creating a new Crane-pattern component from scratch (Counter)
- Combining two facets (CounterFacet + GreeterFacet) in one Diamond
- Single Diamond with multiple features sharing storage/ownership
- Multi-facet DFPkg creation
- Unified frontend for interacting with both features

**New Components Needed (Counter - full Crane pattern):**
- ICounter.sol - Interface with increment/decrement/setNumber/getNumber
- CounterRepo.sol - Storage library with dual `_layout()` pattern
- CounterTarget.sol - Business logic implementation
- CounterFacet.sol - Diamond facet with IFacet metadata
- CounterDFPkg.sol - Diamond Factory Package

**Combined Package:**
- CounterGreeterDFPkg.sol - Bundles both facets together
- Contract list schema for combined UI

---

## Tutorial Design Considerations

### Target Audiences

| Audience | Needs | Entry Point |
|----------|-------|-------------|
| Solidity beginner learning Diamond pattern | Step-by-step guidance, explanations of WHY | Tutorials |
| Experienced dev evaluating Crane | Quick overview, production patterns | Reference examples |
| Team onboarding to existing Crane project | Real-world patterns, best practices | Reference + exercises |

### Documentation Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Inline comments** | Context right in code | Can clutter production code |
| **Separate README per example** | Clean code, detailed docs | Docs can drift from code |
| **Literate programming** | Code and prose interleaved | Tooling complexity |
| **Video + code** | Best for complex concepts | High maintenance |

### Structure Options

#### Option A: Step-by-Step Tutorial
- Developer types along with instructions
- More learning, more time investment
- Best for: Understanding patterns deeply

#### Option B: Working Reference
- Complete, runnable examples
- Developer reads and adapts
- Best for: "Just show me how"

#### Option C: Hybrid (Recommended)
- Complete code exists
- README walks through it explaining decisions
- Exercises at the end for practice

### Proposed Directory Structure (Hybrid Approach)

```
example/
├── README.md                    # "Start here" with learning path overview
│
├── quickstart/                  # 5-minute "just make it work"
│   ├── README.md
│   └── script/DeployGreeter.s.sol
│
├── tutorials/                   # Deep learning path
│   ├── 01-hello-diamond/
│   │   ├── README.md           # Step-by-step walkthrough
│   │   ├── contracts/          # Minimal code
│   │   ├── script/             # Deployment
│   │   └── test/               # Verify it works
│   ├── 02-crane-patterns/      # "The Repo-Target-Facet Pattern"
│   │   ├── README.md           # Deep dive on WHY
│   │   ├── counter/            # Build Counter from scratch
│   │   └── exercises/          # "Try it yourself" challenges
│   ├── 03-composing-facets/    # "Multi-Facet Diamonds"
│   └── 04-frontend-integration/
│
├── reference/                   # Complete, production-style examples
│   ├── counter/                # Full Counter implementation
│   ├── vault/                  # Full ERC4626 implementation
│   └── combined/               # Multi-facet Diamond
│
└── exercises/                   # "Build it yourself" challenges
    ├── 01-add-decrement/       # Extend Counter
    ├── 02-permissioned-greeter/
    └── solutions/
```

### Checkpoint Architecture

Each tutorial could have checkpoints developers can jump to:

```
01-hello-diamond/
├── checkpoints/
│   ├── 01-setup/           # Just foundry.toml
│   ├── 02-deploy-script/   # Script written
│   ├── 03-deployed/        # Addresses saved
│   └── 04-frontend/        # UI connected
└── final/                  # Complete solution
```

### Key Design Principles

1. **Quickstart** gets something running in 5 minutes (dopamine hit)
2. **Tutorials** teach concepts progressively with explanation
3. **Reference** shows production-quality patterns to copy
4. **Exercises** reinforce learning through practice

### Open Questions (To Decide Later)

1. Should examples be self-contained or reference lib/?
   - Self-contained: Easier to understand, but duplicates code
   - Reference lib/: Shows real usage, but harder to follow

2. How do we handle deployments?
   - Local Anvil only?
   - Testnet addresses checked in?
   - Deploy-on-demand scripts?

3. What's the primary entry point?
   - CLI commands to run?
   - Frontend to interact with?
   - Tests to read?

---

## Implementation Tasks

### Phase 1: Hello Diamond (Greeter) - COMPLETE
- [x] Create example/ directory structure
- [x] Write deployment script using GreeterFacetDiamondFactoryPackage
- [x] Write tests (6 tests passing)
- [x] Create wagmi-declare contract list for Greeter (`schema/greeter.contractlist.json`)
- [x] Set up frontend to load Greeter ABI (bundle-abis.sh, run-demo.sh)
- [x] Write tutorial documentation (README.md updated)
- [x] Full pipeline ready: build → test → deploy → bundle ABIs → frontend

### Phase 2: Permissioned Greeter
- [ ] Create PermissionedGreeterDFPkg bundling Greeter + Operable
- [ ] Write deployment script
- [ ] Create contract list with role management UI
- [ ] Add operator management to frontend
- [ ] Write tests for access control
- [ ] Document the composition pattern

### Phase 3: Simple Vault (ERC4626)
- [ ] Implement SimpleVaultRepo with share/asset accounting
- [ ] Implement SimpleVaultTarget with deposit/withdraw/mint/redeem
- [ ] Implement SimpleVaultFacet with IFacet metadata
- [ ] Create SimpleVaultDFPkg
- [ ] Write FactoryService for CREATE3 deployment
- [ ] Create token list for test assets
- [ ] Create contract list schema for vault UI
- [ ] Write comprehensive tests
- [ ] Document vault patterns

### Phase 4: Counter (Full Crane Pattern)
- [ ] Create ICounter.sol interface
- [ ] Implement CounterRepo.sol with storage layout
- [ ] Implement CounterTarget.sol with business logic
- [ ] Implement CounterFacet.sol with IFacet metadata
- [ ] Create CounterDFPkg.sol
- [ ] Write tests following Crane patterns
- [ ] Create wagmi-declare contract list for Counter

### Phase 5: Combined Diamond (Counter + Greeter)
- [ ] Create CounterGreeterDFPkg bundling both facets
- [ ] Write deployment script
- [ ] Create unified contract list schema
- [ ] Build combined frontend view
- [ ] Document multi-facet architecture

### Phase 6: Documentation & Polish
- [ ] Write main README with learning path
- [ ] Create architecture diagrams
- [ ] Add inline code comments
- [ ] Create video walkthrough script (optional)
- [ ] Test on local Anvil fork
- [ ] Test IPFS deployment of frontend

---

## Status

**Current Phase:** Phase 1 COMPLETE - Ready to Test

**Phase 1 Completed:**
- [x] Example directory structure created
- [x] Deployment script (`example/script/DeployGreeter.s.sol`)
- [x] Tests passing (`example/test/HelloDiamond.t.sol` - 6 tests)
- [x] Contract list schema (`example/schema/greeter.contractlist.json`)
- [x] Frontend integration scripts (`scripts/bundle-abis.sh`, `scripts/run-demo.sh`)
- [x] Documentation (`example/README.md`)

**Full Pipeline:**
```
forge build → forge test → anvil → deploy → bundle ABIs → npm run dev → interact
```

---

## Resume Instructions

### To Test the Full Pipeline:

**Terminal 1:**
```bash
anvil
```

**Terminal 2:**
```bash
cd /Users/cyotee/Development/github-cyotee/indexedex/lib/daosys/example
./scripts/run-demo.sh
```

**Terminal 3:**
```bash
cd /Users/cyotee/Development/github-cyotee/indexedex/lib/daosys/lib/daosys_frontend
npm install  # if needed
npm run dev
```

**Browser:**
1. Open http://localhost:3000
2. Add network: Anvil Local, RPC http://127.0.0.1:8545, Chain ID 31337
3. Import account: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`
4. Enter GreeterDiamond address from deployment output
5. Test getMessage() and setMessage()

### Next Steps After Testing:
- Phase 2: Permissioned Greeter (Greeter + Operable facets)
- Phase 4: Counter with full Crane pattern (Repo→Target→Facet→DFPkg)
- Phase 5: Combined Diamond (Counter + Greeter)
- Phase 3: Simple Vault (ERC4626)

---

## Notes

- All contracts must use CREATE3 factory deployment (never `new`)
- Follow Crane's Facet-Target-Repo pattern strictly
- Tests should inherit from CraneTest and use behavior libraries
- Frontend should work in both local dev and IPFS-deployed modes
