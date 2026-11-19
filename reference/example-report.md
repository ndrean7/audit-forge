# Worked example — synthetic vault audit

Everything in this file is synthetic, written for teaching. The
contracts below are not a real protocol, and the findings are not
reports against any real program. They show the shape a real report
takes: scope, findings with PoC, a killed lead, and the closing
statement.

## Scope

- Repository: `example/vault` (synthetic, written for this example)
- Commit: `example-1` (no real repository)
- In scope: `SimpleVault.sol`, `FeeCollector.sol`
- Out of scope: deployment scripts, tests

## Finding 1 — High: reentrancy drains the vault

**Location:** `SimpleVault.sol`, `withdraw()`

**Description.** `withdraw()` sends Ether with a low-level call and only
then zeroes the caller's balance. A caller contract re-enters
`withdraw()` from its `receive()` function while its balance is still
recorded, and withdraws again — and again — until the vault is empty.

```solidity
// SimpleVault.sol (synthetic, vulnerable on purpose)
contract SimpleVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "send failed");
        balances[msg.sender] = 0; // too late: the call above already returned control
    }
}
```

**Impact.** Any depositor can drain the vault's entire balance, not just
their own deposit. In the PoC, an attacker depositing 1 ETH withdraws
10 ETH from a vault holding 10 ETH.

**Proof of concept.** `PoC_VaultReentrancy.t.sol`: an attacker contract
deposits 1 ETH, calls `withdraw()`, and re-enters from `receive()` until
the vault is empty. Assertion: attacker balance gain is 10 ETH, vault
balance is 0. Test passes against the code above.

**Recommendation.** Follow checks-effects-interactions: zero the
balance before the external call, or add a reentrancy guard.

**Status:** verified (PoC passes).

## Finding 2 — Medium: fee collector has no access control

**Location:** `FeeCollector.sol`, `setFeeReceiver()`

**Description.** `setFeeReceiver()` changes where protocol fees go, but
has no access check. Anyone can point future fees at their own address.

```solidity
// FeeCollector.sol (synthetic, vulnerable on purpose)
contract FeeCollector {
    address public feeReceiver;

    function setFeeReceiver(address next) external {
        feeReceiver = next; // no access control
    }

    function collect() external payable {
        (bool ok, ) = feeReceiver.call{value: address(this).balance}("");
        require(ok, "send failed");
    }
}
```

**Impact.** All future fee payouts go to the attacker's address. No
existing funds are taken, and the owner can change it back — so Medium,
not High.

**Proof of concept.** `PoC_FeeReceiver.t.sol`: a random address calls
`setFeeReceiver(attacker)` and the test asserts `feeReceiver` equals the
attacker. Test passes.

**Recommendation.** Restrict `setFeeReceiver()` to the owner role, and
use a two-step change for a payment address.

**Status:** verified (PoC passes).

## Killed lead — not a bug

**Lead:** `SimpleVault.deposit()` accepts Ether from anyone, so an
attacker could "donate" to inflate the vault and break share math.

**Why it died:** the vault tracks balances per depositor and pays out
only recorded balances. A donation changes no one's recorded balance
and no payout. No PoC could show a loss, so the lead was closed with
this reason recorded.

## Closing statement

Scope: `SimpleVault.sol` and `FeeCollector.sol` at commit `example-1`.
Two findings (one High, one Medium), both PoC-verified. One killed lead
recorded above. This audit reduces risk; it does not certify the
contracts as safe.
