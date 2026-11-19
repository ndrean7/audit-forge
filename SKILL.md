---
name: audit-forge
description: A Foundry-first smart contract auditor — scope a Solidity codebase at a pinned commit, review it by hand against a vulnerability checklist, prove every finding with a local Foundry PoC, and write a severity-rated report. An audit reduces risk; it never certifies a contract as safe.
summary: Find the bug before the hacker does — manual review, PoC-verified findings, severity-rated report.
version: 1.0.0
tags:
  - security
  - solidity
  - audit
  - foundry
  - bug-bounty
keywords:
  - smart contract audit
  - solidity security review
  - foundry poc
  - vulnerability
  - severity report
use_cases:
  - Audit a Solidity codebase before mainnet launch
  - Triage a static-analysis report into real findings
  - Verify a fix from a previous audit
  - Prepare a bug bounty submission with a PoC
hosts: []
docs_url: https://github.com/ndrean7/audit-forge
---

# Audit Forge

## Name

audit-forge

## Description

Give it a Solidity codebase and it runs a structured security audit —
the kind that catches the bug before launch, when fixing it is still
cheap. One missed bug can drain a protocol: a reentrancy hole, an
access check nobody wrote, an oracle that trusts a stale price. The
skill works the way a human auditor works: freeze the scope at a
commit, map the architecture and value flows, review the code by hand
against a vulnerability checklist, write protocol invariants, and prove
every finding with a Foundry proof of concept that runs locally — no
mainnet transactions, no testnet transactions. Each finding is rated by
impact and likelihood (Critical / High / Medium / Low / Informational) and
written up with location, impact, a reproducible PoC and a fix suggestion.

A finding only counts when it can be reproduced. A suspected bug that no PoC
can trigger is written up as unverified, with the exact precondition it
depends on — never as a confirmed bug. A killed lead is recorded too, with
the reason it died, so the same path is not re-checked blindly later.

An audit reduces risk; it never certifies a contract as safe, and the report
says so. Bug bounties pay only for valid, first-reported bugs — there is no
guarantee a review finds one, and this skill never promises it will.

## How it works

1. **Freeze the scope.** Record the repository, the commit hash, the
   in-scope files and the out-of-scope files. Nothing outside the frozen
   scope is reported. If the code changes mid-audit, re-freeze and say so.
2. **First pass.** Read the entry points, map the architecture: who can
   call what, where value enters and leaves, which roles exist, which
   invariants the protocol claims. Note trusted assumptions (admin keys,
   oracles, keepers) as assumptions, not as findings.
3. **Static analysis.** Run Slither and Aderyn if available and triage
   their output — a static-analysis warning is a lead, never a finding on
   its own.
4. **Manual review.** Work the checklist in
   `reference/vulnerability-catalog.md`: reentrancy, access control,
   oracle manipulation, rounding and precision, signature replay,
   upgradeability and proxies, unchecked external calls, denial of
   service and griefing, front-running, economic invariants, and
   centralization risk.
5. **Invariants.** Write the protocol's invariants as Foundry invariant
   tests where they can be stated precisely (for example: "a user's
   recorded balance never exceeds what they deposited minus what they
   withdrew").
6. **Prove it.** For each suspected bug, write a Foundry PoC test in a
   local workspace (see `scripts/audit-init.sh`) that reproduces it. A
   finding ships only with a passing PoC; without one it is marked
   unverified with its precondition.
7. **Rate and report.** Rate each finding by impact × likelihood, write
   it up in the report format, and close with the scope, the killed
   leads, and the statement that the audit does not certify safety.

## Instructions

### Start an audit

```sh
# From the skill directory. Creates a local workspace (no network, no chain):
sh scripts/audit-init.sh /path/to/repo-copy <commit>
```

Then work inside the workspace it creates. Read the code there — never
edit the original repository. All PoCs live in the workspace's `test/`
directory and run with `forge test`.

### Scoping questions to answer first

- Which repository and commit? Which files are in scope, which are out?
- What does the protocol do, in one paragraph, in the user's own words?
- Who are the actors (user, keeper, admin, oracle, solver) and what can
  each one do?
- Where does value enter and leave? Which functions move funds?
- What is explicitly trusted (multisig, oracle, backend)?

If any answer is missing, ask before reviewing — do not assume it.

### The review pass

Read every in-scope file end to end, in dependency order (entry points
first, then the contracts they call). For each function, ask:

- Who can call this, and what stops anyone else?
- What state changes before any external call, and what changes after?
- Which values come from a caller, a signature, or an oracle — and what
  happens if they are stale, extreme, or chosen by an attacker?
- Which arithmetic can round the wrong way, and who gains from the
  rounding?
- What happens on the second call, the reverted call, the call with no
  funds left?

Record every suspicion as a lead with file, line, and a one-line
hypothesis. Do not promote a lead to a finding until the PoC runs.

### Writing a PoC

Use the template in `reference/poc-template.t.sol`. A PoC test must:

- Set up the vulnerable state from a clean deploy (no mainnet fork
  unless the user explicitly provides an RPC URL and the finding needs
  deployed state).
- Execute the attack from an unprivileged address where the finding
  claims an unprivileged attacker.
- Assert the exact bad outcome (funds moved, credit granted, check
  bypassed) with a number, not a feeling.
- Run green with `forge test` in the local workspace.

If the PoC fails, the lead is dead or its precondition is missing: record
it as a killed lead with the reason, and move on.

### Severity rating

| Severity | Meaning |
| --- | --- |
| Critical | Direct loss of user funds, or full protocol compromise, reachable by an unprivileged caller |
| High | Loss of funds or a broken core invariant, with a realistic path to reach it |
| Medium | Loss under a precondition (a role, a config, a second bug) or a partial loss |
| Low | Minor loss, griefing, or a broken assumption with limited impact |
| Informational | No direct loss, but worth fixing (stale data, missing expiry, unclear code) |

Rate by impact first, then likelihood. A dramatic bug that needs an
impossible precondition is Medium at most — and its precondition is
written in the finding.

### Report format

One finding per section, in this order:

1. **Title** — what breaks, in one line.
2. **Severity** — Critical / High / Medium / Low / Informational.
3. **Location** — file and function, with the commit hash.
4. **Description** — what the code does and why it is wrong.
5. **Impact** — who loses what, with numbers where possible.
6. **Proof of concept** — the PoC test file and the key assertion.
7. **Recommendation** — the smallest fix that closes the hole.
8. **Status** — verified (PoC passes) or unverified (precondition noted).

Close the report with: scope (repo, commit, in/out), the killed leads,
and the sentence: "This audit reduces risk; it does not certify the
contracts as safe."

### Worked example

See `reference/example-report.md`: a synthetic vault reviewed end to end —
two findings (one High reentrancy with a passing PoC, one Medium access
control issue), one killed lead, and the closing statement. The example
contracts are written for teaching; they are not a real protocol.

### Answering questions

- **"Audit this repo."** — Freeze the scope first (repo + commit +
  in/out), then run the passes in order. Do not skip scoping.
- **"Is this a bug?"** — Answer only after a PoC. Before that it is a
  lead, and say so.
- **"How bad is it?"** — Rate by the table above, with the precondition
  written out. Never inflate a severity to make the report look better.
- **"Can you check this fix?"** — Re-run the PoC against the fixed code:
  it must fail (the attack no longer works), and the repo's own tests
  must still pass.
- **"Will this win a bounty?"** — Say plainly: bounties pay only for
  valid, first-reported bugs, and a review may find nothing. No promise.

## Rules — do not break these

- **Every finding needs a PoC, or it is marked unverified.** Never
  present a suspicion as a confirmed bug.
- **No mainnet or testnet transactions.** All PoCs run locally in
  Foundry. Never ask for a private key, seed phrase, or wallet
  connection, and never sign or send a transaction.
- **Never guarantee safety or a bounty.** An audit reduces risk; it
  never certifies a contract as safe. A review may find nothing, and
  that is a valid result.
- **No copied findings.** Findings come from reading this codebase, not
  from another audit, another entry, or a public report. Prior audits of
  the same code are read to avoid duplicates, and any overlap is
  disclosed as a known issue, not reported as new.
- **No false claims.** Never claim a result, a payout, or a program's
  endorsement that did not happen. If a program is named, it is named
  as the audit target, never as an endorsement.
- **Scope is frozen.** Do not report files outside the frozen scope, and
  do not silently move the commit.
- **Original work.** This skill is the author's own methodology (MIT,
  © 2026 ndrean7), written from the author's own audit practice and
  general security knowledge. It is not copied from any other skill,
  course, or audit report.

## Requirements

- Foundry (`forge`, `cast`) for PoCs and invariant tests.
- Slither and Aderyn for static analysis (optional but recommended).
- A local copy of the target repository at a pinned commit.
- No network access is required for the review itself; a mainnet fork
  is used only when the user explicitly provides an RPC URL.
