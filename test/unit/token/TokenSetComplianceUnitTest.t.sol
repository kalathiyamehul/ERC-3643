// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.31;

import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

import { ERC3643EventsLib } from "contracts/ERC-3643/ERC3643EventsLib.sol";
import { IERC3643Compliance } from "contracts/ERC-3643/IERC3643Compliance.sol";
import { RolesLib } from "contracts/roles/RolesLib.sol";

import { TokenBaseUnitTest } from "./TokenBaseUnitTest.t.sol";

contract TokenSetComplianceUnitTest is TokenBaseUnitTest {

    address newCompliance = makeAddr("NewComplianceMock");

    constructor() {
        vm.mockCall(compliance, abi.encodeWithSelector(IERC3643Compliance.unbindToken.selector, address(token)), "");
        vm.mockCall(newCompliance, abi.encodeWithSelector(IERC3643Compliance.bindToken.selector, address(token)), "");
    }

    function testTokenSetComplianceRevertsWhenNotOwner(address caller) public {
        (bool isOwner,) = accessManager.hasRole(RolesLib.OWNER, caller);
        vm.assume(!isOwner && caller != address(this));

        vm.expectPartialRevert(IAccessManaged.AccessManagedUnauthorized.selector);
        vm.prank(caller);
        token.setCompliance(newCompliance);
    }

    function testTokenSetComplianceNominal() public {
        vm.expectEmit(true, true, true, true, address(token));
        emit ERC3643EventsLib.ComplianceAdded(newCompliance);
        vm.prank(owner);
        token.setCompliance(newCompliance);

        assertEq(address(token.compliance()), newCompliance);
    }

    function testTokenSetComplianceUnbindsPreviousCompliance() public {
        vm.expectEmit(true, true, true, true, address(token));
        emit ERC3643EventsLib.ComplianceAdded(newCompliance);
        vm.prank(owner);
        token.setCompliance(newCompliance);
    }

}
