// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.31;

import { Test } from "@forge-std/Test.sol";
import { IIdentity, Identity } from "@onchain-id/solidity/contracts/Identity.sol";
import { IdFactory } from "@onchain-id/solidity/contracts/factory/IdFactory.sol";
import { KeyPurposes } from "@onchain-id/solidity/contracts/libraries/KeyPurposes.sol";
import { KeyTypes } from "@onchain-id/solidity/contracts/libraries/KeyTypes.sol";
import { ImplementationAuthority } from "@onchain-id/solidity/contracts/proxy/ImplementationAuthority.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AccessManager } from "@openzeppelin/contracts/access/manager/AccessManager.sol";

import { IdentityFactoryHelper } from "./IdentityFactoryHelper.sol";
import { ImplementationAuthorityHelper } from "./ImplementationAuthorityHelper.sol";
import { TREXFactoryHelper } from "./TREXFactoryHelper.sol";
import { ModularCompliance } from "contracts/compliance/modular/ModularCompliance.sol";
import { ITREXFactory, TREXFactory } from "contracts/factory/TREXFactory.sol";
import { TREXGateway } from "contracts/factory/TREXGateway.sol";
import { AccessManagerSetupLib } from "contracts/libraries/AccessManagerSetupLib.sol";
import { RolesLib } from "contracts/libraries/RolesLib.sol";
import {
    ITREXImplementationAuthority,
    TREXImplementationAuthority
} from "contracts/proxy/authority/TREXImplementationAuthority.sol";
import { ClaimTopicsRegistry } from "contracts/registry/implementation/ClaimTopicsRegistry.sol";
import { IERC3643IdentityRegistry, IdentityRegistry } from "contracts/registry/implementation/IdentityRegistry.sol";
import { IdentityRegistryStorage } from "contracts/registry/implementation/IdentityRegistryStorage.sol";
import { TrustedIssuersRegistry } from "contracts/registry/implementation/TrustedIssuersRegistry.sol";
import { Token } from "contracts/token/Token.sol";

import { Countries } from "test/integration/helpers/Countries.sol";

contract TREXSuiteTest is Test {

    // OnchainID
    Identity public identityImplementation;
    ImplementationAuthority public implementationAuthority;
    IdFactory public idFactory;

    // Implementations
    Token tokenImplementation;
    IdentityRegistry identityRegistryImplementation;
    IdentityRegistryStorage identityRegistryStorageImplementation;
    ClaimTopicsRegistry claimTopicsRegistryImplementation;
    TrustedIssuersRegistry trustedIssuersRegistryImplementation;
    ModularCompliance modularComplianceImplementation;

    // Factories
    TREXFactory public trexFactory;
    TREXGateway public trexGateway;
    TREXImplementationAuthority public trexImplementationAuthority;

    // TREX Suite
    Token public token;

    address public accessManagerAdmin = makeAddr("accessManagerAdmin");
    address public deployer = makeAddr("deployer");
    address public agent = makeAddr("agent");

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");
    address public david = makeAddr("david");
    address public another = makeAddr("another");

    IIdentity public aliceIdentity;
    IIdentity public bobIdentity;
    IIdentity public charlieIdentity;

    Account public claimIssuerSigningKey = makeAccount("claimIssuerSigningKey");

    AccessManager public accessManager;

    constructor() {
        accessManager = new AccessManager(accessManagerAdmin);

        vm.startPrank(accessManagerAdmin);
        AccessManagerSetupLib.setupLabels(accessManager);

        accessManager.grantRole(RolesLib.AGENT, agent, 0);
        accessManager.grantRole(RolesLib.AGENT_MINTER, agent, 0);
        accessManager.grantRole(RolesLib.AGENT_BURNER, agent, 0);
        accessManager.grantRole(RolesLib.AGENT_PARTIAL_FREEZER, agent, 0);
        accessManager.grantRole(RolesLib.AGENT_ADDRESS_FREEZER, agent, 0);
        accessManager.grantRole(RolesLib.AGENT_RECOVERY_ADDRESS, agent, 0);
        accessManager.grantRole(RolesLib.AGENT_FORCED_TRANSFER, agent, 0);
        accessManager.grantRole(RolesLib.AGENT_PAUSER, agent, 0);

        vm.stopPrank();
    }

    function setUp() public virtual {
        _setupOnchainId();
        _setupImplementations();
        _setupFactories();

        token = _deployToken("salt", "Token", "TKN");

        _setupIdentities(token);

        token.identityRegistry().claimIssuer()
            .addKey(keccak256(abi.encode(claimIssuerSigningKey.addr)), KeyPurposes.CLAIM_SIGNER, KeyTypes.ECDSA);
    }

    function _setupOnchainId() internal {
        vm.startPrank(deployer);
        identityImplementation = new Identity(accessManagerAdmin, true);
        implementationAuthority = new ImplementationAuthority(address(identityImplementation));
        idFactory = new IdFactory(address(implementationAuthority));
        vm.stopPrank();
    }

    function _setupImplementations() internal {
        tokenImplementation = new Token();
        identityRegistryImplementation = new IdentityRegistry();
        identityRegistryStorageImplementation = new IdentityRegistryStorage();
        claimTopicsRegistryImplementation = new ClaimTopicsRegistry();
        trustedIssuersRegistryImplementation = new TrustedIssuersRegistry();
        modularComplianceImplementation = new ModularCompliance();
    }

    function _setupFactories() internal {
        vm.startPrank(deployer);

        trexImplementationAuthority = new TREXImplementationAuthority(true, address(0), address(0));
        trexImplementationAuthority.addAndUseTREXVersion(
            ITREXImplementationAuthority.Version({ major: 5, minor: 0, patch: 0 }),
            ITREXImplementationAuthority.TREXContracts({
                tokenImplementation: address(tokenImplementation),
                irImplementation: address(identityRegistryImplementation),
                irsImplementation: address(identityRegistryStorageImplementation),
                ctrImplementation: address(claimTopicsRegistryImplementation),
                tirImplementation: address(trustedIssuersRegistryImplementation),
                mcImplementation: address(modularComplianceImplementation)
            })
        );

        trexFactory = new TREXFactory(address(trexImplementationAuthority), address(idFactory));
        idFactory.addTokenFactory(address(trexFactory));

        trexGateway = new TREXGateway(address(trexFactory), false, address(accessManager));

        vm.stopPrank();

        vm.startPrank(accessManagerAdmin);
        accessManager.grantRole(0, address(trexFactory), 0);
        accessManager.grantRole(RolesLib.OWNER, address(trexFactory), 0);
        accessManager.grantRole(RolesLib.OWNER, address(trexImplementationAuthority), 0);
        vm.stopPrank();
    }

    function _deployToken(string memory salt, string memory name, string memory symbol) internal returns (Token) {
        ITREXFactory.TokenDetails memory tokenDetails = ITREXFactory.TokenDetails({
            owner: deployer,
            name: name,
            symbol: symbol,
            decimals: 0,
            irs: address(0),
            ONCHAINID: address(0),
            irAgents: new address[](0),
            tokenAgents: new address[](0),
            complianceModules: new address[](0),
            complianceSettings: new bytes[](0),
            accessManager: address(accessManager)
        });
        ITREXFactory.ClaimDetails memory claimDetails = ITREXFactory.ClaimDetails({
            claimTopics: new uint256[](0), issuers: new address[](0), issuerClaims: new uint256[][](0)
        });

        vm.prank(deployer);
        trexFactory.deployTREXSuite(salt, tokenDetails, claimDetails);

        address tokenAddress = trexFactory.getToken(salt);
        vm.label(tokenAddress, symbol);

        return Token(tokenAddress);
    }

    function getTREXContracts() public view returns (ITREXImplementationAuthority.TREXContracts memory) {
        return ITREXImplementationAuthority.TREXContracts({
            tokenImplementation: address(tokenImplementation),
            ctrImplementation: address(claimTopicsRegistryImplementation),
            irImplementation: address(identityRegistryImplementation),
            irsImplementation: address(identityRegistryStorageImplementation),
            tirImplementation: address(trustedIssuersRegistryImplementation),
            mcImplementation: address(modularComplianceImplementation)
        });
    }

    function _setupIdentities(Token _token) internal {
        vm.startPrank(deployer);
        aliceIdentity = IIdentity(idFactory.createIdentity(alice, "alice"));
        bobIdentity = IIdentity(idFactory.createIdentity(bob, "bob"));
        charlieIdentity = IIdentity(idFactory.createIdentity(charlie, "charlie"));
        vm.stopPrank();

        vm.startPrank(agent);
        IERC3643IdentityRegistry ir = _token.identityRegistry();
        ir.registerIdentity(alice, aliceIdentity, Countries.FRANCE);
        ir.registerIdentity(bob, bobIdentity, Countries.UNITED_STATES);
        ir.registerIdentity(charlie, charlieIdentity, Countries.SPAIN);
        vm.stopPrank();
    }

}
