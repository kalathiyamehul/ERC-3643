// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.31;

import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";
import { IAccessManager } from "@openzeppelin/contracts/access/manager/IAccessManager.sol";
import { ERC3643EventsLib } from "contracts/ERC-3643/ERC3643EventsLib.sol";
import { RolesLib } from "contracts/roles/RolesLib.sol";

import { TokenBaseUnitTest } from "./TokenBaseUnitTest.t.sol";

contract TokenSetIdentityRegistryUnitTest is TokenBaseUnitTest {

    address newIdentityRegistry = makeAddr("NewIdentityRegistry");

    function testTokenSetIdentityRegistryRevertsWhenNotOwner(address caller) public {
        (bool isOwner,) = IAccessManager(token.authority()).hasRole(RolesLib.OWNER, caller);
        vm.assume(!isOwner && caller != address(this) && caller != address(0));

        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, caller));
        vm.prank(caller);
        token.setIdentityRegistry(newIdentityRegistry);
    }

    function testTokenSetIdentityRegistryNominal() public {
        vm.expectEmit(true, true, true, true, address(token));
        emit ERC3643EventsLib.IdentityRegistryAdded(newIdentityRegistry);
        vm.prank(owner);
        token.setIdentityRegistry(newIdentityRegistry);

        assertEq(address(token.identityRegistry()), newIdentityRegistry);
    }

}
