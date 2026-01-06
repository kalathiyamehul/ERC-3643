// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import { ERC3643EventsLib } from "contracts/ERC-3643/ERC3643EventsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";

import { TokenBaseUnitTest } from "./TokenBaseUnitTest.t.sol";

contract TokenSetSymbolUnitTest is TokenBaseUnitTest {

    function testTokenSetSymbolRevertsIfSymbolIsEmpty() public {
        vm.expectRevert(ErrorsLib.EmptyString.selector);
        token.setSymbol("");
    }

    function testTokenSetSymbolRevertsWhenNotOwner(address caller) public {
        vm.assume(caller != address(this));

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, caller));
        vm.prank(caller);
        token.setSymbol("Token");
    }

    function testTokenSetSymbolNominal() public {
        string memory newSymbol = "NEWSYM";

        vm.expectEmit(true, true, true, true, address(token));
        emit ERC3643EventsLib.UpdatedTokenInformation(
            token.name(), newSymbol, token.decimals(), token.version(), token.onchainID()
        );
        token.setSymbol(newSymbol);
    }

}
