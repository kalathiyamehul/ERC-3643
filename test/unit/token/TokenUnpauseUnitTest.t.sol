// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.31;

import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { RolesLib } from "contracts/libraries/RolesLib.sol";

import { TokenBaseUnitTest } from "./TokenBaseUnitTest.t.sol";

contract TokenUnpauseUnitTest is TokenBaseUnitTest {

    function testTokenUnpauseRevertsWhenNotAgent(address caller) public {
        (bool isAgent,) = accessManager.hasRole(RolesLib.AGENT_PAUSER, caller);
        vm.assume(!isAgent);

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, caller));
        vm.prank(caller);
        token.unpause();
    }

    function testTokenUnpauseRevertsWhenNotPaused() public {
        vm.prank(agent);
        token.unpause();

        vm.expectRevert(ErrorsLib.ExpectedPause.selector);
        vm.prank(agent);
        token.unpause();
    }

    function testTokenUnpauseNominal() public {
        address account = agent;

        vm.expectEmit(true, true, true, true, address(token));
        emit PausableUpgradeable.Unpaused(account);
        vm.prank(agent);
        token.unpause();

        assertFalse(token.paused());
    }

    function testTokenUnpauseRevertsWhenDisablePauseRestrictionIsSet() public {
        accessManager.revokeRole(RolesLib.AGENT_PAUSER, agent);

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, agent));
        vm.prank(agent);
        token.unpause();
    }

}
