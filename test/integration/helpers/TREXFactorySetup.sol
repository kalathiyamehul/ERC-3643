// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.31;

import { Test } from "@forge-std/Test.sol";
import { IIdentity, Identity } from "@onchain-id/solidity/contracts/Identity.sol";
import { IdFactory } from "@onchain-id/solidity/contracts/factory/IdFactory.sol";
import { IdFactory } from "@onchain-id/solidity/contracts/factory/IdFactory.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AccessManager } from "@openzeppelin/contracts/access/manager/AccessManager.sol";

import { IdentityFactoryHelper } from "./IdentityFactoryHelper.sol";
import { ImplementationAuthorityHelper } from "./ImplementationAuthorityHelper.sol";
import { TREXFactoryHelper } from "./TREXFactoryHelper.sol";
import { TREXFactory } from "contracts/factory/TREXFactory.sol";
import { AccessManagerSetupLib } from "contracts/libraries/AccessManagerSetupLib.sol";
import { ITREXImplementationAuthority } from "contracts/proxy/authority/ITREXImplementationAuthority.sol";
import { TREXImplementationAuthority } from "contracts/proxy/authority/TREXImplementationAuthority.sol";

contract TREXFactorySetup is Test {

    // OnchainID
    Identity public identityImplementation;
    IdFactory public idFactory;

    // ONCHAINID Setup
    IdentityFactoryHelper.ONCHAINIDSetup public onchainidSetup;

    // TREX Implementation Authority Setup
    ImplementationAuthorityHelper.ImplementationAuthoritySetup public implementationAuthoritySetup;

    // TREX Factory
    TREXFactory public trexFactory;

    // Standard test addresses
    address public deployer = makeAddr("deployer");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");
    address public david = makeAddr("david");
    address public another = makeAddr("another");

    //identities for common test addresses
    IIdentity public aliceIdentity;
    IIdentity public bobIdentity;
    IIdentity public charlieIdentity;

    AccessManager public accessManager;

    constructor() {
        accessManager = new AccessManager(address(this));
        AccessManagerSetupLib.setupLabels(accessManager);
    }

    function setUp() public virtual {
        deploy(deployer, true);
    }

    /// @notice Deploys the complete TREX setup using all 3 helpers
    /// @param deployerAddress The deployer address (used as management key for Identity and as owner)
    /// @param isReference Whether to create a reference Implementation Authority
    /// @dev Ownership: Contracts are initially owned by TREXSuite (since deployed from contract).
    /// Ownership is transferred to deployerAddress where deployer is owner.
    function deploy(address deployerAddress, bool isReference) public {
        // Step 1: Deploy ONCHAINID Components
        onchainidSetup = IdentityFactoryHelper.deploy(deployerAddress);

        // Step 2: Deploy TREX Implementation Authority
        implementationAuthoritySetup = ImplementationAuthorityHelper.deploy(isReference);

        // Step 3: Deploy TREX Factory and link everything
        trexFactory =
            TREXFactoryHelper.deploy(implementationAuthoritySetup.implementationAuthority, onchainidSetup.idFactory);

        // Transfer ownership to deployer after linking is complete
        Ownable(address(implementationAuthoritySetup.implementationAuthority)).transferOwnership(deployerAddress);
        Ownable(address(trexFactory)).transferOwnership(deployerAddress);
        Ownable(address(onchainidSetup.idFactory)).transferOwnership(deployerAddress);

        // common identities for test addresses (alice, bob, charlie)
        vm.startPrank(deployerAddress);
        aliceIdentity = IIdentity(onchainidSetup.idFactory.createIdentity(alice, "alice-salt"));
        bobIdentity = IIdentity(onchainidSetup.idFactory.createIdentity(bob, "bob-salt"));
        charlieIdentity = IIdentity(onchainidSetup.idFactory.createIdentity(charlie, "charlie-salt"));
        vm.stopPrank();
    }

    /// @notice Returns the TREX Implementation Authority contract
    function getTREXImplementationAuthority() public view returns (TREXImplementationAuthority) {
        return implementationAuthoritySetup.implementationAuthority;
    }

    /// @notice Returns the Identity Factory (IdFactory) contract
    function getIdFactory() public view returns (IdFactory) {
        return onchainidSetup.idFactory;
    }

    /// @notice Returns the Identity implementation contract
    function getIdentityImplementation() public view returns (address) {
        return address(onchainidSetup.identityImplementation);
    }

    /// @notice Returns all TREX implementation contracts
    function getTREXImplementations()
        public
        view
        returns (address tokenImpl, address ctrImpl, address irImpl, address irsImpl, address tirImpl, address mcImpl)
    {
        return (
            address(implementationAuthoritySetup.implementations.token),
            address(implementationAuthoritySetup.implementations.claimTopicsRegistry),
            address(implementationAuthoritySetup.implementations.identityRegistry),
            address(implementationAuthoritySetup.implementations.identityRegistryStorage),
            address(implementationAuthoritySetup.implementations.trustedIssuersRegistry),
            address(implementationAuthoritySetup.implementations.modularCompliance)
        );
    }

    /// @notice Returns TREXContracts struct using current implementation addresses
    function getTREXContracts() public view returns (ITREXImplementationAuthority.TREXContracts memory) {
        (address tokenImpl, address ctrImpl, address irImpl, address irsImpl, address tirImpl, address mcImpl) =
            getTREXImplementations();
        return ITREXImplementationAuthority.TREXContracts({
            tokenImplementation: tokenImpl,
            ctrImplementation: ctrImpl,
            irImplementation: irImpl,
            irsImplementation: irsImpl,
            tirImplementation: tirImpl,
            mcImplementation: mcImpl
        });
    }

}
