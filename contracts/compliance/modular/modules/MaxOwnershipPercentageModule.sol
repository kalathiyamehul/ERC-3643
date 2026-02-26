// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import './AbstractModule.sol';
import '../IModularCompliance.sol';
import '../../../token/IToken.sol';

/**
 * @title MaxOwnershipPercentageModule
 * @dev Compliance module to restrict any single user from owning more than 50% of total supply.
 * Includes an exemption list for Issuer and Marketplace.
 */
contract MaxOwnershipPercentageModule is AbstractModule {
    // Compliance address => User address => Is Exempted
    mapping(address => mapping(address => bool)) private _isExempt;

    event ExemptionSet(address indexed compliance, address indexed account, bool isExempt);

    /**
     * @dev Sets the exemption status for an account.
     * Can only be called by the modular compliance contract via callModuleFunction.
     * @param _account The address to set exemption for.
     * @param _status True to exempt, false otherwise.
     */
    function setExemption(address _account, bool _status) external onlyComplianceCall {
        _isExempt[msg.sender][_account] = _status;
        emit ExemptionSet(msg.sender, _account, _status);
    }

    /**
     * @dev Checks if an address is exempt from the 50% ownership rule.
     * @param _compliance The address of the compliance contract.
     * @param _account The address to check.
     */
    function isExempt(address _compliance, address _account) external view returns (bool) {
        return _isExempt[_compliance][_account];
    }

    /**
     * @dev Main compliance check executed during transfers, minting, and burning.
     * @param _to The address of the receiver.
     * @param _value The amount of tokens being transferred.
     * @param _compliance The address of the compliance contract.
     */
    function moduleCheck(address /*_from*/, address _to, uint256 _value, address _compliance) external view override returns (bool) {
        // 1. If receiver is exempt (e.g., Issuer or Marketplace), allow the transfer.
        if (_isExempt[_compliance][_to]) {
            return true;
        }

        IToken token = IToken(IModularCompliance(_compliance).getTokenBound());
        uint256 totalSupply = token.totalSupply();
        uint256 currentBalance = token.balanceOf(_to);

        // If no tokens exist yet, allow the first minting/transfer.
        if (totalSupply == 0) {
            return true;
        }

        // 2. Rule: New balance must not exceed 50% of total supply.
        // Formula: (currentBalance + _value) <= (totalSupply / 2)
        if ((currentBalance + _value) * 2 > totalSupply) {
            return false;
        }

        return true;
    }

    // Required overrides for IModule (empty implementations if no state update needed)
    function moduleTransferAction(address _from, address _to, uint256 _value) external override onlyComplianceCall {}
    function moduleMintAction(address _to, uint256 _value) external override onlyComplianceCall {}
    function moduleBurnAction(address _from, uint256 _value) external override onlyComplianceCall {}

    function canComplianceBind(address /*_compliance*/) external pure override returns (bool) {
        return true;
    }

    function isPlugAndPlay() external pure override returns (bool) {
        return true;
    }

    function name() external pure override returns (string memory) {
        return 'MaxOwnershipPercentageModule';
    }
}
