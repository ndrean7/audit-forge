# Listing — Audit Forge (Agensi)

Copy siap pakai waktu upload ke Agensi. Free v1 — gratis supaya cepat
dapat pemakai.

## Title

Audit Forge

## Tagline

Find the bug before the hacker does — manual review, PoC-verified findings, severity-rated report.

## Description

One missed bug can drain a protocol. A reentrancy hole, an access
check nobody wrote, an oracle that trusts a stale price — each one has
cost real protocols real money, and each one is the kind of thing a
careful review catches before launch.

Give Audit Forge a Solidity codebase and it runs a real security audit,
the way a human auditor works: freeze the scope at a pinned commit, map
the architecture and the value flows, review the code by hand against a
vulnerability checklist, write the protocol's invariants, and prove
every finding with a Foundry proof of concept that runs locally — no
mainnet transactions, no wallet, no private key. You can re-run every
PoC yourself and watch the bug happen.

A finding only counts when it can be reproduced. A suspected bug no PoC
can trigger is written up as unverified, with the exact precondition it
depends on — never as a confirmed bug. A killed lead is recorded too,
with the reason it died, so no one wastes time re-checking a dead path.

Each finding is rated by impact and likelihood (Critical / High /
Medium / Low / Informational) and written up with location, impact, a
reproducible PoC and a fix suggestion. The report closes with the scope,
the killed leads, and the honest statement that an audit reduces risk —
it never certifies a contract as safe.

What it checks: reentrancy, access control, oracle manipulation,
rounding and precision, signature replay, upgradeability and proxies,
unchecked external calls, denial of service and griefing, front-running,
economic invariants, and centralization risk.

Built from real audit practice — scoped reviews, PoC-verified findings,
severity-rated reports — not from a template.

What it does not do: it never promises a bug will be found, and it
never promises a bounty. Bug bounties pay only for valid, first-reported
bugs — a review may find nothing, and that is a valid result.

## Category

Security

## Tags

smart-contract-audit, solidity, security, foundry, bug-bounty,
vulnerability, poc

## Price

Free

## What buyers get

- A scoped audit at a pinned commit: in-scope / out-of-scope recorded,
  so the review covers exactly what was agreed
- Manual review against a full vulnerability checklist — not just a
  scanner dump
- Foundry PoC for every finding, run locally (no mainnet transactions)
  — re-run it yourself and watch the bug happen
- Severity-rated findings report with location, impact, PoC and fix
  suggestion — ready to hand to a developer or a bounty program
- Killed leads recorded, so no path is checked twice blindly
- Fix verification: re-run the PoC against fixed code and confirm the
  attack no longer works

## Example session

User: "Audit this vault before launch."

The skill freezes the scope (repo + commit), reads the entry points,
and finds the withdraw function updates the balance after the external
call. It writes a Foundry PoC: an attacker contract re-enters, drains
the vault, and the test asserts the exact drained amount — 1 ETH in,
10 ETH out, vault left at 0. Finding: High — reentrancy, PoC passing,
fix suggested (checks-effects-interactions). A second suspicion — an
admin-only function with no access check — is confirmed the same way
and rated Medium. A third lead dies in the PoC and is recorded as
killed, with the reason. The buyer gets a report they can hand straight
to a developer: what breaks, where, how bad, proof it happens, and how
to fix it. Full example in `reference/example-report.md`.
