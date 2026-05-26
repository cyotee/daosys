# BANKR_LAUNCH.md — DAOSYS Token Launch Plan

**This document is intended to be self-contained for a new agent or context.** It includes the full narrative, research summaries (Kleros, BattleChain, platforms), key decisions (generalized URIs, payout modes, yield deposits, Kleros force-payouts with governance control, custom discovery), code/interface sketches, phased plans, and implementation guidance. All prior research and decisions from the project are consolidated here.

## What Crane (and DAOSYS) Actually Is (For the Token Pitch)

Crane is the core production-grade, Diamond-first (ERC2535) Solidity framework inside the DAOSYS project. DAOSYS is a Foundry-first Solidity workspace and development ecosystem built on Crane, providing Diamond/Crane-style examples, deployment infrastructure, frontend tooling, and on-chain coordination tools for DeFi development.

Crane itself (the framework) is not a concept — it has 270+ completed development tasks and substantial implementations across every layer of DeFi infrastructure. DAOSYS packages and extends this for practical use.

**Core implemented modules:**

- **Diamond factory system** — CREATE3 deterministic deployment + Diamond Package Callback Factory for cross-chain reproducible proxy deployment
- **Access control** — Operable (operator-based), Reentrancy lock, ERC8023 (two-step ownership, novel EIP)
- **Introspection** — ERC165, ERC2535 (Diamond/Loupe), ERC8109 (novel EIP)
- **Token standards** — ERC20 (+ Permit, MintBurn, vault-locked variants), ERC721 (Enumerable), ERC4626 (tokenized vaults), ERC2612, ERC1155
- **DEX integrations** — Uniswap v2/v3/v4, Balancer v3 (Weighted, Stable, Gyro 2CLP/ECLP, CoW, ReClAMM, LBP, Hooks, Router), Aerodrome v1 + Slipstream, Camelot v2
- **Math utilities** — ConstProdUtils, UniswapV3/V4/Slipstream/Aerodrome quoters, fixed-point math
- **AI agent skills** — `.opencode/skills/` contains pre-built skills covering Aave v3/v4, Balancer v3, Euler, Compound Comet, Uniswap v3/v4, Slipstream, Resupply, and more

The skill library makes Crane immediately useful to any AI agent doing DeFi development — an agent with the Crane skill set knows how to interact with every major protocol and how to build Diamond-pattern contracts to wrap them.

---

## Token Positioning

> **DAOSYS is an on-chain bounty board and coordination token for the DAOSYS project (built on the Crane Diamond framework) for AI agents and developers building DeFi. Anyone can buy DAOSYS, deposit it (directly or into selected Indexedex/compatible vaults via the `IStandardExchangeIn/Out` standards) against a feature request with milestone payment terms, and an agent claims the job. Funds can earn yield while the bounty is live. Agents earn DAOSYS for completing milestones and sell it for compute credits to keep building. Every trade funds the dev team and ecosystem. Every feature built makes DAOSYS more valuable to more agents and builders.**

This is not speculative. The framework exists, the AI agent ecosystem (BankrBot, Claude Code, OpenClaw) exists, and the integration points exist today.

**The economy of scale argument:** If 100 agents each independently build a Uniswap V4 hook integration at $10 of compute each, that's $1,000 of duplicated work. If those same agents each contribute $1 to fund a DAOSYS bounty (built with Crane), all 100 get the primitive for $100 total — and it's built once, maintained, and available to every future agent that needs it.

**Why this token has a real narrative:**
- DAOSYS builds directly on Crane, which already has a rich skills library that agents install — the DAOSYS token funds development and extension of the ecosystem (Crane + DAOSYS examples, frontend, on-chain tools)
- Every major DEX and protocol that Crane/DAOSYS integrates with is on Base — same chain the DAOSYS token launches on
- Hundreds of development tasks across Crane + DAOSYS document real velocity — the token story is grounded in shipped code
- On-chain bounty board (see [GOVERNANCE.md](GOVERNANCE.md)) is the real coordination mechanism for the DAOSYS project — not a vague roadmap

**Governance summary:**
- DAOSYS is a **work token**: deposited into bounties by people who want features, earned by agents who build them
- Milestone-based payment: poster defines completion criteria per milestone, DAOSYS releases on approval
- No voting periods, no quorum — priorities are set by who funds them
- **Yield-bearing deposits (new)**: Instead of (or in addition to) idle escrow, posters can select one or more Indexedex vaults (or other compatible vaults) into which bounty funds are deposited using the `IStandardExchangeIn` / `IStandardExchangeOut` standards (moved from Indexedex into Crane; see promotion details below). Capital earns yield while the bounty is posted and advertised — small deposits can grow.
- Agent registry with DAOSYS stake for dispute panel eligibility and reputation tracking
- Full spec: [GOVERNANCE.md](GOVERNANCE.md) (on-chain `Bounty` struct and board will support vaulted positions via the `IStandardExchangeIn/Out` standards moved to Crane)

Note: The actual token contracts, bounty board, and UI will be implemented in the DAOSYS repo (using Crane factories and patterns for the Diamond implementation).

---

## Concrete Launch Plan

### Phase 0: Pre-Launch (Before deploying the token)

**Do these first — they establish the narrative is real before people check.**

1. **Make the DAOSYS repo public** (if it isn't already) with a clear README that describes the DAOSYS project scope (built on Crane), shows the skill libraries, examples, and frontend tooling, and links to the task archive as evidence of velocity.

2. **Create a GitHub Discussions or Issues section** with a "Feature Request" issue template that includes:
   - Description of the needed primitive or DAOSYS improvement
   - Which protocol/standard it targets
   - Acceptance criteria
   - (later) Payment field for x402 commissions

3. **Publish Crane and DAOSYS Bankr skills** to the public BankrBot skills repo at `github.com/BankrBot/skills` so any agent can install them:
   ```
   install the crane skill from https://github.com/BankrBot/skills
   install the daosys skill from https://github.com/BankrBot/skills
   ```
   The skills should teach agents: what Crane and DAOSYS are, how to install as Foundry dependencies, what primitives/examples exist, how to use the Diamond pattern, and how to build with the DAOSYS workspace/frontend tooling.

4. **Prepare token metadata:**
   - Name: `DAOSYS`
   - Symbol: `DAOSYS`
   - Logo: a suitable DAOSYS project icon/logo
   - Website: https://github.com/cyotee/daosys (or the DAOSYS landing page)
   - Associated launch tweet describing the agent-commissioning model and DAOSYS project

---

### Phase 1: Token Launch

**Requirements:**
- Bankr Club subscription ($20/month — subscribe at bankr.bot in chat)
- Bankr embedded wallet (auto-created via email/social login)
- Prepared metadata from Phase 0

**Launch command (CLI — recommended for metadata control):**
```bash
npm install -g @bankr/cli
bankr login
bankr launch \
  --name "DAOSYS" \
  --image "https://raw.githubusercontent.com/cyotee/daosys/main/assets/daosys-logo.png" \
  --tweet "https://x.com/YOUR_HANDLE/status/LAUNCH_TWEET_ID" \
  --website "https://github.com/cyotee/daosys" \
  --yes
```

**Or via natural language in Bankr terminal:**
```
deploy a token called DAOSYS with symbol DAOSYS on base
```

**What you get after launch:**
- DAOSYS token contract address on Base
- Uniswap V4 pool (via Doppler) — immediately tradeable
- 0.7% swap fee on every trade; 95% flows to your wallet
- DEX URL for sharing

The token contracts and any associated DAO / bounty board UI will be implemented and deployed from the DAOSYS repo (using Crane's Diamond factories and DFPkgs).

**Immediately after:**
- Post the contract address and DEX link in the launch tweet
- Tag `@bankrbot` on X — this surfaces the token to the BankrBot community
- Post in BankrBot Discord: `discord.gg/bankr`

---

### Phase 2: Close the Loop (Fee → Compute)

**Set up automated fee claiming:**
```
set up an automation to claim fees for DAOSYS every 24 hours. run this for 60 executions
```

**Wire fees to LLM credits:**
```
add $25 in LLM credits
```

This is the self-sustaining loop: trading activity → WETH fees → LLM credits → development agent keeps running.

**Install the Bankr skill into your development agent:**
```
install the bankr skill from https://github.com/BankrBot/skills
```

Now the DAOSYS development agent (running in Claude Code / Cowork / Bankr terminal, using Crane) can check its own fee balance, claim when needed, and top up LLM credits without manual intervention.

---

### Phase 3: Agent Feature Commission System

This is the differentiator that makes the DAOSYS token story concrete and defensible.

**Architecture:**

```
Requesting Agent
    │
    ▼  (pays via x402 micropayment)
x402 endpoint (hosted via Bankr x402 Cloud)
    │
    ▼  (files GitHub Issue with payment proof + spec)
crane/issues — Feature Request template
    │
    ▼  (DAOSYS dev agent picks up issue)
Implementation (Foundry, Diamond pattern, tests)
    │
    ▼  (human review gate → merge)
New crane primitive — available to all agents
```

**Setting up the x402 endpoint:**

In Bankr terminal:
```
create an x402 endpoint that accepts feature requests for the crane framework.
charge $10 per request. the endpoint should validate that the request includes:
a feature name, a target protocol or ERC standard, and acceptance criteria.
on payment, file a GitHub issue using the crane feature request template.
```

**GitHub Issue template** (`.github/ISSUE_TEMPLATE/feature_request.yml`):
```yaml
name: Feature Request (Agent Commission)
description: Request a new primitive or integration for the crane framework
labels: ["feature-request", "agent-commissioned"]
body:
  - type: input
    id: feature-name
    attributes:
      label: Feature Name
      placeholder: "BalancerV4 Weighted Pool Facet"
    validations:
      required: true
  - type: input
    id: target
    attributes:
      label: Target Protocol / ERC Standard
      placeholder: "Balancer V4 / ERC4626"
    validations:
      required: true
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance Criteria
      placeholder: "Describe what the implementation must do to be considered complete"
    validations:
      required: true
  - type: input
    id: payment-proof
    attributes:
      label: Payment Transaction Hash
      description: "x402 payment transaction on Base"
```

**DAOSYS task numbering**: the Crane sub-repo has CRANE-001 through CRANE-269 (historical). DAOSYS-level bounties and agent-commissioned issues will use DAOSYS- prefixed numbering (or continue under the unified system), with the payment proof linked. This creates a transparent, on-chain record of which features were funded by agents vs. internal development.

---

### Phase 4: Community and Amplification

**Primary audience: AI agent developers and DeFi builders**

Channels that matter:
- **X/Twitter**: Tag `@bankrbot` on every milestone. The BankrBot community is exactly the agent-native audience that understands the agent-pays-agent model for DAOSYS.
- **BankrBot Discord** (`discord.gg/bankr`): The people here are already running agents on Base — they're the natural first users of agent-commissioned DAOSYS features.
- **Farcaster/Warpcast**: DeFi-native, Base-heavy audience.
- **Claude Code / Cowork users**: The bankr-agent Claude plugin gives direct reach into the Claude Code ecosystem. Crane/DAOSYS skill submissions to the BankrBot skills repo put the ecosystem in front of every agent that installs DeFi skills.

**Content that reinforces the narrative:**
- "Agent X filed a feature request for a Uniswap V4 hook and paid $10 in x402. We shipped it in 48 hours. Here's the PR." — this is the flywheel in action, documented publicly.
- Showcase the existing skill library — 20+ DeFi protocol skills (Crane + DAOSYS) already exist in `.opencode/skills/`; these can be surfaced as evidence of depth.

---

## What Makes This Work vs. What Could Fail

### What works in DAOSYS's favor
- **Real code**: 270+ tasks (Crane) + DAOSYS workspace/examples, complete Diamond factory system, integrations across every major Base DeFi protocol — this is auditable before buying
- **Agents can use it today**: the skills library (Crane + DAOSYS) is immediately installable; no waiting for "roadmap" items
- **Base alignment**: Uniswap V4, Balancer V3, Aerodrome — all deployed on Base, where the DAOSYS token launches (DAOSYS builds on Crane which targets Base heavily)
- **Novel EIPs**: ERC8023 (two-step ownership), ERC8109 (introspection) — these are differentiators that give the framework IP that other devs want
- **Systematic development**: task numbering with PROGRESS.md per task shows a disciplined process agents can rely on
- **Custom discovery + yield bounties**: Team building own posting solution; bounties that earn yield while posted via vaults and standards.

### Where the risk is real
- **Token economics require trading volume**: 0.7% fee on a low-volume token generates tens of dollars/month, not hundreds. Volume depends on community adoption.
- **The agent-commissioning model needs its first proof**: the story is compelling but unproven. The first few agent-commissioned issues that actually ship (with generalized URIs, chosen payout mode, and possible vault yield) are critical — they turn the narrative from pitch to evidence.
- **Human merge gate adds latency**: for the first version, human review before merging is correct (security matters in Solidity), but it breaks the "fully autonomous" story. Frame it honestly: "agent-initiated, human-reviewed."
- **Custom solution execution**: Building own discovery/posting + full bounty contracts (payouts, Kleros integration, vault support) in DAOSYS repo adds scope.

---

## Token Economics Rough Math

To fully self-fund LLM costs via trading fees:

| Monthly LLM spend target | Required trading volume | At average trade size |
|---|---|---|
| $20/month (Bankr Club only) | ~$300K/month | ~3,000 × $100 trades |
| $100/month (active development) | ~$1.5M/month | ~15,000 × $100 trades |
| $500/month (heavy agent use) | ~$7.5M/month | requires significant community |

*(Calculation: 0.7% × volume × 95% creator share = fees. $20 target → $20 / 0.00665 = ~$3,000 daily volume needed.)*

At launch, fees will likely cover Bankr Club costs but not full development budget. The x402 feature commission payments supplement this directly — each commissioned feature adds $10+ in direct revenue.

---

## Quick-Start Checklist

- [ ] Sign up at [bankr.bot](https://bankr.bot) with email/social
- [ ] Subscribe to Bankr Club: `subscribe to Bankr Club`
- [ ] Prepare DAOSYS logo image (public URL)
- [ ] Draft launch tweet
- [ ] Make the DAOSYS repo public (if not already) with clear README describing the project (Crane core + examples + tooling)
- [ ] Run `bankr launch` with DAOSYS metadata
- [ ] Post contract address + DEX link on X tagging `@bankrbot`
- [ ] Set up fee claiming automation
- [ ] Wire fees to LLM credits
- [ ] Submit Crane and/or DAOSYS skill PRs to `github.com/BankrBot/skills`
- [ ] Create GitHub feature request issue template (in DAOSYS repo)
- [ ] Set up x402 feature commission endpoint (Phase 3)
- [ ] Plan implementation of DAOSYS token contracts, bounty board, and UI inside the DAOSYS repo using Crane factories

---

## Kleros Integration Research

Kleros is a decentralized arbitration court that can serve as the dispute resolution layer for the DAOSYS bounty board (implemented in the DAOSYS repo using Crane patterns). Rather than building a custom 3-agent panel (which has a cold-start problem at launch — no registered agents = no panel), Kleros provides a live, battle-tested juror pool that works on day one.

### What Kleros Is

Kleros has been live since 2018. As of 2026 it has processed 1,000+ cases across 23 subcourts with 760+ active jurors, including high-stakes DeFi disputes. It operates on the **ERC-792 Arbitration Standard**, which defines two interfaces — `IArbitrator` (the court) and `IArbitrable` (the contract that requests arbitration). Any ERC-792 arbitrable contract can plug into any ERC-792 arbitrator, including Kleros, without code changes to the court itself.

### Versions and Chain Support

| Version | Status | Chain | Notes |
|---|---|---|---|
| Kleros v1 | Production | Ethereum mainnet, Gnosis Chain | Not on Base |
| Kleros v2 | Beta (since Nov 2024) | Arbitrum One | Audits ongoing as of early 2026 |
| Vea Bridge | In development | Arbitrum ↔ Ethereum, Arbitrum ↔ Gnosis | Base route not yet confirmed |
| Kleros Oracle | Production | Base, Polygon, zkSync + 3 others | Only for Reality.eth oracle disputes, not general bounties |

**Critical limitation for DAOSYS at launch: Base is not directly supported by Kleros Court as of June 2026.** The Kleros Oracle product (for prediction market disputes) supports Base, but general-purpose court arbitration is not available on Base. Full trustless integration requires either waiting for a Vea Bridge Base route, or deploying the DAOSYS bounty board on Arbitrum initially. The contracts will be built in the DAOSYS repo.

### What Integrating with Kleros Requires

ERC-792 integration is a well-defined contract interface. Here is exactly what `CraneDisputeFacet` must implement:

**1. Implement `IArbitrable`**

```solidity
interface IArbitrable {
    event Ruling(IArbitrator indexed _arbitrator, uint256 indexed _disputeID, uint256 _ruling);

    /// @dev Called by the arbitrator to deliver a ruling.
    /// Ruling 0 = refused to arbitrate. Ruling 1 = For agent. Ruling 2 = For poster.
    function rule(uint256 _disputeID, uint256 _ruling) external;
}
```

This is the only interface the DAOSYS bounty board must implement (via its Dispute facet built on Crane). The `rule()` callback receives the dispute outcome and releases or refunds DAOSYS escrow accordingly.

**2. Create a dispute**

When a poster calls `disputeMilestone()`, the facet calls:

```solidity
uint256 disputeID = arbitrator.createDispute{value: arbitrationCost}(
    2,          // 2 choices: ruling 1 = agent wins, ruling 2 = poster wins
    extraData   // encodes subcourt ID and number of jurors
);
```

The `extraData` encoding:
```solidity
// subcourt 4 = "Technical" (code/smart contract disputes)
// 3 jurors recommended as starting point
bytes memory extraData = abi.encodePacked(
    uint256(4),  // subcourtID
    uint256(3)   // numberOfJurors
);
```

**3. Query and pay arbitration cost**

```solidity
uint256 fee = arbitrator.arbitrationCost(extraData);
// fee must be paid in msg.value when calling createDispute
// In v2: payable in ETH or whitelisted stablecoins
```

The arbitration fee is the responsibility of the party raising the dispute (the poster who calls `disputeMilestone()`). If the poster wins, they recover the fee; if the agent wins, the fee is forfeit. This creates a meaningful cost barrier against frivolous disputes.

**4. Write and pin a Dispute Policy**

Kleros jurors use a policy document as their primary reference. DAOSYS needs one IPFS-pinned document describing:
- What constitutes valid milestone completion
- What proof formats are acceptable (PR URL, deployed contract address, IPFS hash)
- What makes a dispute invalid (poster disputing without good-faith reason)
- The burden of proof standard

This document is pinned once and referenced in all disputes. It is not per-bounty — it is per-platform.

**5. (v2 only) Register a Dispute Template**

In Kleros v2, call `setDisputeTemplate()` on the `TemplateRegistry` contract (one per chain) to register the question jurors will see. Example:

```
"Did the agent's submitted proof satisfy the milestone completion criteria as described in the bounty specification?"
```

### What Kleros Handles For You (v2)

In Kleros v2, these are fully handled by the court and do NOT require any code in `CraneDisputeFacet`:

- Evidence submission UI and indexing
- Appeal logic and multi-round voting
- Appeal crowdfunding (anyone can top up either side's appeal deposit)
- Juror selection and PNK staking

### What the DAOSYS board Must Handle

| Responsibility | Where |
|---|---|
| Holding DAOSYS in escrow during dispute | `CraneEscrowFacet` (or DAOSYS equivalent built on it) |
| Paying ETH arbitration fee when dispute raised | Dispute facet (charged to disputing party) |
| Calling `arbitrator.createDispute()` | Dispute facet |
| Receiving `rule()` callback and releasing/refunding DAOSYS | Dispute facet |
| Pinning the Dispute Policy to IPFS | Off-chain, one-time setup |
| Registering the Dispute Template (v2) | Off-chain, one-time setup |

### Subcourt Selection

For DAOSYS bounty milestone disputes, the **Technical Court (ID 4)** is the most appropriate subcourt. It handles smart contract and code-related disputes and attracts jurors with relevant technical expertise. Jurors self-select into courts based on their skills — those without smart contract knowledge will lose money in this court over time and exit.

The downside: technical court jurors are generalist Solidity reviewers, not crane-specific experts. They will be evaluating whether a PR merged and whether acceptance criteria appear met — not whether the crane-specific architecture is ideal. This is acceptable for milestone disputes. Fine-grained technical quality should be addressed by the human review gate on PRs, not by Kleros.

### Restrictions and Limitations

These are firm constraints, not workarounds:

**Chain availability** — Kleros Court is not live on Base. DAOSYS cannot use trustless Kleros integration at Base launch. Options: (a) deploy the bounty board on Arbitrum, (b) use a fallback centralized arbitrator at launch and upgrade when Base is supported, or (c) use the Recognition-of-Jurisdiction (RoJ) model — pledge off-chain to follow Kleros rulings, use [resolve.kleros.io](https://resolve.kleros.io) as the dispute venue.

**Cannot pre-select jurors** — anyone who stakes PNK in the Technical Court can be drawn. There is no mechanism to restrict jurors to crane-familiar reviewers. Jurors evaluate evidence and policy documents, not code quality in depth.

**Arbitration fees are in ETH, not DAOSYS** — the fee is separate from the DAOSYS escrow. Disputing parties must hold ETH to raise a dispute. On Arbitrum this is cheap; on Ethereum mainnet it is expensive.

**Evidence is public and cannot be suppressed** — anyone on the internet can submit evidence to an open Kleros dispute. This is by design. DAOSYS's dispute policy should specify which evidence formats are authoritative.

**Jurors are anonymous** — there is no identity verification. The incentive mechanism (losing staked PNK for incoherent votes) is the only honesty guarantee.

**5–10 day resolution timeline** — each subcourt has a configured voting period. Disputes are not instant. The DAOSYS milestone approval window must account for this.

**v2 is still in controlled beta** — Kleros 2.0 Beta launched on Arbitrum in November 2024 and is undergoing ongoing security audits as of mid-2026. Integrating now means either targeting v1 (Ethereum only, expensive gas) or v2 beta (Arbitrum, lower cost, not fully production-hardened).

**Smart contract wallet caveats** — AI agent wallets are typically smart contract wallets. Courts with hidden votes enabled (General Court on Gnosis and Spanish General Court on Ethereum) have known issues with smart contract wallet signature verification. The Technical Court does not use hidden votes, so this is not an issue for DAOSYS specifically. Kleros contracts deployed from 2025 use a `SafeSend` mechanism that resolves the ETH reward transfer issue for smart contract wallets.

### Upgrade Path for DAOSYS bounty board

The ERC-792 standard separates the arbitrable contract from the arbitrator. `CraneDisputeFacet` stores the arbitrator address as a configurable parameter. This means:

1. **At launch (Base)**: set arbitrator to a `CentralizedArbitrator` controlled by the DAOSYS dev wallet (or DAO). This gives final ruling power during bootstrap. Disputes go to the controller, not Kleros. Fast, no ETH fee required, but centralized. Contracts implemented in DAOSYS repo.

2. **When Kleros Base route is live**: set arbitrator to the Kleros Court v2 contract on Base (or via Vea Bridge). No other code changes needed. Existing `rule()` callback is identical.

3. **Optional future**: when/if Kleros launches an AI-specific court (the "Automated Curation Court" launched in 2025 is an early experiment with AI jurors), DAOSYS could route disputes there for a more agent-native arbitration experience.

This is a clean one-line upgrade. The arbitrator address swap is a governance action (a bounty posted to the board itself).

The same governed Kleros path is used to *force payouts* in both Pay-on-Acceptance and Linear modes if the bounty poster accepts (or appears to accept) a deliverable but then refuses to release funds. See the "Dispute and Forced Payout via Arbitration" and "Payout Options" sections in GOVERNANCE.md for details.

### Summary

| Factor | Assessment |
|---|---|
| Integration complexity | Low — implement one interface (`IArbitrable`), one callback (`rule()`), pay ETH fee |
| Chain compatibility | Blocked on Base today; works on Arbitrum now |
| Juror quality for DAOSYS disputes | Adequate for milestone binary decisions; not crane-specific |
| Cold-start problem | Solved — Kleros has 760+ active jurors today |
| Cost per dispute | ETH arbitration fee (varies by subcourt) + gas; no DAOSYS required for dispute process |
| v2 readiness | Beta on Arbitrum; audits ongoing |
| Upgrade path | Clean — swap arbitrator address, no other changes |

Contact for integration support: [integrations@kleros.io](mailto:integrations@kleros.io)

---

## BattleChain Integration

BattleChain is a pre-mainnet, post-testnet L2 built by Cyfrin — the team that audits major protocols (zkSync, Chainlink, MetaMask, Linea). It is purpose-built to fill the gap between testnet and mainnet: real funds, real adversaries, legal framework.

**Testnet (chain ID 627)** is live as of March 2026. **Mainnet (chain ID 626)** is announced but not yet deployed as of June 2026.

### Why BattleChain Belongs in the DAOSYS Launch

DAOSYS (and its Crane core) produces DeFi infrastructure and tooling — components get composed into protocols handling real funds. The existing security story (Foundry tests + human review gate on PRs + Crane's Facet-Target-Repo patterns) is good but not sufficient for that risk profile. BattleChain adds a step that the project currently lacks: adversarial testing with real money and real incentives before anything reaches mainnet.

This also strengthens the Bankr launch narrative significantly. "Agents commission DAOSYS features (built with Crane) via the DAOSYS board, and every feature gets battle-tested before it ships" is a materially stronger claim than "we have unit tests." It directly addresses the concern a DeFi developer would have before using DAOSYS/Crane primitives in a live protocol.

### How BattleChain Works

The lifecycle for any contract on BattleChain:

```
Audit
  │
  ▼
Deploy to BattleChain via BattleChainDeployer
  │
  ▼
NEW_DEPLOYMENT → requestUnderAttack()
  │
  ▼
ATTACK_REQUESTED → DAO reviews (14-day auto-approve window if DAO doesn't act)
  │
  ├─► REJECTED (NOT_DEPLOYED)
  │
  └─► UNDER_ATTACK
        │  whitehats exploit legally, earn 10% of drained funds
        │  rest goes to recovery address
        │
        ▼
      PROMOTION_REQUESTED → 3-day delay (still attackable)
        │
        ├─► CORRUPTED (terminal — exploited during delay)
        │
        └─► PRODUCTION (terminal — protected like mainnet)
```

**Safe Harbor**: when a contract enters attack mode, an on-chain agreement activates that legally protects whitehats who exploit it. The protocol cannot pursue legal action against attackers during the attack window. Bounty percentages, caps, and identity requirements are all set on-chain. This is based on the SEAL Team framework created in collaboration with a16z and Paradigm.

**Whitehats get paid by proving exploits, not writing reports.** They drain the vault, keep 10%, and send the rest to the recovery address. No severity debates, no politics, no unpaid bounties.

### Key Parameters

| Parameter | Value |
|---|---|
| Chain ID (testnet) | 627 |
| Chain ID (mainnet) | 626 |
| L2 stack | ZKSync |
| PROMOTION_WINDOW | 14 days (DAO auto-approves if no action) |
| PROMOTION_DELAY | 3 days (still attackable after promote request) |
| MIN_COMMITMENT | 7 days minimum attack window |
| Whitehat bounty cut | 10% of exploited funds |

### BattleChain in the DAOSYS Release Workflow

Every DAOSYS DAO bounty completion (for significant Crane-based or DAOSYS primitives) should require BattleChain battle-testing as a milestone condition before the final payout. This turns the bounty board into a full security pipeline, not just a payment mechanism. Contracts and UI implemented in the DAOSYS repo.

**Updated milestone template (Large feature):**

| Milestone | Criteria | DAOSYS % |
|---|---|---|
| Scoping | Protocol analysis, interface mapping, risk notes | 5% |
| Interfaces | All `I*.sol` files, NatSpec, selector annotations | 10% |
| Implementation | Repo + Target + Facet + DFPkg compiling | 25% |
| Tests | TestBase + behavior + at least one fork test passing | 20% |
| BattleChain deploy | Contracts deployed and in ATTACK_REQUESTED state | 5% |
| Battle-tested | Survived minimum 7 days in UNDER_ATTACK without CORRUPTED | 25% |
| Production + skill | Promoted to PRODUCTION, NatSpec complete, skill entry added, PR merged | 10% |

The "Battle-tested" milestone is verifiable on-chain: check that the contract's BattleChain state is `PRODUCTION` and `postedAt` is at least 7 days before `promote()` was called.

**The security gate is explicit, not advisory.** The agent does not receive the final 35% (BattleChain + battle-tested + production milestones) until the contracts have survived adversarial testing. Posters can verify this on the BattleChain explorer before approving.

### AI Integration (Directly Relevant to Crane's AGENTS.md)

BattleChain is explicitly built for AI coding agents. Crane already has `AGENTS.md` — adding BattleChain context there means every agent that reads crane's codebase instructions will know to deploy to BattleChain before mainnet.

**Install the BattleChain skill (Claude Code):**
```bash
/plugin marketplace add Cyfrin/solskill
/plugin install battlechain@solskill
/plugin install battlechain-tutorial@solskill
```

Or via npm for any agent:
```bash
npx skills add cyfrin/solskill
```

**Add to `AGENTS.md`** (crane already has this file — append to it):
```
## Security: BattleChain Pre-Mainnet Testing

Before deploying any crane contract to Base mainnet, it MUST be deployed to
BattleChain and survive the attack window. The workflow is:

1. Deploy to BattleChain testnet (chain ID 627) first to verify the process
2. Deploy to BattleChain mainnet (chain ID 626) with real liquidity
3. Call requestUnderAttack() to open it for whitehat testing
4. Wait for DAO approval (UNDER_ATTACK state)
5. Survive minimum 7 days in attack mode
6. Call promote() and wait 3-day delay
7. Verify PRODUCTION state before deploying to Base mainnet

BattleChain docs: https://docs.battlechain.com/llms-full.txt
Foundry starter: https://github.com/Cyfrin/battlechain-starter-foundry
```

**MCP server** for real-time BattleChain context in any MCP-compatible tool:
```bash
claude mcp add --transport http battlechain-docs https://docs.battlechain.com/api/mcp
```

### Foundry Compatibility

Crane uses Foundry exclusively. Cyfrin ships `battlechain-starter-foundry` ([github.com/Cyfrin/battlechain-starter-foundry](https://github.com/Cyfrin/battlechain-starter-foundry)) — a Foundry template for the full BattleChain workflow including deploy scripts, Safe Harbor agreement creation, and attack-mode request. Crane can fork this as the baseline for its own `script/battlechain/` deploy scripts.

### What BattleChain Cannot Do (Limitations)

**Mainnet not live yet** — as of June 2026, only the testnet is deployed. The full value proposition (real funds, real adversaries) is not yet available. Testnet can be used to validate the deployment process and workflow.

**ZKSync-based, not Base** — BattleChain is its own L2. Contracts must be deployed there as a separate step; it's not a Base pre-deployment. Any crane primitives that use Base-specific dependencies (e.g., Base bridge precompiles) need mock equivalents for BattleChain.

**DAO dependency** — contracts enter attack mode only after DAO approval. If the DAO is slow, there's a 14-day auto-approve window, but that's 14 days of waiting. For the milestone payout gate, posters should account for this in their timeline.

**Attack window does not guarantee discovery** — surviving BattleChain is evidence of security, not proof. A contract can survive the window without being found by whitehats if the reward isn't large enough to attract expert attention. Larger bounty deposits attract more serious scrutiny. Set liquidity proportional to the stakes in your protocol.

**Identity requirements for whitehats** — BattleChain requires some identity verification for whitehats claiming bounties (KYC/KYB level depends on bounty size). This is a legal requirement of the Safe Harbor framework. AI agent whitehats would need a human entity behind them to claim.

### The Bankr Narrative Addition

> DAOSYS doesn't just build DeFi primitives and tooling (on Crane) — it proves them. Every major deliverable funded by the DAOSYS board gets battle-tested on BattleChain before it ships. Whitehats get paid to find bugs before users get hurt. If it survives the attack window, it promotes to mainnet. If it gets exploited, the agent fixes it and starts over. The bounty board doesn't close until the code is hardened. Contracts are implemented in the DAOSYS repo.

This is a differentiated story in the DeFi tooling space. Most frameworks have tests. Almost none have real-money adversarial testing baked into the release process.

### Summary

| Factor | Assessment |
|---|---|
| Relevance to DAOSYS | Very high — DAOSYS (on Crane) ships DeFi infrastructure and tooling, security (via BattleChain) is part of the product |
| Workflow fit | Native — Foundry starter exists, AI skill installs in one command |
| Current availability | Testnet only (chain 627); mainnet (chain 626) announced, not live |
| Integration complexity | Low — deploy scripts + AGENTS.md update + milestone criteria change |
| Narrative value | High — "battle-tested" is a verifiable claim, not a marketing claim |
| Timing | Start on testnet now; mainnet workflow ready for first bounty completion |

---

## Bounty & Job Board Platform Research

The DAOSYS bounty board contracts (building on the historical CRANE-DAO-001 planning through CRANE-DAO-009) don't exist yet. There's a bootstrap problem: you need to post bounties to build the bounty board, but the board isn't built yet. The answer is to use existing platforms (or the team's custom solution) as the discovery and posting layer, then migrate to the on-chain DAOSYS board (implemented in the DAOSYS repo) once it's deployed.

This section covers what exists, what fits, and the recommended layered approach.

### On-Chain Bounty Funding with Yield-Bearing Vault Deposits

The core on-chain board (detailed in [GOVERNANCE.md](GOVERNANCE.md)) will support an enhanced deposit model beyond simple token escrow:

- Posters can select one or more vaults (primarily Indexedex vaults, or any compatible ERC4626 / yield position).
- Bounty funds are deposited using the `IStandardExchangeIn` standard (moved from the Indexedex codebase into Crane as a public standard at `contracts/interfaces/IStandardExchangeIn.sol`). The board receives the output position (e.g. vault shares).
- While the bounty is posted and advertised, the escrowed capital earns yield inside the chosen vault(s). This makes even small deposits more attractive because the effective prize can grow over time.
- On milestone approval, expiry, or payout, the board uses the symmetric `IStandardExchangeOut` to redeem/realize the (grown) position and distribute DAOSYS or underlying assets to the agent or return to the poster.

`IStandardExchangeIn/Out` abstract the "exchange value into a target position" and "exchange out" flows. This includes direct vault deposits and (optionally) swap-then-deposit paths via `data` calldata. Crane owns these as first-class public interfaces (similar to its ERC4626 implementation and Pendle's `IStandardizedYield` precedent), allowing Indexedex and third parties to implement against them.

**Exact promotion (as executed):** 
- Moved the source definitions from `indexedex/contracts/vaults/standard/exchange/IStandardExchangeIn.sol` and `IStandardExchangeOut.sol` (plus the supporting `IStandardExchangeErrors.sol`) into Crane under `lib/crane/contracts/interfaces/`.
- Updated thin re-exports in `indexedex/contracts/interfaces/` and all direct `import` statements throughout `indexedex/contracts/` to resolve via the pre-existing remapping `@crane/=lib/daosys/lib/crane/`.
- Example import after move: `import {IStandardExchangeIn} from "@crane/contracts/interfaces/IStandardExchangeIn.sol";`.
- The old vault-specific location was removed; the interfaces are now Crane-owned standards.
- BANKR_LAUNCH.md was updated to record this move process (no invented interfaces).

The on-chain `Bounty` struct (and `CraneBountyBoardFacet` / related) will be extended to track selected vault targets and position balances. GitHub Issues remain the human-readable spec (see below).

This is a capital-efficient differentiator: "bounties that work while they wait."

**Bounty Process Design Decisions (Generalized + Flexible Payouts)**

The on-chain bounty process (to be implemented in the DAOSYS repo) is deliberately generalized and not locked to any single platform:

- **Any public URI for spec and proof**: The `specUri` and `proofUri` fields accept *any* stable URL or content-addressed URI (GitHub PR/issue, Notion page, IPFS/Arweave hash, custom documentation site, deployed contract explorer link, video, etc.). Verification of contents against `completionCriteria` happens off-chain by the poster, community, and agents. The contract treats URIs opaquely.

- **Payout Options** (per-milestone, chosen at posting):
  - **Immediate / Pay on Acceptance**: Full amount released on `approveMilestone` (or auto-approval, or successful arbitration ruling). Classic milestone model.
  - **Linear**: After acceptance, the amount vests linearly over a `payoutDuration` (in seconds). Agent calls `claimLinearPayout` periodically. Formula: `vested = min(amount, (amount * (now - approvedAt)) / duration)`. This provides ongoing alignment post-delivery while giving the agent progressive access to funds. Remaining unvested stays protected.

- **Kleros + Governance for Force Payouts and Disputes**:
  - The board implements `IArbitrable` (ERC-792).
  - Arbitrator address is governance-controlled (swappable via meta-bounty on the board itself).
  - At launch on Base: start with a dev/DAO-controlled `CentralizedArbitrator` for speed.
  - Upgrade path: swap to Kleros v2 (Technical Court) once Base support or bridge is available. Clean one-line change.
  - **Force Payout**: If the bounty poster "accepts" (via approve or explicit `acceptDeliverable` for linear) but then refuses to release funds, the agent can call `requestForcePayout`. This escalates to Kleros. A ruling in the agent's favor triggers immediate/accelerated release via the `rule()` callback (bypassing poster). Arbitration cost creates skin in the game.
  - Normal disputes (challenging a submission) use the same path.
  - Fallbacks (timeouts, auto-approve) protect against stalling.
  - Full research (versions, costs, policy document, subcourt, evidence rules, smart wallet caveats, upgrade) is documented below in the Kleros section.

The real `IStandardExchangeIn` and `IStandardExchangeOut` (plus `IStandardExchangeErrors`) were moved from Indexedex into Crane (see promotion process above). The bounty board will use them for vaulted deposits as described.

Existing Crane ERC4626 support (`IERC4626`, `ERC4626Service`, Permit2 paths, DFPkgs) + the moved `IStandardExchangeIn/Out` standards provide a strong base. The actual facets (e.g., CraneBountyBoardFacet adapted for DAOSYS, Escrow, Payout, Dispute implementing IArbitrable) will be built in the DAOSYS repo using Crane.

### Discovery, Signaling & Posting Services (Snapshot, etc.)

For *discovery and community signaling* (separate from on-chain funding/escrow), services like Snapshot can complement the board:

- **Snapshot**: Strong for off-chain, gasless proposals and voting. Use it to post bounty specs (linked to public URIs), run temperature checks, or signal priority for features. Many DAOs pair Snapshot proposals with on-chain actions (e.g., curators or treasury releases). **It does not handle token deposits, escrow, milestone releases, or yield** — that stays in the Crane on-chain board using `IStandardExchangeIn/Out`.
- **Gitcoin / other quest platforms**: Useful for contributor discovery but less aligned with multi-milestone DAOSYS work tokens.
- **x402 endpoints (via Bankr)**: Ideal for small paid commissions that auto-create feature requests with public spec URIs (see Phase 3).
- **Pure on-chain + indexers + custom discovery**: The primary path. The team is building its own solution for bounty discovery and posting (integrated with Bankr, on-chain events from the DAOSYS board, and direct URI-based specs). GitHub/public URIs + x402 serve as the bootstrap layer.

No mainstream service natively supports "select your own yield vaults so the bounty deposit earns while posted." The Crane + Indexedex integration provides this unique advantage.

The team is developing its own custom discovery layer on top of the on-chain board rather than depending on third-party platforms.

---

### Phase 0 Posting Layer (Before Contracts)

Use these immediately to fund the first wave of development work. Bountycaster is not being used. The team is building its own dedicated bounty discovery and posting solution. In the meantime, rely on public specification URIs combined with x402 commissions and direct coordination.

#### Dework — Not Recommended

Dework is a DAO task manager (Trello + crypto payments). Its GitHub integration (PR merge → task status update) sounds useful, but GitHub Issues already does this natively. Dework adds a human-facing Kanban layer that agents don't use and that duplicates the GitHub Issues spec layer. No agent API. Skip it.

---

#### Superteam Earn — Not Recommended

Superteam Earn is Solana infrastructure with a Solana community. EVM listings are technically accepted but get no network effect — the contributor pool is Solana-native. The agent API is technically well-designed (REST endpoints, `AGENT_ONLY` listing type, claim code flow) but there's no point posting Base/EVM bounties where no one is looking for them. Skip.

---

### Platforms Reviewed and Not Recommended

#### Gitcoin Allo Protocol
In maintenance mode as of May 2025. Capital allocation / grants framework — not suited to per-task milestone bounties. Skip.

#### Immunefi / HackenProof / Hats Finance
Security audit bug bounty platforms, not development task bounties. Hats Finance is the most interesting (on-chain permissionless vaults, no KYC), but it's scoped to vulnerability disclosure, not feature development. Skip for now — relevant if you want to post a separate bug bounty on CraneBountyDiamond after it ships.

#### JobForAgent.com
Early-stage job board for AI agents. Companies post tasks, builders showcase agents. No crypto payments, no on-chain escrow, no smart contracts. More of a directory. Not suitable as a bounty posting layer.

#### Agentic.market (Coinbase x402)
**URL:** https://agentic.market  
Not a bounty board. It's a service marketplace for agents to buy capabilities from each other using x402 micropayments. Agents can already publish Crane or DAOSYS skills there and charge per-use. Relevant for the x402 feature commission mechanism but not for posting development work bounties.

---

### Recommended Phased Approach

| Phase | Timing | Posting Layer | Payment |
|---|---|---|---|
| **Phase 0** | Now, before token launch | Public specification URIs (GitHub, Notion, IPFS, custom sites, etc.); direct dev wallet payment per milestone | ETH/USDC from dev wallet |
| **Phase 1** | After token launch | Same + x402 for paid commissions (auto-creates URIs with payment proof) | USDC posted via x402 or direct, DAOSYS bonus from dev wallet |
| **Phase 2** | After DAOSYS board deployment (using Crane) | On-chain DAOSYS Bounty Board (primary, with custom discovery solution built by the team) — this is the product | DAOSYS (or other assets) deposited via `IStandardExchangeIn` into poster-selected vaults for yield while escrowed |

In Phase 2, the DAOSYS bounty board (plus the team's custom discovery solution, implemented in the DAOSYS repo using Crane) is the canonical layer. Public specification URIs remain as the human-readable spec source; the on-chain bounty ID is the authoritative record. The board will natively support vaulted, yield-bearing deposits (see "On-Chain Bounty Funding with Yield-Bearing Vault Deposits" above) in addition to direct escrow. External platforms are de-emphasized in favor of direct + custom-built channels.

---

### GitHub Issues as the Spec Layer

Regardless of which platform posts the bounty, every DAOSYS bounty should have a canonical public specification source (a stable URL or URI). This can be a GitHub Issue, a Notion page, a custom website, an IPFS document, etc. x402 commissions (or direct posting) serve as the payment/discovery hook; the URI is the authoritative spec that the agent pulls. The on-chain bounty records the `specUri`. The team is developing its own custom solution for discovery and amplification to reduce reliance on third-party boards.

Issue template fields for DAOSYS bounties (see also the `.github/ISSUE_TEMPLATE/feature_request.yml` for the agent-commissioned variant):
- **Bounty ID** (e.g. `DAOSYS-DAO-001`)
- **Description** — what and why
- **Specification** — full acceptance criteria
- **Repository ref** — target branch/directory (optional; use Spec URI instead)
- **Milestones** — ordered list, each with completion criteria, DAOSYS amount, and payout mode (Immediate or Linear)
- **Vault Targets** (optional) — list of vault addresses (Indexedex or compatible) for yield-bearing deposits via `IStandardExchangeIn`. When specified, funds are deposited into these instead of (or alongside) raw escrow so they can earn while posted.
- **Spec / Evidence URIs** — Any public URL or content URI for the full specification and for milestone proofs (GitHub, IPFS/Arweave, deployed explorer link, custom documentation site, Notion, video, etc. — the process is deliberately *not* locked to GitHub)
- **Claim deadline** — expiry if unclaimed
- **Payment** — ETH/USDC (or other) amount per milestone (or equivalent in vault positions); supports Pay-on-Acceptance (immediate) or Linear (vested over time after acceptance) modes
- **Payout Mode per milestone** — Immediate or Linear (with duration)

This pattern mirrors exactly what the on-chain `Bounty` struct holds (see `GOVERNANCE.md`) — so when the on-chain board ships, migrating existing GitHub Issues to on-chain bounties is mechanical. The vault targets and position accounting will be reflected on-chain.

---

### The Chicken-and-Egg Solution

The DAOSYS bounty board contracts are themselves the first bounties posted. The sequence (building on historical CRANE-DAO planning):

1. Post `DAOSYS-DAO-001` through `DAOSYS-DAO-009` (or equivalent bootstrap bounties) using public spec URIs (e.g. GitHub Issues or any stable URI), funded with ETH/USDC (or vaulted) paid directly from the dev wallet on milestone confirmation (early bounties can use direct deposits; later ones demonstrate vaulted `IStandardExchangeIn` deposits, generalized URIs, and both Immediate/Linear payout modes).
2. An agent completes foundational packages (full Diamond package using Crane).
3. Test suite, dispute/arbitration paths, payout logic, and deploy steps complete the bootstrap.
4. The deployed DAOSYS board (in the DAOSYS repo, using Crane factories) is now live on Base — the board built itself.

Every subsequent bounty runs through the on-chain board. Public URIs remain as the human-readable spec layer. The board will support the advanced vaulted-deposit flow, generalized proof, payout options, and governed Kleros force-payouts once deployed.

### Summary

| Platform / Approach | Fits DAOSYS? | Best Use |
|---|---|---|
| **Dework** | No — human Kanban, no agent API, duplicates GitHub Issues | Skip |
| **Superteam Earn** | No — Solana community, no Base/EVM network effect | Skip |
| **Gitcoin Allo** | No | Maintenance mode |
| **Immunefi/Hats** | Not now | Post-deployment bug bounty on the bounty board contracts |
| **Agentic.market** | Adjacent | x402 feature commissions, not development bounties |
| **JobForAgent.com** | No | No crypto payments or on-chain escrow |
| **Public URIs + x402 + Custom Discovery** | Yes | Phase 0/1 primary layer (team building dedicated solution) |
| **On-chain DAOSYS Board** | Yes — primary target | Phase 2 canonical bounty layer after DAOSYS board deployment (with native `IStandardExchangeIn/Out` vault deposits for yield, generalized any-URI proof, Immediate/Linear payouts, and governed Kleros force-payouts). Contracts and UI implemented in the DAOSYS repo using Crane; integrated with team's custom discovery |

---

## Key Decisions, Research, and Implementation Guidance (for New Agent Context)

This document consolidates all research and decisions for the DAOSYS token launch and bounty system. The actual on-chain contracts, bounty board (with facets for board/claim/milestone/payout/dispute/escrow), token (likely ERC20 DFPkg or similar), and UI will be implemented in the DAOSYS repo using Crane as the foundation.

### Summary of Major Decisions
- **Token**: DAOSYS (name and symbol). Launched on Base via BankrBot for fair launch + fee flywheel to LLM credits. Represents the full DAOSYS project/ecosystem (Crane + workspace + tools + coordination).
- **Bounty Funding**: Support both direct escrow and yield-bearing via selected vaults. Use `IStandardExchangeIn/Out` standards (moved from Indexedex into Crane under the existing @crane remapping). Funds earn while bounty is live/advertised.
- **Spec & Proof**: Fully generalized — any public URL/URI. Not GitHub-locked. Record `specUri` and per-milestone `proofUri` on-chain.
- **Payout Modes** (per milestone):
  - Immediate (pay on acceptance/approval/arbitration ruling).
  - Linear (vest over `payoutDuration` after acceptance; claim vested portions over time).
- **Disputes & Force Payouts**: Governed arbitrator (IArbitrable). Kleros primary long-term (Technical Court), centralized fallback at Base launch. Explicit path for agent to force payout via Kleros if poster accepts but refuses release. Governance swaps arbitrator via meta-bounty.
- **BattleChain**: Required milestone for significant bounties (deploy -> attack mode -> survive -> promote). Use `battlechain-lib`, update AGENTS.md. Adds "battle-tested" narrative.
- **Discovery**: Bountycaster not viable. Rely on public URIs + x402 + team's custom-built discovery solution (integrated with Bankr/on-chain events). Snapshot for signaling/voting.
- **Bootstrap**: GitHub/public URIs + direct payments or x402 initially. On-chain DAOSYS board (with all features) as Phase 2 target. Bootstrap bounties build the board itself.
- **Governance**: Bounty board itself (meta-bounties change params, arbitrator, etc.). No traditional voting. Work token model.
- **Risk Mitigations**: Timeouts/auto-approve, agent registry + slashable stake, BattleChain gate, Kleros force, human review initially.

### Contract/UI Implementation Notes (DAOSYS Repo)
- Leverage Crane: Factories (Create3 + DiamondPackageCallBack), ERC20/ERC4626 DFPkgs, patterns (Facet-Target-Repo), `IStandardExchangeIn/Out` (moved from Indexedex).
- New/Adapted: Bounty structs with `specUri`, generalized `Milestone` (payoutMode, payoutDuration, proofUri, vault targets), Escrow with vault position support + linear release math, PayoutFacet, DisputeFacet (IArbitrable + force logic), integration with Kleros and BattleChain.
- UI: Build in DAOSYS (Next.js or similar from existing frontend tooling) for posting bounties (select vaults, payout mode, URIs), claiming, milestone submission/approval, linear claims, dispute escalation.
- Tests: Lifecycle, generalized URI flows, both payout modes, arbitration force, vaulted escrow, BattleChain integration.
- Skills: Publish/update Crane + new DAOSYS skills for BankrBot agents.

See also: GOVERNANCE.md (structs, flows, architecture), Crane's AGENTS.md (add BattleChain section), lib/battlechain-lib, prior Kleros/BattleChain research in this doc.

This should provide a complete, self-contained context for continuing implementation and launch.

## Resources

- [BankrBot Docs](https://docs.bankr.bot)
- [Token Launching Overview](https://docs.bankr.bot/token-launching/overview)
- [Zero to Earning Guide](https://docs.bankr.bot/guides/zero-to-earning)
- [Claude Plugins](https://docs.bankr.bot/claude-plugins/overview)
- [x402 Cloud](https://docs.bankr.bot/x402-cloud/overview)
- [BankrBot Skills GitHub](https://github.com/BankrBot/skills)
- [Bankr CLI Docs](https://docs.bankr.bot/cli)
- [LLM Gateway](https://docs.bankr.bot/llm-gateway/overview)
