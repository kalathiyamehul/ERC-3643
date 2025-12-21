// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.31;

import { Test } from "@forge-std/Test.sol";
import { AccessManager } from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { ModularCompliance } from "contracts/compliance/modular/ModularCompliance.sol";
import { ErrorsLib } from "contracts/libraries/ErrorsLib.sol";

import { TREXSuiteTest } from "test/integration/helpers/TREXSuiteTest.sol";
import { TestModule } from "test/integration/mocks/TestModule.sol";

/// @notice tests for TestModule multicall functionality
contract TestModuleTest is TREXSuiteTest {

    ModularCompliance public compliance;
    TestModule public testModule;

    function setUp() public override {
        super.setUp();

        compliance = ModularCompliance(address(token.compliance()));

        // Deploy TestModule implementation
        TestModule testModuleImplementation = new TestModule();

        // Deploy TestModule proxy with initialize using ERC1967Proxy
        bytes memory moduleInitData = abi.encodeCall(TestModule.initialize, (address(accessManager)));
        ERC1967Proxy testModuleProxy = new ERC1967Proxy(address(testModuleImplementation), moduleInitData);
        testModule = TestModule(address(testModuleProxy));

        // Add module to compliance
        vm.prank(deployer);
        compliance.addModule(address(testModule));
    }

    /// @notice Should execute multiple doSomething calls in a single transaction
    function test_MultipleDoSomethingCalls_Success() public {
        // Encode function calls
        bytes memory doSomething42Data = abi.encodeWithSignature("doSomething(uint256)", 42);
        bytes memory doSomething43Data = abi.encodeWithSignature("doSomething(uint256)", 43);

        // Create array of call data for multicall
        bytes[] memory multicallData = new bytes[](2);
        multicallData[0] = doSomething42Data;
        multicallData[1] = doSomething43Data;

        // Encode multicall
        bytes memory multicallEncoded = abi.encodeWithSignature("multicall(bytes[])", multicallData);

        // Call multicall via compliance
        vm.prank(deployer);
        compliance.callModuleFunction(multicallEncoded, address(testModule));

        // Verify state changes, the last call should overwrite the first one
        assertEq(testModule.getComplianceData(address(compliance)), 43);
    }

    /// @notice Should execute multiple blockModule calls in a single transaction
    function test_MultipleBlockModuleCalls_Success() public {
        // Encode function calls
        bytes memory blockModuleTrueData = abi.encodeWithSignature("blockModule(bool)", true);
        bytes memory blockModuleFalseData = abi.encodeWithSignature("blockModule(bool)", false);

        // Create array of call data for multicall
        bytes[] memory multicallData = new bytes[](2);
        multicallData[0] = blockModuleTrueData;
        multicallData[1] = blockModuleFalseData;

        // Encode multicall
        bytes memory multicallEncoded = abi.encodeWithSignature("multicall(bytes[])", multicallData);

        // Call multicall via compliance, the compliance will call the multicall in the testModule which already has multicall functionality
        vm.prank(deployer);
        compliance.callModuleFunction(multicallEncoded, address(testModule));

        // Verify state changes, the last call should overwrite the first one
        assertEq(testModule.getBlockedTransfers(address(compliance)), false);
    }

    /// @notice Should execute mixed doSomething and blockModule calls in a single transaction
    function test_MixedDoSomethingAndBlockModuleCalls_Success() public {
        // Encode function calls
        bytes memory doSomething100Data = abi.encodeWithSignature("doSomething(uint256)", 100);
        bytes memory blockModuleTrueData = abi.encodeWithSignature("blockModule(bool)", true);
        bytes memory doSomething200Data = abi.encodeWithSignature("doSomething(uint256)", 200);

        // Create array of call data for multicall
        bytes[] memory multicallData = new bytes[](3);
        multicallData[0] = doSomething100Data;
        multicallData[1] = blockModuleTrueData;
        multicallData[2] = doSomething200Data;

        // Encode multicall
        bytes memory multicallEncoded = abi.encodeWithSignature("multicall(bytes[])", multicallData);

        // Call multicall via compliance
        vm.prank(deployer);
        compliance.callModuleFunction(multicallEncoded, address(testModule));

        // Verify state changes, both should be set to the last values
        assertEq(testModule.getComplianceData(address(compliance)), 200);
        assertEq(testModule.getBlockedTransfers(address(compliance)), true);
    }

    /// @notice Should revert when calling multicall directly on module, it should not be from compliance!
    function test_MulticallDirectlyOnModule_RevertWhen_NotFromCompliance() public {
        // Encode function call
        bytes memory doSomething42Data = abi.encodeWithSignature("doSomething(uint256)", 42);

        // Create array of call data for multicall
        bytes[] memory multicallData = new bytes[](1);
        multicallData[0] = doSomething42Data;

        // Expect revert when calling multicall directly on module
        vm.prank(deployer);
        vm.expectRevert(ErrorsLib.OnlyBoundComplianceCanCall.selector);
        testModule.multicall(multicallData);
    }

}
