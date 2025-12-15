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

import { IAccessManager } from "@openzeppelin/contracts/access/manager/IAccessManager.sol";

import { RolesLib } from "../roles/RolesLib.sol";
import { Token } from "./Token.sol";

/// @title TokenAccessManagerSetupLib
/// @notice Library for setting up roles and functions in AccessManager for the Token contract
library TokenAccessManagerSetupLib {

    function setupRoles(IAccessManager accessManager, address token) internal {
        // ------ OWNER role ------
        bytes4[] memory functions = new bytes4[](7);
        functions[0] = Token.setName.selector;
        functions[1] = Token.setSymbol.selector;
        functions[2] = Token.setOnchainID.selector;
        functions[3] = Token.setIdentityRegistry.selector;
        functions[4] = Token.setCompliance.selector;
        functions[5] = Token.setTrustedForwarder.selector;
        functions[6] = Token.setAllowanceForAll.selector;
        accessManager.setTargetFunctionRole(token, functions, RolesLib.OWNER);

        // ------ AGENT_MINTER role ------
        functions = new bytes4[](2);
        functions[0] = Token.mint.selector;
        functions[1] = Token.batchMint.selector;
        accessManager.setTargetFunctionRole(token, functions, RolesLib.AGENT_MINTER);

        // ------ AGENT_BURNER role ------
        functions = new bytes4[](2);
        functions[0] = Token.burn.selector;
        functions[1] = Token.batchBurn.selector;
        accessManager.setTargetFunctionRole(token, functions, RolesLib.AGENT_BURNER);

        // ------ AGENT_PARTIAL_FREEZER role ------
        functions = new bytes4[](4);
        functions[0] = Token.freezePartialTokens.selector;
        functions[1] = Token.batchFreezePartialTokens.selector;
        functions[2] = Token.unfreezePartialTokens.selector;
        functions[3] = Token.batchUnfreezePartialTokens.selector;
        accessManager.setTargetFunctionRole(token, functions, RolesLib.AGENT_PARTIAL_FREEZER);

        // ------ AGENT_ADDRESS_FREEZER role ------
        functions = new bytes4[](2);
        functions[0] = Token.setAddressFrozen.selector;
        functions[1] = Token.batchSetAddressFrozen.selector;
        accessManager.setTargetFunctionRole(token, functions, RolesLib.AGENT_ADDRESS_FREEZER);

        // ------ AGENT_RECOVERY_ADDRESS role ------
        functions = new bytes4[](1);
        functions[0] = Token.recoveryAddress.selector;
        accessManager.setTargetFunctionRole(token, functions, RolesLib.AGENT_RECOVERY_ADDRESS);

        // ------ AGENT_FORCED_TRANSFER role ------
        functions = new bytes4[](2);
        functions[0] = Token.forcedTransfer.selector;
        functions[1] = Token.batchForcedTransfer.selector;
        accessManager.setTargetFunctionRole(token, functions, RolesLib.AGENT_FORCED_TRANSFER);

        // ------ AGENT_PAUSER role ------
        functions = new bytes4[](2);
        functions[0] = Token.pause.selector;
        functions[1] = Token.unpause.selector;
        accessManager.setTargetFunctionRole(token, functions, RolesLib.AGENT_PAUSER);

        // ------ Labeling roles ------
        accessManager.labelRole(RolesLib.OWNER, "TREX-Suite Owner");

        accessManager.labelRole(RolesLib.AGENT, "TREX-Suite Agent");
        accessManager.labelRole(RolesLib.AGENT_MINTER, "TREX-Suite Agent: Minter");
        accessManager.labelRole(RolesLib.AGENT_BURNER, "TREX-Suite Agent: Burner");
        accessManager.labelRole(RolesLib.AGENT_PARTIAL_FREEZER, "TREX-Suite Agent: Partial Freezer");
        accessManager.labelRole(RolesLib.AGENT_ADDRESS_FREEZER, "TREX-Suite Agent: Address Freezer");
        accessManager.labelRole(RolesLib.AGENT_RECOVERY_ADDRESS, "TREX-Suite Agent: Recovery Address");
        accessManager.labelRole(RolesLib.AGENT_FORCED_TRANSFER, "TREX-Suite Agent: Forced Transfer");
        accessManager.labelRole(RolesLib.AGENT_PAUSER, "TREX-Suite Agent: Pauser");
    }

}
