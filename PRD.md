---
project: DAOSYS Bounty Board
version: 1.0
created: 2026-06-29
last_updated: 2026-06-29
---

# DAOSYS Bounty Board - Product Requirements Document

## Vision

The DAOSYS Bounty Board is an on-chain coordination system built on the Crane Diamond framework. It enables AI agents and developers to post, claim, and complete bounties for DeFi primitives and tools using the DAOSYS work token. The system supports multiple bounty types, flexible ERC20 funding (including multi-token), role separation between issuers and funders, generalized URIs for specs and deliverables, optional encryption, and Kleros-based dispute resolution. All contracts are implemented in the Crane submodule for reusability.

## Problem Statement

Coordinating development work for a complex Diamond-based framework like Crane across many contributors (especially AI agents) requires:

- A trust-minimized way to post jobs and release payment on verifiable completion.
- Support for different project structures (simple tasks, multi-milestone, contests, ongoing work).
- Ability to fund with any ERC20, separate funding from management, and allow community top-ups.
- Minimal on-chain data (heavy details via URIs) to keep gas low and Kleros integration clean.
- Reusable infrastructure so other DAOs/projects can deploy their own instances.

Existing solutions are either off-chain, too rigid, or don't integrate well with on-chain dispute systems like Kleros or yield-bearing vaults.

## Target Users

| User Type | Description | Primary Needs |
|-----------|-------------|---------------|
| DAOSYS / Crane Core Team | Primary issuers and funders | Easy posting, multi-token funding, reliable payout on acceptance |
| AI Agents & Developers | Claimants / workers | Clear specs via URI, flexible proof submission, payment on completion |
| Other DAOs / Projects | Re-users of the system | Ability to deploy own instance via DFPkg, independent governance |
| Community Funders | Additional contributors | Easy top-up and withdraw of extra funding without canceling |

## Goals

### Primary Goals
1. Support four high-level bounty types as orthogonal composable definitions.
2. Allow any ERC20 funding with clear roles (Issuer, Funder) and additional contributors.
3. Minimize on-chain storage; use stable URIs (ipfs:// preferred) for PRDs, proofs, and encryption keys.
4. Integrate cleanly with Kleros via IArbitrable (arbitrator from Config Oracle or override).
5. Provide a Crane DFPkg so the system is reusable (singleton for DAOSYS, own proxies for others).
6. Precede with (or include) an ERC165 Config Oracle in Crane for defaults like arbitrator.

### Success Metrics
- All four bounty types supported in v1 DFPkg.
- Funding with multiple ERC20s per bounty, with correct refund/withdraw semantics.
- Kleros disputes work for payment/assignment issues with minimal on-chain state.
- Other projects can deploy independent instances with their own Config Oracle.
- Gas costs kept reasonable through URI/hashes and efficient storage.

## Non-Goals (Out of Scope for v1)
- Heavy on-chain evaluation of deliverables (Kleros + off-chain policy + URIs handle judgment).
- Mandatory yield-bearing funding (direct ERC20 primary; IStandardExchangeIn/Out optional enhancement).
- On-chain BattleChain enforcement (advisory only).
- Complex vesting beyond basic per-type payment (Linear may be considered later).
- Agent registry / staking in initial scope (focus on core board + escrow + disputes).

## Key Design Decisions

### Bounty Types (High-Level Definitions)
All types support:
- Open (anyone can submit) or Closed (approved list + assignment).
- Optional deadline for submissions.
- Assignment model: exclusive (submit for assignment) or first-past-the-post.

**Single Final Deliverable Open/Closed Bounty**
- One final deliverable.
- Payment only on acceptance.
- Disputes: Worker → issuer for non-response or refusal to pay. Closed: worker can dispute unfair removal from assignment.
- Issuer: one PRD URL (ipfs:// preferred).
- Worker: any number of deliverable URLs.
- Good for short/simple work.

**Milestone Deliverables Open/Closed Bounty**
- Total budget, budgeted per milestone; paid per milestone delivery.
- Closed: per-milestone assignment possible.
- Disputes: Worker → issuer for non-response/refusal on milestone. Closed: dispute removal.
- Issuer: global PRD + one PRD per milestone.
- Suitable for long projects with progress checkpoints and parallel work.

**Contest Open/Closed Bounty**
- Total budget as prize pool allocated to tiers (1st, 2nd, ... — must sum exactly).
- Closed: issuer can assign workers (can assign more than tiers).
- Disputes (worker only): failure to respond by deadline+72h, refusal to assign all tiers, or refusal to pay.
- No disputes on ranking/quality (issuer discretion).
- Supports multi-acceptance with equal or ranked prizes.
- Hard deadline.

**Continuous Bounty Open/Closed Bounty**
- Current escrowed budget; issuer sets per-deliverable payment + timer.
- Optional: max missed intervals before removal (closed).
- Disputes (worker): non-response within +72h per deliverable.
- Closed: dispute removal.
- For recurring/iterative work.

### Funding Model (Orthogonal to Type & Payment)
- Any ERC20 allowed (multi-token per bounty supported, e.g. USDC + DAO token).
- Roles:
  - Issuer: defines bounty, manages (transferable). Designates funder at creation.
  - Funder (designated): provides main capital (transferable refund rights). Can be issuer or separate (compartmentalization).
- Funding can be added at creation or later by anyone.
- Anyone can add "additional" funding as incentive.
- On-chain: per-contributor per-bounty per-token contributions.
- Cancel: Issuer or Funder can cancel. After close, designated Funder can request per-token withdrawal of their contributions (they loop). Other contributors withdraw freely anytime.
- Issuer may declare (on-chain) a public key URL for encrypted deliverables.

### Architecture & Implementation
- Contracts live in the Crane submodule (lib/crane) for reusability.
- Use Crane Diamond + Facet-Target-Repo + DFPkg patterns.
- **Distinct facets per bounty type** (SingleBountyFacet, MilestoneBountyFacet, ContestBountyFacet, ContinuousBountyFacet) for simplicity.
- Common data promoted to shared Repos (BountyRepo, EscrowRepo, DisputeRepo, etc.) reusable by all type facets.
- Type-specific Repos for unique data (e.g. prize tiers, milestone arrays).
- Singleton Diamond proxy for DAOSYS (easy discovery). Other DAOs/projects use the DFPkg to deploy their own independent proxies.
- Proxy deployment arguments: arbitratorOverride (optional), configOracle, owner (for Operable control).

### Config Oracle (Prerequisite)
- New ERC165-based Config Oracle in Crane.
- Per-developer/DAO deployable Operable-controlled proxies with fall-through to parent oracle.
- Exposes:
  - getDefaultTarget(bytes4 interfaceId)
  - getTarget(bytes4 interfaceId) — uses msg.sender internally (wraps the two-arg version)
  - getTarget(bytes4 interfaceId, address caller)
- Fallback: caller override → default. 0 = unset.
- Bounty Board DFPkg uses it at deployment (via caller-specific query + interface ID) to resolve default arbitrator (overridable).
- Long-term: integrate Config Oracle facet into CREATE3 Factory Package.

**Storage struct example (ConfigOracleRepo):**
```solidity
struct Config {
    mapping(bytes4 interfaceId => address defaultTarget) defaults;
    mapping(bytes4 interfaceId => mapping(address caller => address target)) overrides;
}
```

### Kleros Integration
- Board implements IArbitrable.
- Arbitrator address from Config Oracle (or override at deploy).
- Create dispute from the proxy; Kleros records the proxy as arbitrable.
- Kleros calls rule(disputeID, ruling) on the proxy.
- Board verifies msg.sender == arbitrator, maps disputeID to bounty, executes outcome based on ruling.
- On-chain data kept minimal — Kleros uses off-chain policy + submitted URIs/evidence.
- Ruling semantics (1=worker side release, 2=issuer side refund, etc.) to be defined per bounty type.
- Governance can swap arbitrator via meta-bounty on the board.

### On-Chain Data Model (Minimal)
Focus on what is required for escrow accounting, status, role permissions, Kleros mapping, and execution. Use hashes/URIs for heavy content.

Example minimal Bounty struct (refined in implementation):
```solidity
struct Bounty {
    uint256 id;
    address issuer;
    address funder;                 // designated funder
    uint8 bountyType;               // 0=single, 1=milestone, ...
    uint8 status;
    uint256 createdAt;
    uint256 deadline;
    bytes32 specUriHash;
    bytes32 encryptionPubKeyUriHash; // optional
    // Type-specific data in dedicated mappings or extension structs
}
```

Contributions tracked as:
mapping(uint256 bountyId => mapping(address contributor => mapping(address token => uint256 amount)))

Disputes:
mapping(uint256 disputeId => struct { uint256 bountyId; uint256 milestoneOrIndex; ... })

Separate mappings or type-specific Repos for milestones, prizes, assignments, etc.

All storage namespaced (Crane keccak pattern) and scoped by bountyId.

### Payment & Acceptance
- Payment triggers defined per type (on acceptance, per milestone, prize tiers, per deliverable).
- Generalized URIs: specUri (issuer PRD), proof/deliverable URIs (any number from worker).
- No on-chain evaluation of deliverables.

### Orthogonality
Bounty type (structure), Payment model, Funding (ERC20 + roles), Access (open/closed), Dispute path are designed to combine flexibly.

## Technical Requirements

### Architecture
- Diamond (ERC2535) via Crane patterns.
- DFPkg for consistent deployment of facets.
- CREATE3 for deterministic addresses.
- Use existing Crane components: Operable for access, IStandardExchange* (if yield used), SafeERC20, etc.

### Integrations
- IStandardExchangeIn / Out for optional yield funding.
- Kleros (IArbitrable) for disputes.
- Config Oracle for defaults.

### Chains
- Base primary (for Bankr launch alignment).
- Support via Crane for other EVM chains.

### Security
- Proper access control per role (issuer, funder, etc.).
- Reentrancy protection.
- Secure handling of arbitrary ERC20.
- Minimal on-chain data to reduce attack surface.
- Dispute logic only executes on verified arbitrator callback.

## Development Approach

### Order
1. Implement Config Oracle package (per-dev proxies, fallthrough, ERC165 query). [DONE]
2. Implement Bounty Board DFPkg + common Repos + per-type facets in Crane. [DONE in this session]
3. Ensure multi-ERC20 funding, role transfers, withdraw/cancel flows. [core flows in CommonTarget]
4. Integrate Kleros (after ruling semantics per type defined). [IArbitrable + rule wired; full ruling policies can be refined]
5. Tests, deployment scripts, documentation. [smoke tests added; full run heavy]

### Documentation
- Update this PRD, BANKR_LAUNCH.md, and lib/crane/GOVERNANCE.md as needed.
- Clear NatSpec.
- Off-chain policy document for Kleros.

### Milestones (for this component)
- M1: Config Oracle package.
- M2: Core DFPkg with shared + per-type facets, basic single bounty flow.
- M3: Multi-type support, multi-token funding, role/cancel/withdraw logic.
- M4: Kleros integration + full dispute flows.
- M5: Deployment of DAOSYS singleton + examples for other users.

## References
- BANKR_LAUNCH.md (DAOSYS token launch plan)
- lib/crane/GOVERNANCE.md (original bounty board concepts)
- Crane patterns (Facet-Target-Repo, DFPkg, CREATE3)
- ERC-792 / Kleros documentation (from BANKR_LAUNCH research)
- IVaultFeeOracleQuery.sol and VaultFeeOracleQueryFacet.sol (patterns for Config Oracle)