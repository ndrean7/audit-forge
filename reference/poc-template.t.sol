// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

/// @notice PoC template. Copy this file per finding, rename the test,
/// and fill in the three sections. A PoC must fail before the fix and
/// pass after it — run it against both.
/// @dev Runs locally in Foundry. No mainnet fork, no real transactions.
contract PoCTemplate is Test {
    // --- 1. SETUP: deploy the target from a clean state ---
    function setUp() public {
        // Deploy the contracts under review here.
        // Use fresh deploys, never a live address.
    }

    // --- 2. ATTACK: execute the suspected exploit ---
    // Attack from an unprivileged address where the finding claims
    // an unprivileged attacker. Keep the attack minimal.
    function test_PoC() public {
        // Arrange: fund the attacker, set up the vulnerable state.
        // Act: perform the attack (one transaction, or a short sequence).
        // Assert: the exact bad outcome, with a number.
        //
        // Example assertions:
        //   assertEq(attackerBalanceAfter - attackerBalanceBefore, <expected stolen>);
        //   assertEq(victimBalanceAfter, 0);
        //   assertEq(target.feeReceiver(), attacker);
    }
}
