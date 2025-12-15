// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.31;

import { console } from "@forge-std/console.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { RolesLib } from "contracts/roles/RolesLib.sol";

import { TokenBaseUnitTest } from "./TokenBaseUnitTest.t.sol";

contract TokenPauseUnitTest is TokenBaseUnitTest {

    function setUp() public override {
        super.setUp();

        vm.prank(agent);
        token.unpause();
    }

    function testTokenPauseRevertsWhenNotAgent(address caller) public {
        (bool isAgent,) = accessManager.hasRole(RolesLib.AGENT_PAUSER, caller);
        vm.assume(!isAgent);

        vm.expectPartialRevert(IAccessManaged.AccessManagedUnauthorized.selector);
        vm.prank(caller);
        token.pause();
    }

    function testTokenPauseRevertsWhenAlreadyPaused() public {
        vm.prank(agent);
        token.pause();

        vm.expectRevert(ErrorsLib.EnforcedPause.selector);
        vm.prank(agent);
        token.pause();
    }

    function testTokenPauseNominal() public {
        address account = agent;

        vm.expectEmit(true, true, true, true);
        emit PausableUpgradeable.Paused(account);
        vm.prank(agent);
        token.pause();

        assertTrue(token.paused());
    }

    function testTokenPauseRevertsWhenDisablePauseRestrictionIsSet() public {
        accessManager.revokeRole(RolesLib.AGENT_PAUSER, agent);

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, agent));
        vm.prank(agent);
        token.pause();
    }

}
