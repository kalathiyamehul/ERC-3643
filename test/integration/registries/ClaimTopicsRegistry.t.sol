// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.31;

import { Test } from "@forge-std/Test.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AccessManager } from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import { IAccessManaged } from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { ERC3643EventsLib } from "contracts/ERC-3643/ERC3643EventsLib.sol";
import { IERC3643ClaimTopicsRegistry } from "contracts/ERC-3643/IERC3643ClaimTopicsRegistry.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";
import { ClaimTopicsRegistryProxy } from "contracts/proxy/ClaimTopicsRegistryProxy.sol";
import { ITREXImplementationAuthority } from "contracts/proxy/authority/ITREXImplementationAuthority.sol";
import { TREXImplementationAuthority } from "contracts/proxy/authority/TREXImplementationAuthority.sol";
import { ClaimTopicsRegistry } from "contracts/registry/implementation/ClaimTopicsRegistry.sol";
import { IERC173 } from "contracts/roles/IERC173.sol";
import { InterfaceIdCalculator } from "contracts/utils/InterfaceIdCalculator.sol";

import { ImplementationAuthorityHelper } from "test/integration/helpers/ImplementationAuthorityHelper.sol";
import { TREXSuiteTest } from "test/integration/helpers/TREXSuiteTest.sol";

contract ClaimTopicsRegistryTest is TREXSuiteTest {

    ClaimTopicsRegistry public claimTopicsRegistry;

    function setUp() public override {
        super.setUp();

        claimTopicsRegistry = ClaimTopicsRegistry(address(token.identityRegistry().topicsRegistry()));
    }

    // ============ init() Tests ============

    /// @notice Should revert when contract was already initialized
    function test_init_RevertWhen_AlreadyInitialized() public {
        vm.prank(deployer);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        claimTopicsRegistry.init(address(accessManager));
    }

    // ============ addClaimTopic() Tests ============

    /// @notice Should revert when sender is not owner
    function test_addClaimTopic_RevertWhen_NotOwner() public {
        vm.prank(another);
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, another));
        claimTopicsRegistry.addClaimTopic(1);
    }

    /// @notice Should revert when topic array contains more than 14 elements
    /// @dev Contract allows up to 15 topics (length < 15). To test the limit, we add 15 topics first.
    function test_addClaimTopic_RevertWhen_MoreThan14Topics() public {
        // Add 14 topics first (0-13)
        for (uint256 i = 0; i < 14; i++) {
            vm.prank(deployer);
            claimTopicsRegistry.addClaimTopic(i);
        }

        // Add the 15th topic (index 14), this should succeed (length 14 < 15)
        vm.prank(deployer);
        claimTopicsRegistry.addClaimTopic(14);

        // Now try to add 16th topic, should revert (length 15 is not < 15)
        vm.prank(deployer);
        vm.expectRevert(abi.encodeWithSelector(ErrorsLib.MaxTopicsReached.selector, 15));
        claimTopicsRegistry.addClaimTopic(15);
    }

    /// @notice Should revert when adding a topic that is already added
    function test_addClaimTopic_RevertWhen_TopicAlreadyExists() public {
        vm.prank(deployer);
        claimTopicsRegistry.addClaimTopic(1);

        vm.prank(deployer);
        vm.expectRevert(ErrorsLib.ClaimTopicAlreadyExists.selector);
        claimTopicsRegistry.addClaimTopic(1);
    }

    // ============ removeClaimTopic() Tests ============

    /// @notice Should revert when sender is not owner
    function test_removeClaimTopic_RevertWhen_NotOwner() public {
        vm.prank(another);
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, another));
        claimTopicsRegistry.removeClaimTopic(1);
    }

    /// @notice Should remove claim topic successfully
    function test_removeClaimTopic_Success() public {
        // Add topics first
        vm.prank(deployer);
        claimTopicsRegistry.addClaimTopic(1);
        vm.prank(deployer);
        claimTopicsRegistry.addClaimTopic(2);
        vm.prank(deployer);
        claimTopicsRegistry.addClaimTopic(3);

        // Remove topic 2
        vm.prank(deployer);
        vm.expectEmit(true, false, false, false);
        emit ERC3643EventsLib.ClaimTopicRemoved(2);
        claimTopicsRegistry.removeClaimTopic(2);
    }

    // ============ supportsInterface() Tests ============

    /// @notice Should return false for unsupported interfaces
    function test_supportsInterface_ReturnsFalse_ForUnsupported() public view {
        bytes4 unsupportedInterfaceId = 0x12345678;
        assertFalse(claimTopicsRegistry.supportsInterface(unsupportedInterfaceId));
    }

    /// @notice Should correctly identify the IERC3643ClaimTopicsRegistry interface ID
    function test_supportsInterface_ReturnsTrue_ForIERC3643ClaimTopicsRegistry() public {
        InterfaceIdCalculator calculator = new InterfaceIdCalculator();
        bytes4 interfaceId = calculator.getIERC3643ClaimTopicsRegistryInterfaceId();
        assertTrue(claimTopicsRegistry.supportsInterface(interfaceId));
    }

    /// @notice Should correctly identify the IERC173 interface ID
    function test_supportsInterface_ReturnsTrue_ForIERC173() public {
        InterfaceIdCalculator calculator = new InterfaceIdCalculator();
        bytes4 interfaceId = calculator.getIERC173InterfaceId();
        assertTrue(claimTopicsRegistry.supportsInterface(interfaceId));
    }

    /// @notice Should correctly identify the IERC165 interface ID
    function test_supportsInterface_ReturnsTrue_ForIERC165() public {
        InterfaceIdCalculator calculator = new InterfaceIdCalculator();
        bytes4 interfaceId = calculator.getIERC165InterfaceId();
        assertTrue(claimTopicsRegistry.supportsInterface(interfaceId));
    }

}
