// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.31;

import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import { ERC3643EventsLib } from "contracts/ERC-3643/ERC3643EventsLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { RolesLib } from "contracts/libraries/RolesLib.sol";

import { TokenBaseUnitTest } from "./TokenBaseUnitTest.t.sol";

contract TokenSetNameUnitTest is TokenBaseUnitTest {

    function testTokenSetNameRevertsIfNameIsEmpty() public {
        vm.expectRevert(ErrorsLib.EmptyString.selector);
        vm.prank(owner);
        token.setName("");
    }

    function testTokenSetNameRevertsWhenNotOwner(address caller) public {
        (bool isOwner,) = accessManager.hasRole(RolesLib.OWNER, caller);
        vm.assume(!isOwner && caller != address(this));

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, caller));
        vm.prank(caller);
        token.setName("Token");
    }

    function testTokenSetNameNominal() public {
        string memory newName = "New Name";

        vm.expectEmit(true, true, true, true, address(token));
        emit ERC3643EventsLib.UpdatedTokenInformation(
            newName, token.symbol(), token.decimals(), token.version(), token.onchainID()
        );
        vm.prank(owner);
        token.setName(newName);

        (, string memory name,,,,,) = token.eip712Domain();
        assertEq(name, newName);
    }

}
