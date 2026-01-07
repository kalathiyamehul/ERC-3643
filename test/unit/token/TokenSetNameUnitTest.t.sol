// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import { ERC3643EventsLib } from "contracts/ERC-3643/ERC3643EventsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";

import { TokenBaseUnitTest } from "../helpers/TokenBaseUnitTest.t.sol";

contract TokenSetNameUnitTest is TokenBaseUnitTest {

    function testTokenSetNameRevertsIfNameIsEmpty() public {
        vm.expectRevert(ErrorsLib.EmptyString.selector);
        token.setName("");
    }

    function testTokenSetNameRevertsWhenNotOwner(address caller) public {
        vm.assume(caller != address(this));

        vm.expectPartialRevert(IAccessManaged.AccessManagedUnauthorized.selector);
        vm.prank(caller);
        token.setName("Token");
    }

    function testTokenSetNameNominal() public {
        string memory newName = "New Name";

        vm.expectEmit(true, true, true, true, address(token));
        emit ERC3643EventsLib.UpdatedTokenInformation(
            newName, token.symbol(), token.decimals(), token.version(), token.onchainID()
        );
        token.setName(newName);

        (, string memory name,,,,,) = token.eip712Domain();
        assertEq(name, newName);
    }

}
