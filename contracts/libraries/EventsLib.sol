// SPDX-License-Identifier: GPL-3.0
//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//

/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2025, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
pragma solidity 0.8.31;

import { ITREXImplementationAuthority } from "../proxy/authority/ITREXImplementationAuthority.sol";

library EventsLib {

    // ============================================
    // Common Events
    // ============================================

    event ImplementationAuthoritySet(address _implementationAuthority);

    // ============================================
    // AgentRole / AgentRoleUpgradeable
    // ============================================

    event AgentAdded(address indexed _agent);

    event AgentRemoved(address indexed _agent);

    // ============================================
    // Token (IToken)
    // ============================================

    event AgentRestrictionsSet(
        address indexed _agent,
        bool _disableMint,
        bool _disableBurn,
        bool _disableAddressFreeze,
        bool _disableForceTransfer,
        bool _disablePartialFreeze,
        bool _disablePause,
        bool _disableRecovery
    );

    event DefaultAllowanceUpdated(address to, bool allowance, address updater);

    event DefaultAllowanceOptOutUpdated(address user, bool optOut);

    // ============================================
    // ModularCompliance
    // ============================================

    event ModuleInteraction(address indexed _target, bytes4 _selector);

    event ModuleAdded(address indexed _module);

    event ModuleRemoved(address indexed _module);

    // ============================================
    // AbstractModule / AbstractModuleUpgradeable
    // ============================================

    event ComplianceBound(address indexed _compliance);

    event ComplianceUnbound(address indexed _compliance);

    // ============================================
    // IdentityRegistry
    // ============================================

    event EligibilityChecksDisabled();

    event EligibilityChecksEnabled();

    // ============================================
    // TREXFactory
    // ============================================

    event Deployed(address indexed _addr);

    event IdFactorySet(address _idFactory);

    event TREXSuiteDeployed(
        address indexed _token, address _ir, address _irs, address _tir, address _ctr, address _mc, string indexed _salt
    );

    // ============================================
    // TREXGateway
    // ============================================

    event FactorySet(address indexed _factory);

    event PublicDeploymentStatusSet(bool indexed _publicDeploymentStatus);

    event DeploymentFeeSet(uint256 indexed _fee, address indexed _feeToken, address indexed _feeCollector);

    event DeploymentFeeEnabled(bool indexed _isEnabled);

    event DeployerAdded(address indexed _deployer);

    event DeployerRemoved(address indexed _deployer);

    event FeeDiscountApplied(address indexed _deployer, uint16 _discount);

    event GatewaySuiteDeploymentProcessed(address indexed _requester, address _intendedOwner, uint256 _feeApplied);

    // ============================================
    // TREXImplementationAuthority
    // ============================================

    event TREXVersionAdded(
        ITREXImplementationAuthority.Version indexed _version, ITREXImplementationAuthority.TREXContracts indexed _trex
    );

    event TREXVersionFetched(
        ITREXImplementationAuthority.Version indexed _version, ITREXImplementationAuthority.TREXContracts indexed _trex
    );

    event VersionUpdated(ITREXImplementationAuthority.Version indexed _version);

    event ImplementationAuthoritySetWithStatus(bool _referenceStatus, address _trexFactory);

    event TREXFactorySet(address indexed _trexFactory);

    event IAFactorySet(address indexed _iaFactory);

    event ImplementationAuthorityChanged(address indexed _token, address indexed _newImplementationAuthority);

    // ============================================
    // IAFactory
    // ============================================

    event ImplementationAuthorityDeployed(address indexed _ia);

    // ============================================
    // OwnableOnceNext2StepUpgradeable
    // ============================================

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

}
