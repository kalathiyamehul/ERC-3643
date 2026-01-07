// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import { TokenBaseUnitTest } from "../helpers/TokenBaseUnitTest.t.sol";
import { Token } from "contracts/token/Token.sol";

contract TokenInitUnitTest is TokenBaseUnitTest {

    function testTokenConstructorDisablesInitializers() public {
        Token newToken = new Token();

        vm.expectRevert(abi.encodeWithSelector(Initializable.InvalidInitialization.selector));
        newToken.init("", "", 0, address(0), address(0), address(0), address(accessManager));
    }

}
