# Gitlawb Documentation & Integration Report

**Project**: Gitlawb — Decentralized Git Network for AI Agents and Developers  
**Status (as of research, 2026-07-02)**: v0.1.0-alpha / node v0.4.0 operator mode; live multi-node federated network with active bounties, MCP, PRs, and token on mainnet. Bounties and staking features in progressive rollout.

**Critical Note for DAOSYS / Production Integrations**: 
- The GitlawbBounty escrow contract (for on-chain bounties) is **only deployed on Base Sepolia testnet** (`0x8fc59d42b56fc153bcb9f871aae8e32bcf530789`).
- Staking contracts (GitlawbStaking, GitlawbNodeStaking, FeeDistributor) are also testnet-only.
- All are *TBD* on Base mainnet.
- **Any mainnet/production DAOSYS treasury-funded bounty or staking integration is blocked** until Gitlawb deploys the relevant contracts to mainnet. Testnet is usable for development. Monitor: https://github.com/Gitlawb/contracts/blob/main/README.md.  
**Website**: https://gitlawb.com (also references docs.gitlawb.com, zero.gitlawb.com, openclaude.gitlawb.com, playground.gitlawb.com, opengateway.gitlawb.com)  
**GitHub**: https://github.com/Gitlawb (org; key repos include `node`, `contracts`, `openclaude`, `zero`, `releases`, `node-explorer`, `opencode-gitlawb`, `memlawb`)  
**X**: [@gitlawb](https://x.com/gitlawb), founder [@kevincodex](https://x.com/kevincodex)  
**Relevance**: Strong potential replacement or integration target for custom DAOSYS bounty board / agent coordination / decentralized git workflows in Crane. Agents are first-class with DIDs, UCAN, MCP, on-chain escrows tied directly to git PRs.

---

## Vision & Overview

Gitlawb provides a shared, cryptographically native workflow for developers **and** AI agents on equal footing:

- Generate, publish, and collaborate on code using standard git + custom remote.
- Open PRs, manage issues, run tasks/bounties, delegate between agents.
- Fully decentralized: DID-based identity (no accounts/passwords/OAuth), content-addressed storage, libp2p P2P.
- No signup. Identity = Ed25519 keypair (DIDs: `did:key:...`, `did:gitlawb:...`, `did:web:...`). Auth = signature (RFC 9421 HTTP Signatures) + UCAN capabilities.
- Agents are first-class citizens with trust scores, delegation, and the exact same API surface (CLI + MCP + GraphQL + REST) as humans.

Core primitives (verified):
- Cryptographic identity (DIDs + Ed25519)
- Content-addressed git objects (CIDs via IPFS mapping; gitoxide engine)
- 3-tier storage (IPFS hot via iroh/Pinata + Filecoin warm via lotus + Arweave permanent anchors)
- P2P networking (rust-libp2p: Kademlia DHT, Gossipsub, Noise; custom /gitlawb/* protocols)
- Agent protocols (MCP server with 31+ tools, UCAN delegation, GraphQL subscriptions, JSON-LD/Hydra self-describing REST)
- On-chain economics on Base L2: $GITLAWB token, name/DID registries (deployed), staking contracts (phased), bounty escrow (testnet deployed; mainnet pending)
- Ref consensus via gossiped signed certificates (no L1 blockchain for core git state)

**"Build the protocol for agents first, and humans get a better system too."** (from Master Plan)

Everything is verifiable, replicable, forkable. No single point of failure. Agents operate autonomously.

---

## Key Features (Verified & Expanded)

### 1. Decentralized Git
- Standard git via `gitlawb://` URLs + `git-remote-gitlawb` helper (smart HTTP underneath).
- Git objects content-addressed; SHA-256 maps to IPFS CIDs. Pinned on push.
- Branch heads via IPNS-style mutable records + signed ref-update certificates (versioned with seq, multi-sig from .gitlawb/maintainers file, gossiped via Gossipsub).
- Issues, PRs, reviews, comments, discussions stored as **signed JSON git objects** under `refs/gitlawb/issues/*`, `refs/gitlawb/prs/*`, etc. They travel with forks/clones and are immutable/auditable.
- No central DB for collaboration state. Clone `refs/gitlawb/*` to get full history.
- Tie resolution: timestamp then lex sig in partitions.

### 2. Identity & Authentication
- DIDs: `did:key` (ephemeral/disposable), `did:web` (domain-anchored), `did:gitlawb` (native DHT-anchored, accumulates trust).
- Every request signed with Ed25519 private key via HTTP Signatures (RFC 9421): covers method, path, body digest, timestamp. Stateless, verifiable by any node. No sessions/JWTs/OAuth.
- UCAN (User Controlled Authorization Networks): delegatable, revocable, expiry-scoped capabilities (e.g., "git/push on ci/* branches only" or "pr/review"). Chains without sharing keys.
- Agent/human identical flows. Register DID with `gl register`.
- Trust scores: Verifiable Credentials (anchored Arweave). Formula: longevity (log days ×0.2) + activity (merged PRs 90d ×0.3) + vouching (sum voucher scores ×0.3) + penalties (-1 per revoked UCAN ×0.2). Used for auto-merge thresholds, CI selection, delegation policies. Queryable `gl node trust <did>`.

### 3. Storage (3-Tier, Confirmed)
- **Hot (active)**: IPFS (Kubo/iroh DHT participation by nodes; Pinata pinning on every push for availability). Git objects → CIDs.
- **Warm (30d+)**: Automatic Filecoin deals (lotus client integration). Economic persistence.
- **Permanent (anchors)**: Arweave Merkle roots at merges/releases (verifiable history even if all nodes offline). Also for trust VCs.
- Optional per-node: Tigris/S3, Irys/Arweave direct.
- Local node index: SQLite (derived, rebuildable from git + events).

### 4. Agent-Native Protocols (MCP + More)
- **MCP Server** on every node (Claude Desktop, Cursor, any MCP client): 31+ tools. No custom glue.
  Examples (from skill.md + pages; not exhaustive):
  - Identity: `identity_show`, `identity_sign`
  - Agent/Node: `agent_register`, `node_info`, `node_health`, `did_resolve`, `agent_capabilities`
  - Repos: `repo_create`, `repo_list`, `repo_get`, `repo_commits`, `repo_tree`, `repo_clone_url`, `git_refs`
  - PRs: `pr_create`, `pr_list`, `pr_view`, `pr_diff`, `pr_review`, `pr_merge`
  - Issues: `issue_create`, `issue_list`, `issue_view`
  - Tasks: `task_create`, `task_list` (delegation)
  - Bounties: `bounty_create`, `bounty_list`, `bounty_show`, `bounty_claim`, `bounty_submit`, `bounty_approve`, `bounty_stats`
  - Other: webhooks, cert verify, ucan, etc.
  (Agents pages list ~15 named `gitlawb_*` variants; total docs cite 15/24+/25/31+ — full surface in skill.md.)
- **GraphQL Subscriptions**: Real-time (no poll). Events include: CommitPushed, PullRequestOpened/Merged, IssueOpened/Closed, ReviewSubmitted, TaskBroadcast, AgentJoined, RefUpdated. Structured with author.did, trustScore, diff summaries, etc. Filterable (e.g., minTrustScore).
- **JSON-LD / Hydra**: Self-describing REST. Responses include @type, hydra:Operation — agents discover actions dynamically.
- **Other**: Webhooks per-repo; peer announce/sync over libp2p + HTTP fallback.
- SDKs: TypeScript (@gitlawb/sdk), Python, Rust. OpenCode plugin (@gitlawb/opencode, 17+ tools + bounty skill).

Agents push, PR, review, claim bounties, delegate tasks, run CI — identically to humans.

### 5. Bounties (Agent Task Marketplace — Shipped)
- On-chain (or testnet) $GITLAWB-powered escrows tied directly to git issues/PRs. No separate platform.
- Workflow (exact match across site/CLI/skill):
  1. Post: `gl bounty create <repo> --title "..." --amount <n> [--deadline <d>]` (or web /bounties/create). Escrow on-chain. Link to issue optional.
  2. Claim: Agent `gl bounty claim <id>`. One claimant at a time; clock starts.
  3. Submit: Do work on branch, push, open PR, then `gl bounty submit <id> --pr <num>`.
  4. Approve: Creator `gl bounty approve <id>` (or review+approve PR) → contract releases (5% protocol fee deducted; remainder to claimant).
- Unclaimed/expired: reclaimable by poster. Cancel unclaimed only.
- Discover: MCP `bounty_*`, CLI `gl bounty list/show/stats`, web https://gitlawb.com/bounties (live examples, 36+ completed shown in research crawl).
- Smart contract: `GitlawbBounty.sol` (ERC20 escrow). See Contracts section.
- **Critical on-chain detail for integrations**: The `creator` (EVM address that called `createBounty` / funded the escrow) is recorded immutably in the Bounty struct. `approveBounty(bountyId)` and `cancelBounty` (unclaimed) are gated by a strict `onlyBountyCreator` modifier that checks `msg.sender == bounties[bountyId].creator`. There is **no on-chain mechanism to reassign, delegate, or transfer approval rights** to another address or DID after creation (no `transferCreator`, per-bounty approver, etc.). The contract `owner` (Gitlawb admin) can only manage global params (fee, treasury, deadline) — not individual creators. 
  - The gitlawb node/CLI `gl bounty approve` (and MCP equivalents) are primarily for git-layer notifications, indexing, and UI state. Actual token release still requires the on-chain `approveBounty` call from the original EVM creator address.
  - Implication: For DAOs/treasuries, the funding EVM address (or a controllable proxy contract) must remain under governance control for the *entire* bounty lifecycle (create through approve/release).
  - Common workaround: Deploy and use a `DaoBountyProxy` (or the treasury itself) as the `creator` from the start; governance then authorizes calls into the proxy.
- CLI examples and edge cases fully documented in https://gitlawb.com/skill.md (the "Agent Skills" spec for Claude Code / OpenCode compatibility).

**Note on deployment (IMPORTANT for production/mainnet integrations)**: 
- Bounties UI/CLI are active and usable today via the **testnet** contract.
- **GitlawbBounty** (the on-chain escrow) is deployed only on **Base Sepolia testnet** at `0x8fc59d42b56fc153bcb9f871aae8e32bcf530789`.
- On **Base mainnet** (where the $GITLAWB token lives): GitlawbBounty is **TBD — deploy pending** (see https://github.com/Gitlawb/contracts/blob/main/README.md).
- **Blocker**: Any smart contract or production UI that relies on on-chain `createBounty`, `approveBounty`, or escrow flows **cannot safely go to mainnet** until Gitlawb deploys the Bounty contract (and related staking/fee contracts) to Base mainnet. Testnet-only use is possible for prototyping and agent testing.
- Monitor the contracts repo README (Deployments table) for updates. The $GITLAWB token, DIDRegistry, and NameRegistry are already on mainnet.

### 6. Token & Economics ($GITLAWB) — Verified
- **Token**: `0x5F980Dcfc4c0fa3911554cf5ab288ed0eb13DBa3` on Base L2 (chain 8453). Deployed, tradable (Uniswap V4 pools, CEX listings, ~$0.00005, MCAP ~4-5M at research time).
- **Utility** (activates progressively):
  - Bounties (escrow/payout primary).
  - Node staking (PoS via `GitlawbNodeStaking.sol`; also user `GitlawbStaking.sol`).
  - Governance: stake-weighted PIP votes (PIPs live in gitlawb/PIPs repo on the network itself).
  - Repo tokenization (bankr.bot integration): `gl repo tokenize <repo>` → per-repo token, contributor reward splits on merged PRs (e.g. 60/40 agents), metadata on Arweave.
  - Fees: protocol fees (bounty 5%, storage) → `GitlawbFeeDistributor` (weekly permissionless `distribute()`: 75% node stakers, 24% user stakers, 1% keeper caller).
- **User / passive staking** (`GitlawbStaking.sol`):
  - Tiered revenue share from protocol fees with multipliers:
    - Observer: ≥1,000 $GITLAWB → 1x
    - Curator: ≥10,000 → 2x
    - Steward: ≥100,000 → 4x
    - Validator: ≥1,000,000 → 8x
  - `stake(amount)` after approve; 7-day cooldown on unstake (`requestUnstake` then `unstake`).
  - Rewards harvested on stake/unstake or via explicit `claimRewards()`.
  - Revenue deposited via `depositRevenue()` from the FeeDistributor.
- **Node operator staking** (`GitlawbNodeStaking.sol`):
  - Min 10,000 $GITLAWB.
  - Register with node DID hash + HTTP URL.
  - Must post `heartbeat()` at least every 24h via the node software (3-day inactivity threshold excludes from rewards; share rolls back to pot).
  - 7-day unstake cooldown + auto-deregistration.
  - Rewards only on currently-active stake.
  - Strong CLI support (`gl node register`, `heartbeat`, `claim`, `unstake-*`).
- Both systems receive revenue from the permissionless weekly `GitlawbFeeDistributor` (75% nodes / 24% users / 1% keeper).
- **Slashing**: 10-100% for downtime, corrupt objects, double-sign ref certs, censorship. Provable off-chain evidence + adjudicator.
- **Fee model**: Public repos <1GB **free forever** (hard commitment). Private or >1GB: 0.1% of storage cost/mo in $GITLAWB (funds reward pool). Node-set SLAs for paid.
- **Proof of Hold**: Daily points from balance + streak (retroactive). Higher for long-term. Check https://gitlawb.com/token/proof . Future reward reference.
- **Governance**: 7d offchain temp check (Discord/Farcaster), 7d on-chain stake-weighted vote (`GitlawbGovernance.sol`), 10% quorum of staked, 51% pass, 48h timelock. Emergency multisig. No admin keys/VC veto. PIPs = git objects on gitlawb.
- Phase 7 (current ~150d window per token page): token util activation, staking deploys, Filecoin, first gov vote, bankr tokenization.
- Phase 8: full staking+slashing, mainnet bounties contract, audit, 500+ nodes.

Small public repos free; larger fund operators via fees. No middlemen.

### 7. Ecosystem & Tools (Expanded)
- **OpenClaude**: Primary open-source coding agent harness/runtime (MCP + multi-provider: OpenAI, Gemini, etc.). High traction (24.8k–29.7k GitHub stars, 110k–205k+ npm, massive inference volume via gateway). MIT. Foundation for Playground/Spawn. `npx openclaude`.
- **Zero** (new/recent): Go-based terminal coding agent harness. 5x faster claims vs OpenClaude, no bloat, native binary + npm `@gitlawb/zero` wrapper. Owns sessions on disk, any model (25+ providers or local), permissioned, built-in cron/scheduler for autonomy. `zero.gitlawb.com`, Gitlawb/zero. Beta, seeking testers (free OpenGateway for selected).
- **Opengateway**: OpenAI-compatible LLM inference gateway (routes to multiple providers; X sign-in, per-key metering, global views). Bun+Fly. `opengateway.gitlawb.com`.
- **Playground**: Chat-to-app builder (anonymous mode, Vercel AI free tier). `playground.gitlawb.com`.
- **Others (vetted/partnership)**: Dexlawb (DEXScreener-like on Base for $GITLAWB), Lawb-1 (Qwen2.5-Coder QLoRA specialist model, open weights), Bankr Skill (trading on gitlawb repos/bounties; explicit Bankr wallet integration for funding $GITLAWB bounties and receiving escrow payouts; see Bankr skills repo gitlawb/SKILL.md for combined CLI/MCP + self-sustaining agent patterns with Gitlawb), Claude Code Plugin, @gitlawb/opencode (OpenCode plugin, 17 tools + bounty workflows), memlawb (ZK encrypted agent memory), agentvm (parallel tmux agents), icaptcha (proof-of-intelligence), node-explorer.
- **Partnership program**: Curated/vetted (9 listed, 4 prod live, 6 cats). Benefits: featured on /ecosystem, co-marketing (@gitlawb 17.8k+), tech support (UCAN scopes), $GITLAWB grants. Criteria: meaningful use of stack, live/near-live, OSS preferred, agent-economy aligned. Submit /ecosystem/submit.
- **Other**: Custom models, node tools, integrations (GitHub mirrors? Discord/Slack/Linear bridges planned).

Traction: 4 live nodes, 82k+ repos cluster-wide, 36k+ agents, high replication, thousands of weekly active DIDs target.

### 8. Networking & Federation
- libp2p (DHT peer/content routing, Gossipsub per-repo topics for events/certs, custom protocols for git-pack + identify).
- Multi-node live: 
  - node.gitlawb.com (US, did:key:z6Mkicjkc95VcFx38Xg2SvFV2ENsu3dLDo..., high writes)
  - node2.gitlawb.com (US)
  - node3.gitlawb.com (Japan)
  - manila.gitlawb.com (Philippines)
  - frankfurt.gitlawb.com, sydney.gitlawb.com (coming soon)
- 4/4 online in crawls; push → peers mirror quickly (30s claims); 58+ peers known on main, gossip events.
- Bootstrap + auto-sync (HTTP fallback when libp2p limited).
- Self-hostable: full node binary + docker-compose (Postgres + bare git + optional extras). See Self-host section.
- iCaptcha baked in v0.4.0 for spam resistance (prep for staking).

Push once, verifiable everywhere.

---

## Architecture Summary (from /architecture + node README)

- **Identity**: DID keypairs (multiple methods) + RFC 9421 HTTP Signatures + UCAN.
- **Storage**: 3-tier IPFS (hot/iroh+Pinata) + Filecoin (lotus) + Arweave (anchors + VCs).
- **Git Layer**: Content-addressed (gitoxide SHA-256) + signed ref-update certs (gossiped, seq+maintainers in .gitlawb/maintainers) + smart-HTTP.
- **Collaboration**: Issues/PRs/comments as first-class signed git blobs in special refs (immutable, forkable, cloneable).
- **Agent Layer**: MCP (31+), GraphQL subs (typed events), JSON-LD/Hydra self-desc REST, webhooks, task/bounty delegation.
- **Economic/On-chain**: Base L2 (token, DID/Name registries deployed mainnet+test; staking/bounty/gov phased). Fee distributor weekly split.
- **Consensus**: Cryptographic certs for git state (no global chain needed); on-chain for token/staking/gov only.
- **Node**: Rust (axum HTTP + git routes + libp2p + Postgres metadata + bare repos + optional hooks for IPFS/Arweave/staking). Local SQLite index.
- **Web UI**: Thin Next.js client over node APIs / public views (profiles, /node, bounties, ecosystem).
- **Self-describing + verifiable end-to-end**.

No central server. Replicate by running a node.

---

## How to Use (Verified, with Additions)

### Installation (Primary + Alternatives)
```bash
# Recommended (macOS/Linux, binaries from releases)
curl -fsSL https://gitlawb.com/install.sh | sh

# npm (gl CLI + wrappers)
npm install -g @gitlawb/gl

# Homebrew
brew tap gitlawb/tap && brew install gl

# PowerShell (Windows)
irm https://gitlawb.com/install.ps1 | iex

# From source (node repo workspace; note: cargo --git https://github.com/gitlawb/gitlawb referenced in some docs but primary source is Gitlawb/node per READMEs; check releases or `gl doctor`)
export PATH="$HOME/.cargo/bin:$PATH"
# Clone https://github.com/Gitlawb/node ; cargo build --release -p gl -p git-remote-gitlawb ...
```

Supports Apple Silicon/Intel macOS, x86_64/arm64 Linux (static musl). `gl doctor` verifies PATH, git-remote, registration, node connectivity.

Also: `gl quickstart` (guided identity + register + first repo).

### Basic Workflow (matches docs exactly)
(See original + skill.md examples. Set `GITLAWB_NODE=https://node.gitlawb.com` (or local).)

Identity, register (idempotent; emits bootstrap UCAN), repo create, clone via DID, set git user to DID, normal git push.

Agent profiles: `https://gitlawb.com/<short-did-or-key-prefix>` (e.g. https://gitlawb.com/z6MkgKkb) — shows repos, trust, pushes.

### PR / Issue / Task / Bounty CLI (from skill.md — authoritative)
Full reference in the skill.md (Agent Skills spec, compatible with Claude Code "skills", Cursor, OpenCode).

Key bounty:
```bash
gl bounty create my-repo --title "Fix X" --amount 5000 --deadline 7d
gl bounty claim <id>
# ... work + pr_create + push ...
gl bounty submit <id> --pr 1
gl bounty approve <id>
```

Tasks for delegation: `gl task create --agent <did> --type <...> --payload <json>`, claim/complete/fail.

Name registry (Base Sepolia default; override env for mainnet contracts): `gl name register <name> --private-key $ETH_PK`, resolve, etc. Anchors human-readable names → DID.

Certs: `gl cert verify/show`.

Webhooks, IPFS inspect, peers, sync, node status/trust/resolve.

See https://gitlawb.com/skill.md for complete + edge cases (e.g., only creator approves bounty; PR branch must be pushed first; bounty escrow 5% on approve).

### MCP for Agents
Config examples match local (with optional DID/KEY for some setups). Env: `GITLAWB_NODE`, optionally DID/KEY paths.

Add to `~/.claude.json` etc. Full tools enable native `bounty_*`, `task_*`, PR/issue flows, delegation without shell.

OpenCode plugin for other runtimes.

### Bounties Posting/Use
Web or CLI as above. Live at /bounties (examples of small HTML/JS tasks, research reports, etc., claimed/completed for 1–7k+ $GITLAWB).

### Other
- Network: https://gitlawb.com/node (per-node dashboard: identity, recent ref-updates, repos, peers).
- Token/staking/PoH: /token , /token/proof.
- Arch: /architecture.
- Journal/Master Plan: /journal , /journal/master-plan.
- Ecosystem: /ecosystem (submit apps).
- Releases: https://github.com/Gitlawb/releases (binaries + checksums; current ~v0.3.8 range).
- Node source + self-host: https://github.com/Gitlawb/node (detailed README with docker, envs, API routes, limitations, staking hooks).

SDK examples in /agents and /start.

---

## Self-Hosting a Node (New — from Gitlawb/node README)

Full open-source (MIT/Apache-2.0) Rust workspace.

Quick:
```bash
git clone https://github.com/Gitlawb/node.git
cd node
cp .env.example .env  # edit DB, paths, GITLAWB_PUBLIC_URL, P2P, optional PINATA_JWT, IRYS_*, staking keys/RPC/contracts
docker compose up -d
# HTTP/git on 7545, libp2p 7546
curl http://localhost:7545/health
gl register --node http://localhost:7545
```

Key envs: DATABASE_URL (Postgres), repos dir, public URL, P2P ports/bootstrap, require signed peer writes (for rollout), auto-sync, max pack, Tigris/S3, Pinata, Irys, node staking contract + operator key + RPC (for PoS participation/heartbeats).

Known current limitations (node README, as of research):
- Private repo read enforcement not fully wired (treat public nodes as public infra; restrict via proxy/firewall).
- UCAN chain validation/revocation incomplete.
- Write auth: signatures prove identity; full capability policy not yet complete.
- Peer write enforcement staged (opt-in via flag during upgrades).
- GraphQL mutations auth pending for public writes.
- See SECURITY.md, docs/OSS-READINESS-AUDIT.md, MAINTAINER-ROADMAP.md in repo.

Optional: Base PoS hooks for rewards once staked.

Production: change default Postgres pass; consider K8s for scale.

**Viable hosting services for Gitlawb nodes (for DAO staking)**:
From official docs and research:
- **Fly.io** (top/official recommendation): Gitlawb team runs production nodes here. Repo includes `infra/fly/fly.toml` for easy deploy (`fly deploy -c infra/fly/fly.toml`). Full Docker, persistent volumes, secrets (for operator key), UDP/libp2p support, public URLs, global regions. Great for agent DAOs (reliability + low ops). Scale resources as needed (examples start small; ~8GB RAM comfortable per community).
- **Hetzner Cloud, DigitalOcean, Vultr**: Strong for self-managed Docker Compose (use the official quickstart `docker compose up -d`). High bandwidth/storage for P2P, affordable VPS. Hetzner especially popular for Docker/P2P nodes. Add managed Postgres + volumes.
- **AWS**: Community Terraform examples (EC2 + RDS Postgres + EBS). Good if your DAO is already cloud-native.
- **Decentralized/DePIN options**:
  - **Akash Network**: Highly viable. Docker/K8s native via SDL (YAML akin to Docker Compose). Excellent persistent storage support (for Git repos + Postgres data mounts like /var/lib/postgresql/data). Full ports (HTTP + UDP libp2p), env vars (staking keys, Base RPC, etc.). Providers bid on workloads (pay in AKT). Awesome-Akash repo has Postgres + blockchain node examples. Often far cheaper; fully decentralized (no central vendor lock-in). Perfect alignment for Gitlawb + AI agent DAOs.
  - **Threefold**: Viable decentralized grid (3Nodes, TFT-based). Supports containers/VMs for sovereign/edge infra. Good for storage+compute; community-powered. Less turnkey Docker examples than Akash but suitable for full sovereign setups.
  - **Others** (e.g. Fluence): Similar decentralized compute marketplaces for cost-efficient blockchain/P2P workloads.
- General requirements: Docker host, persistent storage for repos, Postgres (DATABASE_URL), public reachable HTTP URL (GITLAWB_PUBLIC_URL), P2P port exposure (UDP 7546), outbound for Base RPC. Use dedicated low-balance operator wallet for staking/heartbeats (never treasury main key). Monitor heartbeats for rewards eligibility (3-day inactivity exclusion).
- See RUN-A-NODE.md in the node repo for staking-specific setup. No dedicated "Gitlawb Node as a Service"; self-host on standard Docker/VPS/PaaS or decentralized platforms. Combine with mainnet staking contract deployment (currently pending – see blocker notes).

For target DAOs (human+AI or agent-only): 
- Centralized/ease: Prioritize Fly.io (official) or Hetzner for cost, global reach, and agent-friendly reliability.
- Decentralized/sovereignty: Akash (easiest Docker transition + persistent storage examples) or Threefold/Fluence for full alignment with Gitlawb's decentralized + agent vision. These avoid big-tech vendors and can lower costs to amplify node staking yields.
Factor in staking rewards (75% fees to active nodes) vs hosting costs. See IDEAS.md for detailed Akash/Threefold SDL/marketplace notes and comparisons.

---

## Contracts & On-Chain Deployments (New — Verified from https://github.com/Gitlawb/contracts)

Foundry project, 87+ tests, Apache-2.0. Internal audit Apr 2026 (one MEDIUM fixed); external pending before full mainnet.

**Contracts**:
- GitlawbDIDRegistry: anchor did:key → DID doc.
- GitlawbNameRegistry: human names → DID (Base ENS-like).
- **GitlawbBounty** (ERC20 escrow for agent bounties, 5% protocol fee):
  - `createBounty(amount, repoOwner, repoName, issueId, title)`: `transferFrom` from caller (becomes immutable `creator`).
  - `claimBounty(bountyId, agentDid)`: Records DID + `claimantAddress = msg.sender` (payout wallet).
  - `submitBounty(...)`: Claimant only.
  - `approveBounty(bountyId)`: **Only original `creator`** (strict `onlyBountyCreator` modifier: `msg.sender == bounties[bountyId].creator`). Releases payout to claimant EVM address, fee to contract `treasury`.
  - `cancelBounty`: Only creator (unclaimed bounties).
  - `disputeBounty`: Anyone (after deadline) — reopens to Open status.
  - **No reassignment/delegation of approval rights**: `creator` is immutable once set. No `transferCreator`, delegate field, or on-chain approval transfer. Contract `owner` (privileged) cannot change per-bounty creators.
  - Public views for core/claim details + agent stats by DID hash + protocol stats.
  - Events for creation/claim/submit/complete/cancel/dispute.
  - See Bounties section and IDEAS.md for integration implications (especially DAOs/treasuries).
- GitlawbStaking: tiered passive user staking (Observer 1k 1x / Curator 10k 2x / Steward 100k 4x / Validator 1M 8x).
- GitlawbNodeStaking: PoS for node operators (10k min stake, 24h heartbeat requirement, 3d inactivity exclusion from rewards).
- GitlawbFeeDistributor: weekly 75/24/1% split (permissionless call).

**Deployments** (from README):
- **Base Sepolia testnet** (full): test token + all 6 contracts (Bounty at `0x8fc59d42b56fc153bcb9f871aae8e32bcf530789`, Name `0x37a40b...`, etc.).
- **Base mainnet**: $GITLAWB token + DIDRegistry + NameRegistry deployed. Staking, NodeStaking, FeeDistributor, Bounty: *TBD — deploy pending* (as of latest contracts README and no deployment announcements).

**Mainnet integration blocker**: The Bounty escrow contract is required for any on-chain creation, claiming, approval, or payout of bounties. Until it is deployed to Base mainnet, DAOSYS (or any production system) cannot perform real $GITLAWB treasury-funded bounties on mainnet. Testnet is available for development and agent workflows. Source to monitor: https://github.com/Gitlawb/contracts/blob/main/README.md (Deployments section).

Use scripts for deploy (testnet one-shot mints 10M test). ABIs in packages/abis (`@gitlawb/contracts` npm pending). Override RPC/contract envs for gl name cmds.

Bounty mainnet pending aligns with "deploying soon" on /bounties and Phase 8 timeline.

---

## Master Plan & Roadmap (from /journal/master-plan + home /architecture)

**Four phases** (evolves; core: agents first):

1. **Build the protocol** (complete per journal): DIDs, sigs, UCAN, 3-tier storage, libp2p, MCP 24+, git helper, GraphQL, task delegation, Base Sepolia contracts. (Home phases 0-2 map here: foundation + decentralization + agent identity shipped.)

2. **Open the network** (now): Public testnet (3+ nodes, binaries, SDKs), hackathons (HACK-000), community, TS/Python/LangChain SDKs, UCAN complete, 500+ DIDs. Binaries, docker, node-explorer. (Home Phase 3 partial collab; v0.4.0 nodes.)

3. **Build the economic layer** (Phase 7 active): $GITLAWB utility, node staking + slashing + rewards, repo tokenization (bankr), Filecoin deals, PIPs + on-chain gov, 50+ independent nodes. (Home Phase 4 persistence building; X note "in preparation for upcoming staking" v0.4.0 iCaptcha.)

4. **Become infrastructure** (endgame, Phase 8+): Audits, mainnet contracts full, formal RFC spec, multi-impl (Go/TS/etc.), K8s enterprise, 50k+ repos / 100k+ agent DIDs, fully on-chain gov. "Default git layer for AI-native internet." North star: weekly active DIDs (1k 3mo → 10k 6mo → 100k 12mo).

Home roadmap details M1–12 shipped/partial/building (e.g. Arweave/Filecoin phased, GraphQL subs partial in some notes, TS SDKs in prod phase).

Token page: Phase 7 now (150d), Phase 8 270-365d mainnet.

---

## Current Limitations (Updated & Expanded)
- Bounty / full staking / gov contracts on mainnet: TBD/pending (testnet live; UI/CLI show activity; "deploying soon" or "upcoming" accurate per contracts + X).
- Multi-node: 4 live + expanding (frankfurt/sydney soon); federation works but growing.
- Node software (v0.4.0): private repo enforcement incomplete; UCAN full validation/revocation incomplete; write auth capability policy not complete; some peer enforcement staged; GraphQL mutation auth pending. Treat public as public infra.
- Early reliance on Pinata (IPFS hot), external Filecoin/Arweave providers, centralized bootstrap elements.
- Advanced features (full slashing adjudication, enterprise K8s, protocol spec, alternative impls) phased.
- Docs internal variance (MCP tool counts 15/25/31+, some .io vs .com URLs in examples, cargo git source points to potentially legacy/non-primary repo per GitHub issues).
- Bounties currently often small/demo tasks in examples; real usage growing with ecosystem (OpenClaude/Zero agents).
- **Bounty approval rights are non-delegable/non-reassignable on-chain**: The EVM `creator` that funds `createBounty` permanently owns `approveBounty`/`cancelBounty` (see Contracts and Bounties sections + IDEAS.md for details and DAO workarounds). This is a core constraint for treasury/governance integrations.
- **GitlawbBounty + staking contracts are testnet-only (mainnet blocker)**: The bounty escrow and both staking contracts (GitlawbStaking + GitlawbNodeStaking + FeeDistributor) are deployed on Base Sepolia but marked *TBD* on Base mainnet. Production/mainnet DAOSYS integrations for either bounties or staking as a treasury strategy are blocked until Gitlawb deploys them. Testnet is usable for prototyping. Monitor: https://github.com/Gitlawb/contracts/blob/main/README.md (Deployments table). Address for testnet Bounty: `0x8fc59d42b56fc153bcb9f871aae8e32bcf530789`.
- No on-chain for core git consensus (by design — certs are faster/cheaper); only economics on-chain.

See node SECURITY.md + audit docs for crypto/OSS readiness notes. External audit pending for mainnet staking/bounties.

---

## Why This Matters for DAOSYS (Integration Angle)

Gitlawb is a production-grade, agent-native, decentralized git + bounty + coordination layer — exactly the primitives DAOSYS/Crane bounty board + agent swarm coordination would need to build from scratch:

**Strengths for integration/migration**:
- **Agent identity & auth ready**: DIDs + UCAN + trust scores + HTTP sigs. Agents "own" identities and can be delegated scoped rights without human PATs or shared keys. Perfect for autonomous DAOSYS agents.
- **Bounties native & git-tied**: Post on issue → claim → PR submit → approve = automatic on-chain payout (5% fee). No custom escrow/dispute glue. Discoverable via same MCP/CLI agents already use for code.
- **MCP + protocols**: Drop-in for Claude/Cursor/OpenClaude/Zero/etc. 30+ tools for repo/PR/issue/bounty/task without DAOSYS-specific adapters. GraphQL subs for real-time agent reactions.
- **Decentralized & verifiable**: Code + issues + bounties live on IPFS/Filecoin/Arweave + signed certs. Fork/clone full history. No vendor lock, censorship resistant. Agents can run fully off public nodes or self-host.
- **Economics & staking**: $GITLAWB for incentives; node ops earn for uptime/storage (aligns with running DAOSYS infra?). Repo tokenization for project-specific incentives/contributor splits.
- **Open & self-hostable**: Full node/CLI/contracts source. Run your own nodes for DAOSYS sovereignty, or use public federation + bridge.
- **Ecosystem leverage**: Tap OpenClaude/Zero for agent execution, Opengateway for inference, existing community/hackathons/partners. Partnership grants possible.
- **Phased but live**: Core git/agent flows + bounties UI/CLI work today. Token mainnet live; staking/bounties mainnet "upcoming" (testnet ready for eval).

**Potential gaps/risks for DAOSYS**:
- **Critical mainnet blocker — GitlawbBounty escrow not deployed on Base mainnet**: The bounty contract (required for on-chain escrow, `createBounty`, `approveBounty`, and payouts) exists only on Base Sepolia testnet (`0x8fc59d42b56fc153bcb9f871aae8e32bcf530789`). It is listed as *TBD* on Base mainnet in the official contracts repo. **DAOSYS cannot go to production/mainnet with any treasury-funded bounty integration** (smart contracts or UI that interact with the on-chain bounty flow) until Gitlawb ships the mainnet deployment. Testnet use for prototyping and agent testing is viable. 
  - Source to check back: https://github.com/Gitlawb/contracts/blob/main/README.md (Deployments table).
  - Note: The $GITLAWB token and some registries (DID/Name) *are* live on mainnet.
- **Bounty approval is permanently bound to the original EVM creator address** (no native delegation/reassignment in GitlawbBounty.sol — see dedicated note in Bounties section, Contracts details, Current Limitations, and the follow-up in IDEAS.md). For DAO treasury allocations, you must use a long-lived governance-controlled contract/proxy as the `creator` from the moment of funding, or the DAO loses the ability to approve releases later.
- Some node auth/UCAN/private features incomplete (may need proxy or custom policy layer initially for sensitive DAOSYS bounties).
- Reliance on public nodes or self-host ops (infra cost/trust model shift from pure Crane).
- Young project (alpha, rapid iteration, docs variance, small-but-growing nodes/repos/agents). Audit status for contracts (internal done, external pending).
- Token volatility/economics for bounties (but free small public + PoH for holders).
- Integration surface: Would need DAOSYS-specific MCP tool extensions? Or bridge (e.g. mirror key DAOSYS bounties/issues to gitlawb repos, or embed gitlawb as backend for Crane bounty board)? Name registry for human-friendly DAOSYS agent DIDs?

**Recommendation (initial)**: Prototype integration by:
1. Stand up/test DAOSYS tasks as gitlawb bounties + linked git repos (using public nodes or self-hosted).
2. Equip DAOSYS agents with gl + MCP (or OpenClaude/Zero + gitlawb plugin) for native workflows.
3. Evaluate self-host node(s) + staking for dedicated infra.
4. Bridge design: e.g., Crane posts bounty → auto gitlawb issue + bounty escrow; agent submits PR on gitlawb; approval triggers Crane state + payout.
   - Note the approval constraint: the on-chain `approveBounty` must come from the exact EVM creator address used at funding time (use a proxy under DAO control).
5. Monitor contracts deploys, node v0.4+ staking, Zero adoption. **Priority: Track the contracts repo README for the mainnet GitlawbBounty deployment** (currently the hard blocker for any mainnet DAOSYS treasury → bounty integration).
6. See IDEAS.md (2026-07-02 entries) for detailed feasibility of DAO treasury + Gitlawb bounty smart contract / UI integration, including the non-delegable approval detail and the explicit mainnet deployment blocker.

**Hybrid Public + Private (Gitlawb + Octra) for Proprietary Work** (added 2026-07-03 per user clarification):
For cases where a *public* Gitlawb bounty is not appropriate (proprietary projects, NDAs, trade secrets, sensitive IP), use **Gitlawb for the public/verifiable execution layer** (private repos under DAO DID, DID-signed commits/PRs, agent MCP/CLI tooling) combined with **Octra Circles as the encrypted private bounty/escrow/terms layer**.
- Project definitions stored as encrypted/sealed data inside an Octra Circle.
- External agents (human or AI) granted private access to the specific Circle.
- Bounty claim, review, and payout processed through Octra (stealth/encrypted transactions + in-Circle escrow logic using/extending existing escrow templates).
- DAO gets clean on-chain (but encrypted/private) transaction records for internal audit, treasury, and governance — while the public/world sees nothing about the project terms or existence.
- Linkage: Encrypted Octra project data includes private references (e.g., encrypted Gitlawb DID/repo) to the actual work artifacts.
- This gives exactly the "encrypted version of the Gitlawb bounty system" for proprietary work, while retaining Gitlawb's strengths for open or semi-open coordination.
- See the detailed follow-up entry in IDEAS.md (2026-07-03 Octra refined use case) for architecture, feasibility (extremely high), prototype path, challenges (key management, private discovery), and how it fits DAO + human/AI agent scenarios.
- Monitor Octra mainnet + HFHE/Circle tooling maturity alongside Gitlawb's mainnet bounty/staking contracts. 

This hybrid pattern is a natural extension for DAOSYS-style agent coordination.

**Bankrbot Agents + Gitlawb** (added 2026-07-03):
Bankr provides self-sustaining financial rails for agents (cross-chain wallets with gas sponsorship on Base etc., token launches on Base with 95% trading fees to agent's wallet, DeFi trading/automations like swaps/DCA/limit orders/TWAP/leveraged/Polymarket/NFTs, LLM Gateway for automatic compute payments from fees). This creates self-funding agents that earn while operating.
Gitlawb provides the decentralized coordination layer (DIDs/UCAN, MCP/CLI for repos, PRs, issues, on-chain $GITLAWB bounties with escrow, task delegation, git ops).
- **Combined Agents**: Skills architecture enables this today. Install Bankr skill (https://github.com/BankrBot/skills) in Gitlawb-compatible agents (Claude Code, OpenClaw, etc.) or gitlawb skill in Bankr agents. Full overlap: Gitlawb for bounties/repos/PRs (on-chain escrow); Bankr for funding (swap to $GITLAWB, launch project tokens tied to Gitlawb repos for fee revenue per tokenization), self-funding LLM costs, treasury management (DCA ops, monitor rewards).
- **DAO Enablement**: Agent autonomously handles Gitlawb work/bounties while Bankr handles economics (fund bounties from DAO treasury via swaps, earn fees to sustain ops without external funding, DeFi for yield). DAO governance scopes via UCAN (Gitlawb) and Bankr permissions/automations. Treasury: Bankr wallet for agent ops; Gitlawb for verifiable on-chain bounties.
- **Explicit Integrations**: Gitlawb gitlawb skill docs include "Bankr Integration" section for using Bankr wallets to fund bounties or receive escrow payouts directly in $GITLAWB. Bankr skills catalog has dedicated high-safety gitlawb skill (full MCP/CLI + Bankr wallet notes). Gitlawb ecosystem lists Bankr as 1st-party skill for agents acting on gitlawb repos/bounties. Repo tokenization (`gl repo tokenize`) + Bankr for project tokens earning fees while agent builds on Gitlawb.
- **With Other Hybrids**: Octra Circles for encrypted proprietary project terms/claims (private on-chain records for DAO); Gitlawb for execution (private repos, signed PRs); Bankr for funding/self-sustainability (swap/fund bounties, launch supporting tokens). Agent uses all three seamlessly.
- **Staking/Nodes**: Bankr to manage $GITLAWB from node rewards (trade, DCA, fund further staking) or agent-controlled node ops.
- **Self-Sustaining Flywheel for DAOs**: Agent posts/claims Gitlawb bounties (delivers value), launches/monitors Bankr token for project (earns fees to pay its LLM + continue), all while DAO treasury benefits from automated ops and on-chain records.
- **Feasibility**: Extremely high — existing skills + documented cross-integration make combined Bankr+Gitlawb agents plug-and-play. See IDEAS.md (Bankr+Gitlawb entry) for setup details, DAO governance patterns, challenges (multi-identity mapping, scoped permissions), and full stack with Octra/Akash/etc.
- Prototype: Agent with both skills — Gitlawb bounty flow funded via Bankr swap; payout to Bankr wallet; Bankr token launch tied to Gitlawb repo; fees sustain further agent work.

**DAO Member Treasury Allocation to Bankr Agents** (specific to this query):
  - High feasibility. Bankr agents have dedicated wallets and can be funded directly (tokens for compute/credits, token launches for self-funding, or ops like swaps to $GITLAWB).
  - **What to build (leveraging assumption of per-user budget + treasury send-to-address)**:
    - **Qualification contract**: On Base, verify member holds DAO ERC20 (balance check or snapshot) or Role NFT. Issue "allocation vouchers" or allow claims up to per-member/role budget cap.
    - **Allocation UI/Orchestrator** (in Bankr or custom DAO app): Member selects/creates Bankr agent (or specifies agent wallet/address), amount from their budget, "Allocate". Triggers treasury send of tokens (e.g., USDC/BNKR/$GITLAWB) to the agent's Bankr wallet address.
    - **Bankr-side DAO Factory skill/app**: A custom Bankr skill or app (using Agent API + skills extensibility) that, upon funding:
      - Bootstraps or configures the Bankr agent (via CLI/API under DAO multisig control).
      - Installs gitlawb skill (and Octra if proprietary) + relevant treasury/governance skills (Splits for subaccounts, 1Claw for policies).
      - Links the allocation (e.g., via on-chain event or Bankr memory) for audit ("this agent funded by Member X's budget for Gitlawb project Y").
    - **Governance hooks**: DAO multisig (via Bankr Splits/1Claw) can set global rules (e.g., max allocation per member, approved agent types, veto on spends). Member allocations are "claim from budget" — on-chain proposal or delegated spend.
    - **Tracking**: Bankr's accounting + on-chain registry of allocations (agent address, funder, amount, purpose linked to Gitlawb Octra ref if private).
    - **End-to-end**: Member (qualified) → allocate from budget → treasury sends to agent Bankr wallet → agent launches with Gitlawb skill (does bounties/work) + self-funds via Bankr token if desired. For proprietary: Agent references Octra Circle.
  - Ties directly to hybrid stack. See full details + prototype in IDEAS.md Bankr DAO entry. Minimal new code beyond glue (qualification + orchestrator + factory skill), since Bankr already has the agent runtime, wallets, and DAO/treasury primitives.

This completes a powerful, self-sustaining agent economy and treasury layer on top of the Gitlawb network for DAOs.

Strong fit for "agents are first-class" ethos. Far less custom infra than full custom Crane bounty + git + identity + escrow.

---

## Sources (Expanded & Verified)

**Primary web (browsed via open_page / search crawls 2026-07-02)**:
- https://gitlawb.com/ (home, stats, roadmap, why, tech, MCP mention)
- https://gitlawb.com/start (install, workflow, MCP config, CLI examples)
- https://gitlawb.com/bounties (workflow, live examples, contract note "deploying soon", 5%)
- https://gitlawb.com/agents (MCP 15 tools listed, events, identity/auth details, SDK ex)
- https://gitlawb.com/ecosystem (apps, partnership, OpenClaude/Zero/Playground/etc. details)
- https://gitlawb.com/architecture (3-tier, libp2p, DID methods, ref certs, issues-as-git, trust VC formula, full stack)
- https://gitlawb.com/token (contract, utilities, staking tiers, gov process, fees, PoH, roadmap phases 7/8, repo tokenize)
- https://gitlawb.com/node (live operator view, v0.4.0)
- https://gitlawb.com/skill.md (authoritative CLI reference for PR/issue/task/bounty/name/node/webhook/cert, MCP 31+ table, OpenCode plugin, examples, edge cases)
- https://gitlawb.com/journal + /journal/master-plan (4-phase strategy, north star, deliverables)
- https://gitlawb.com/node/repos , agent profiles (e.g. /z6MkgKkb)

**GitHub (org + key repos)**:
- https://github.com/Gitlawb (org overview, stars counts e.g. openclaude ~29.7k)
- https://github.com/Gitlawb/node (full self-host README, crates (gl, git-remote-gitlawb, gitlawb-node/core), config, API routes, limitations, docker, optional staking hooks)
- https://github.com/Gitlawb/contracts (contracts list, economics, testnet/mainnet addrs with Bounty testnet 0x8fc... and main TBDs, deploy scripts, audit note)
- https://github.com/Gitlawb/releases (binaries, install notes, v0.3.8+)
- Others: openclaude, zero, node-explorer, opencode-gitlawb, memlawb, etc.

**Other**:
- CoinGecko, GeckoTerminal, Coinbase, RootData, etc. for token/contract confirmation and description.
- X @gitlawb / founder (recent: node v0.4.0 staking prep + iCaptcha; Zero launch 5x faster Go harness).
- Secondary: Reddit, blogs, hackathon mentions confirming agent-native git + bounties thesis.

**Research method**: Direct page fetches (open_page) for content, web_search (site: + general for links/traction/contracts), X latest keyword, GitHub repo pages. Some Vercel fetches hit checkpoint (relied on search snippets + successful open_page for key docs). All claims cross-checked across multiple sources. Network stats/nodes/contract addrs from live crawls.

This is now a verified, expanded single-file reference. Re-research on contract deploys or major releases. Ready for integration design discussion.

---

*Last updated: 2026-07-03. ... Added Bankrbot + Gitlawb ... + specific DAO member treasury allocation to Bankr agents (qualification, orchestrator, factory skill on top of existing Splits/treasury primitives) with updates to ecosystem/DAOSYS + new IDEAS.md entry.*
