// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { TokenBaseUnitTest } from "../helpers/TokenBaseUnitTest.t.sol";

contract TokenBurnUnitTest is TokenBaseUnitTest {

    uint256 mintAmount = 1000;
    uint256 burnAmount = 500;

    function setUp() public override {
        super.setUp();

        vm.startPrank(agent);
        token.unpause();
        token.mint(user1, mintAmount);
        vm.stopPrank();
    }

    function testTokenBatchBurnNominal() public {
        uint256 amount1 = 1000;
        uint256 amount2 = 500;
        uint256 burnAmount1 = 300;
        uint256 burnAmount2 = 200;

        // Mint tokens
        vm.startPrank(agent);
        token.mint(user1, amount1);
        token.mint(user2, amount2);

        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);

        address[] memory froms = new address[](2);
        froms[0] = user1;
        froms[1] = user2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = burnAmount1;
        amounts[1] = burnAmount2;

        token.batchBurn(froms, amounts);
        vm.stopPrank();

        assertEq(token.balanceOf(user1), user1BalanceBefore - burnAmount1);
        assertEq(token.balanceOf(user2), user2BalanceBefore - burnAmount2);
        assertEq(token.totalSupply(), mintAmount + amount1 + amount2 - burnAmount1 - burnAmount2);
    }

}
