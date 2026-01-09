// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { RolesLib } from "contracts/libraries/RolesLib.sol";

import { TokenBaseUnitTest } from "../helpers/TokenBaseUnitTest.t.sol";

contract TokenMintUnitTest is TokenBaseUnitTest {

    uint256 mintAmount = 1000;

    function setUp() public override {
        super.setUp();

        vm.prank(agent);
        token.unpause();
    }

    function testTokenBatchMintNominal() public {
        uint256 amount1 = 500;
        uint256 amount2 = 300;

        address[] memory tos = new address[](2);
        tos[0] = user1;
        tos[1] = user2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = amount1;
        amounts[1] = amount2;

        vm.prank(agent);
        token.batchMint(tos, amounts);

        assertEq(token.balanceOf(user1), amount1);
        assertEq(token.balanceOf(user2), amount2);
        assertEq(token.totalSupply(), amount1 + amount2);
    }

}

