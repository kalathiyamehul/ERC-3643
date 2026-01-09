// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { TokenBaseUnitTest } from "../helpers/TokenBaseUnitTest.t.sol";

contract TokenTransferUnitTest is TokenBaseUnitTest {

    address from = makeAddr("From");
    address to = makeAddr("To");
    address spender = makeAddr("Spender");
    uint256 mintAmount = 1000;
    uint256 transferAmount = 500;
    uint256 frozenAmount = 300;

    function setUp() public override {
        super.setUp();

        vm.startPrank(agent);
        token.unpause();
        token.mint(from, mintAmount);
        vm.stopPrank();
    }

    function testTokenBatchTransferNominal() public {
        address to1 = makeAddr("To1");
        address to2 = makeAddr("To2");
        uint256 amount1 = 200;
        uint256 amount2 = 300;

        address[] memory tos = new address[](2);
        tos[0] = to1;
        tos[1] = to2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = amount1;
        amounts[1] = amount2;

        vm.prank(from);
        token.batchTransfer(tos, amounts);

        assertEq(token.balanceOf(from), mintAmount - amount1 - amount2);
        assertEq(token.balanceOf(to1), amount1);
        assertEq(token.balanceOf(to2), amount2);
    }

}

