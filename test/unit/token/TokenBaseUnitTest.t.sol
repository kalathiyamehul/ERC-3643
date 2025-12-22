// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.31;

import { Test } from "@forge-std/Test.sol";

import { IIdentity } from "@onchain-id/solidity/contracts/interface/IIdentity.sol";

import { AccessManager } from "@openzeppelin/contracts/access/manager/AccessManager.sol";

import { IERC3643Compliance } from "contracts/ERC-3643/IERC3643Compliance.sol";
import { IERC3643IdentityRegistry } from "contracts/ERC-3643/IERC3643IdentityRegistry.sol";
import { TokenProxy } from "contracts/proxy/TokenProxy.sol";
import { ITREXImplementationAuthority } from "contracts/proxy/authority/ITREXImplementationAuthority.sol";
import { RolesLib } from "contracts/roles/RolesLib.sol";
import { Token } from "contracts/token/Token.sol";
import { TokenAccessManagerSetupLib } from "contracts/token/TokenAccessManagerSetupLib.sol";

abstract contract TokenBaseUnitTest is Test {

    AccessManager accessManager;

    Token tokenImplementation;
    Token token;

    address implementationAuthority = makeAddr("ImplementationAuthorityMock");

    address identityRegistry = makeAddr("IdentityRegistryMock");
    address compliance = makeAddr("ComplianceMock");
    address onchainId = makeAddr("OnchainIdMock");

    address user1 = makeAddr("User1");
    address user2 = makeAddr("User2");

    address agent = makeAddr("Agent");
    address owner = makeAddr("Owner");

    constructor() {
        tokenImplementation = new Token();
        accessManager = new AccessManager(address(this));

        mockImplementationAuthority();
        mockCompliance();
        mockIdentityRegistry();
    }

    function setUp() public virtual {
        token = Token(
            address(
                new TokenProxy(
                    implementationAuthority,
                    identityRegistry,
                    compliance,
                    "Token",
                    "TKN",
                    18,
                    address(onchainId),
                    address(accessManager)
                )
            )
        );

        TokenAccessManagerSetupLib.setupRoles(accessManager, address(token));
        accessManager.grantRole(RolesLib.OWNER, address(owner), 0);
        accessManager.grantRole(RolesLib.OWNER, address(this), 0);
        accessManager.grantRole(RolesLib.AGENT, address(agent), 0);
        accessManager.grantRole(RolesLib.AGENT_MINTER, address(agent), 0);
        accessManager.grantRole(RolesLib.AGENT_BURNER, address(agent), 0);
        accessManager.grantRole(RolesLib.AGENT_PARTIAL_FREEZER, address(agent), 0);
        accessManager.grantRole(RolesLib.AGENT_ADDRESS_FREEZER, address(agent), 0);
        accessManager.grantRole(RolesLib.AGENT_RECOVERY_ADDRESS, address(agent), 0);
        accessManager.grantRole(RolesLib.AGENT_FORCED_TRANSFER, address(agent), 0);
        accessManager.grantRole(RolesLib.AGENT_PAUSER, address(agent), 0);
    }

    function mockImplementationAuthority() internal {
        vm.mockCall(
            implementationAuthority,
            abi.encodeWithSelector(ITREXImplementationAuthority.getTokenImplementation.selector),
            abi.encode(address(tokenImplementation))
        );
    }

    function mockCompliance() internal {
        vm.mockCall(compliance, abi.encodeWithSelector(IERC3643Compliance.bindToken.selector), "");
        vm.mockCall(compliance, abi.encodeWithSelector(IERC3643Compliance.unbindToken.selector), "");
        vm.mockCall(compliance, abi.encodeWithSelector(IERC3643Compliance.canTransfer.selector), abi.encode(true));

        vm.mockCall(compliance, abi.encodeWithSelector(IERC3643Compliance.created.selector), "");
        vm.mockCall(compliance, abi.encodeWithSelector(IERC3643Compliance.destroyed.selector), "");
        vm.mockCall(compliance, abi.encodeWithSelector(IERC3643Compliance.transferred.selector), "");
    }

    function mockIdentityRegistry() internal {
        vm.mockCall(
            identityRegistry, abi.encodeWithSelector(IERC3643IdentityRegistry.isVerified.selector), abi.encode(true)
        );

        vm.mockCall(identityRegistry, abi.encodeWithSelector(IERC3643IdentityRegistry.deleteIdentity.selector), "");
    }

}
