// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";
import { IERC20Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import { ERC3643EventsLib } from "contracts/ERC-3643/ERC3643EventsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { RolesLib } from "contracts/libraries/RolesLib.sol";

import { TokenBaseUnitTest } from "./TokenBaseUnitTest.t.sol";

contract TokenFreezeUnitTest is TokenBaseUnitTest {

    address user = makeAddr("User");
    uint256 mintAmount = 1000;
    uint256 freezeAmount = 500;

    function setUp() public override {
        super.setUp();

        vm.startPrank(agent);
        token.unpause();
        token.mint(user, mintAmount);
        vm.stopPrank();
    }

    function testTokenFreezePartialTokensRevertsWhenNotAgent(address caller) public {
        vm.assume(caller != agent);

        vm.expectPartialRevert(IAccessManaged.AccessManagedUnauthorized.selector);
        vm.prank(caller);
        token.freezePartialTokens(user, freezeAmount);
    }

    function testTokenFreezePartialTokensRevertsWhenInsufficientBalance() public {
        uint256 excessiveAmount = mintAmount + 1;

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, user, mintAmount, excessiveAmount)
        );
        vm.prank(agent);
        token.freezePartialTokens(user, excessiveAmount);
    }

    function testTokenFreezePartialTokensNominal() public {
        vm.expectEmit(true, true, true, true);
        emit ERC3643EventsLib.TokensFrozen(user, freezeAmount);

        vm.prank(agent);
        token.freezePartialTokens(user, freezeAmount);

        assertEq(token.getFrozenTokens(user), freezeAmount);
    }

    function testTokenSetAddressFrozenRevertsWhenNotAgent(address caller) public {
        vm.assume(caller != agent);

        vm.expectPartialRevert(IAccessManaged.AccessManagedUnauthorized.selector);
        vm.prank(caller);
        token.setAddressFrozen(user, true);
    }

    function testTokenSetAddressFrozenNominal() public {
        vm.expectEmit(true, true, true, true, address(token));
        emit ERC3643EventsLib.AddressFrozen(user, true, agent);
        vm.prank(agent);
        token.setAddressFrozen(user, true);

        assertTrue(token.isFrozen(user));
    }

    function testTokenSetAddressFrozenToFalse() public {
        // First freeze the address
        vm.prank(agent);
        token.setAddressFrozen(user, true);

        vm.expectEmit(true, true, true, true, address(token));
        emit ERC3643EventsLib.AddressFrozen(user, false, agent);
        vm.prank(agent);
        token.setAddressFrozen(user, false);

        assertFalse(token.isFrozen(user));
    }

    function testTokenBatchFreezePartialTokensNominal() public {
        address user1 = makeAddr("User1");
        address user2 = makeAddr("User2");
        uint256 amount1 = 1000;
        uint256 amount2 = 500;
        uint256 freezeAmount1 = 300;
        uint256 freezeAmount2 = 200;

        // Mint tokens
        vm.startPrank(agent);
        token.mint(user1, amount1);
        token.mint(user2, amount2);

        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = freezeAmount1;
        amounts[1] = freezeAmount2;

        token.batchFreezePartialTokens(users, amounts);
        vm.stopPrank();

        assertEq(token.getFrozenTokens(user1), freezeAmount1);
        assertEq(token.getFrozenTokens(user2), freezeAmount2);
    }

    function testTokenBatchSetAddressFrozenNominal() public {
        address user1 = makeAddr("User1");
        address user2 = makeAddr("User2");

        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;

        bool[] memory freezes = new bool[](2);
        freezes[0] = true;
        freezes[1] = false;

        vm.prank(agent);
        token.batchSetAddressFrozen(users, freezes);

        assertTrue(token.isFrozen(user1));
        assertFalse(token.isFrozen(user2));
    }

    function testTokenFreezePartialTokensRevertsWhenDisablePartialFreezeRestrictionIsSet() public {
        vm.prank(accessManagerAdmin);
        accessManager.revokeRole(RolesLib.AGENT_PARTIAL_FREEZER, agent);

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, agent));
        vm.prank(agent);
        token.freezePartialTokens(user, freezeAmount);
    }

    function testTokenSetAddressFrozenRevertsWhenDisableAddressFreezeRestrictionIsSet() public {
        vm.prank(accessManagerAdmin);
        accessManager.revokeRole(RolesLib.AGENT_ADDRESS_FREEZER, agent);

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, agent));
        vm.prank(agent);
        token.setAddressFrozen(user, true);
    }

}

