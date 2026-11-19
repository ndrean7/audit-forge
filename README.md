# Audit Forge

A Foundry-first smart contract auditor. Scope a Solidity codebase at a
pinned commit, review it by hand, prove every finding with a local
Foundry PoC, and write a severity-rated report.

## What it does

- Freezes the audit scope (repo + commit, in/out of scope)
- Reviews code by hand against a vulnerability checklist
- Writes protocol invariants and tests them in Foundry
- Proves each finding with a reproducible PoC — no mainnet transactions
- Rates findings Critical / High / Medium / Low / Informational
- Records killed leads so no path is checked twice blindly

## What it does not do

- It never certifies a contract as safe. An audit reduces risk.
- It never promises a bug will be found, or a bounty will be paid.
  Bug bounties pay only for valid, first-reported bugs.

## Contents

- `SKILL.md` — the skill: methodology, instructions, rules
- `LISTING.md` — copy-paste listing text for Agensi
- `reference/vulnerability-catalog.md` — the review checklist
- `reference/example-report.md` — a worked example on synthetic contracts
- `reference/poc-template.t.sol` — Foundry PoC test template
- `scripts/audit-init.sh` — scaffold a local audit workspace

## Quick start

```sh
sh scripts/audit-init.sh /path/to/repo-copy <commit>
# work inside the workspace it creates, run PoCs with: forge test
```

## Requirements

Foundry (`forge`, `cast`). Slither and Aderyn recommended for static
analysis. No network access needed for the review itself.

## License

MIT © 2026 ndrean7. Original work: the author's own audit methodology,
written from the author's own audit practice and general security
knowledge.
