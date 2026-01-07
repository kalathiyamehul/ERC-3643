// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

import { Test } from "@forge-std/Test.sol";
import { AccessManaged, IAccessManaged } from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import { AccessManager } from "@openzeppelin/contracts/access/manager/AccessManager.sol";

import { ITREXFactory, TREXFactory } from "contracts/factory/TREXFactory.sol";
import { AccessManagerSetupLib } from "contracts/libraries/AccessManagerSetupLib.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { RolesLib } from "contracts/libraries/RolesLib.sol";
import { TREXImplementationAuthority } from "contracts/proxy/authority/TREXImplementationAuthority.sol";

contract TREXFactoryDeployTREXSuite is Test {

    TREXFactory trexFactory;

    AccessManager accessManager;

    constructor() {
        accessManager = new AccessManager(address(this));
        accessManager.grantRole(RolesLib.OWNER, address(this), 0);

        TREXImplementationAuthority implementationAuthority =
            new TREXImplementationAuthority(true, address(0), address(0), address(accessManager));

        vm.mockCall(
            address(implementationAuthority),
            TREXImplementationAuthority.getTokenImplementation.selector,
            abi.encode(address(0x01))
        );
        vm.mockCall(
            address(implementationAuthority),
            TREXImplementationAuthority.getCTRImplementation.selector,
            abi.encode(address(0x01))
        );
        vm.mockCall(
            address(implementationAuthority),
            TREXImplementationAuthority.getIRImplementation.selector,
            abi.encode(address(0x01))
        );
        vm.mockCall(
            address(implementationAuthority),
            TREXImplementationAuthority.getIRSImplementation.selector,
            abi.encode(address(0x01))
        );
        vm.mockCall(
            address(implementationAuthority),
            TREXImplementationAuthority.getMCImplementation.selector,
            abi.encode(address(0x01))
        );
        vm.mockCall(
            address(implementationAuthority),
            TREXImplementationAuthority.getTIRImplementation.selector,
            abi.encode(address(0x01))
        );

        trexFactory = new TREXFactory(address(implementationAuthority), makeAddr("IdFactory"), address(accessManager));
        AccessManagerSetupLib.setupTREXFactoryRoles(accessManager, address(trexFactory));
    }

    function testRevertsWhenAccessManagerIsNotSet() public {
        ITREXFactory.TokenDetails memory tokenDetails = _createTokenDetails(address(0));
        ITREXFactory.ClaimDetails memory claimDetails = _createClaimDetails();

        vm.expectRevert(ErrorsLib.ZeroAddress.selector);
        trexFactory.deployTREXSuite("salt", tokenDetails, claimDetails);
    }

    function testRevertsWhenMissingRoleOnFactory() public {
        ITREXFactory.TokenDetails memory tokenDetails = _createTokenDetails(address(accessManager));
        ITREXFactory.ClaimDetails memory claimDetails = _createClaimDetails();

        vm.expectRevert(ErrorsLib.FactoryMissingAdminRoleOnAccessManager.selector);
        trexFactory.deployTREXSuite("salt", tokenDetails, claimDetails);
    }

    // ----- Helpers -----

    function _createTokenDetails(address accessManagerAddress) internal returns (ITREXFactory.TokenDetails memory) {
        return ITREXFactory.TokenDetails({
            owner: makeAddr("Owner"),
            name: "Token",
            symbol: "TKN",
            decimals: 18,
            irs: address(0),
            ONCHAINID: address(0),
            irAgents: new address[](0),
            tokenAgents: new address[](0),
            complianceModules: new address[](0),
            complianceSettings: new bytes[](0),
            accessManager: accessManagerAddress
        });
    }

    function _createClaimDetails() internal pure returns (ITREXFactory.ClaimDetails memory) {
        return ITREXFactory.ClaimDetails({
            claimTopics: new uint256[](0), issuers: new address[](0), issuerClaims: new uint256[][](0)
        });
    }

}
