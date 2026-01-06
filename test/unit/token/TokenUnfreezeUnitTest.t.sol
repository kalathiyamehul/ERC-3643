// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import { ERC3643EventsLib } from "contracts/ERC-3643/ERC3643EventsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { RolesLib } from "contracts/libraries/RolesLib.sol";

import { TokenBaseUnitTest } from "./TokenBaseUnitTest.t.sol";

contract TokenUnfreezeUnitTest is TokenBaseUnitTest {

    address user = makeAddr("User");
    uint256 mintAmount = 1000;
    uint256 freezeAmount = 500;

    function setUp() public override {
        super.setUp();

        vm.startPrank(agent);
        token.unpause();
        token.mint(user, mintAmount);

        token.freezePartialTokens(user, freezeAmount);
        vm.stopPrank();
    }

    function testTokenUnfreezePartialTokensRevertsWhenNotAgent(address caller) public {
        vm.assume(caller != agent);

        vm.expectPartialRevert(IAccessManaged.AccessManagedUnauthorized.selector);
        vm.prank(caller);
        token.unfreezePartialTokens(user, freezeAmount);
    }

    function testTokenUnfreezePartialTokensRevertsWhenAmountAboveFrozen() public {
        uint256 unfreezeAmount = freezeAmount + 1;

        vm.expectRevert(
            abi.encodeWithSelector(ErrorsLib.AmountAboveFrozenTokens.selector, unfreezeAmount, freezeAmount)
        );
        vm.prank(agent);
        token.unfreezePartialTokens(user, unfreezeAmount);
    }

    function testTokenUnfreezePartialTokensNominal() public {
        uint256 unfreezeAmount = 200;

        vm.expectEmit(true, true, true, true);
        emit ERC3643EventsLib.TokensUnfrozen(user, unfreezeAmount);

        vm.prank(agent);
        token.unfreezePartialTokens(user, unfreezeAmount);

        assertEq(token.getFrozenTokens(user), freezeAmount - unfreezeAmount);
    }

    function testTokenBatchUnfreezePartialTokensNominal() public {
        address user1 = makeAddr("User1");
        address user2 = makeAddr("User2");
        uint256 amount1 = 1000;
        uint256 amount2 = 500;
        uint256 freezeAmount1 = 300;
        uint256 freezeAmount2 = 200;
        uint256 unfreezeAmount1 = 100;
        uint256 unfreezeAmount2 = 50;

        // Mint tokens
        vm.startPrank(agent);
        token.mint(user1, amount1);
        token.mint(user2, amount2);

        // Freeze tokens
        token.freezePartialTokens(user1, freezeAmount1);
        token.freezePartialTokens(user2, freezeAmount2);

        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = unfreezeAmount1;
        amounts[1] = unfreezeAmount2;

        token.batchUnfreezePartialTokens(users, amounts);
        vm.stopPrank();

        assertEq(token.getFrozenTokens(user1), freezeAmount1 - unfreezeAmount1);
        assertEq(token.getFrozenTokens(user2), freezeAmount2 - unfreezeAmount2);
    }

    function testTokenUnfreezePartialTokensRevertsWhenDisablePartialFreezeRestrictionIsSet() public {
        vm.prank(accessManagerAdmin);
        accessManager.revokeRole(RolesLib.AGENT_PARTIAL_FREEZER, agent);

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, agent));
        vm.prank(agent);
        token.unfreezePartialTokens(user, 200);
    }

}

