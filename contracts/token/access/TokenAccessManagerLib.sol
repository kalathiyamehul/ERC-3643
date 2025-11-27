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

pragma solidity 0.8.30;

import { IAccessManager } from "@openzeppelin/contracts/access/manager/IAccessManager.sol";

import { Token } from "../Token.sol";
import { TokenRolesLib } from "./TokenRolesLib.sol";

/// @title TokenAccessManagerLib
/// @notice Library for setting up roles and functions in AccessManager for the Token contract
library TokenAccessManagerLib {

    function setupRoles(IAccessManager accessManager, address token) internal {
        // ------ ADMIN role ------
        bytes4[] memory functions = new bytes4[](5);
        functions[0] = Token.setName.selector;
        functions[1] = Token.setSymbol.selector;
        functions[2] = Token.setOnchainID.selector;
        functions[3] = Token.setIdentityRegistry.selector;
        functions[4] = Token.setCompliance.selector;
        accessManager.setTargetFunctionRole(token, functions, TokenRolesLib.ADMIN);

        // ------ AGENT_MINTER role ------
        functions = new bytes4[](1);
        functions[0] = Token.mint.selector;
        accessManager.setTargetFunctionRole(token, functions, TokenRolesLib.AGENT_MINTER);

        // ------ AGENT_BURNER role ------
        functions = new bytes4[](1);
        functions[0] = Token.burn.selector;
        accessManager.setTargetFunctionRole(token, functions, TokenRolesLib.AGENT_BURNER);

        // ------ AGENT_PARTIAL_FREEZER role ------
        functions = new bytes4[](1);
        functions[0] = Token.freezePartialTokens.selector;
        accessManager.setTargetFunctionRole(token, functions, TokenRolesLib.AGENT_PARTIAL_FREEZER);

        // ------ AGENT_ADDRESS_FREEZER role ------
        functions = new bytes4[](1);
        functions[0] = Token.setAddressFrozen.selector;
        accessManager.setTargetFunctionRole(token, functions, TokenRolesLib.AGENT_ADDRESS_FREEZER);

        // ------ AGENT_RECOVERY_ADDRESS role ------
        functions = new bytes4[](1);
        functions[0] = Token.recoveryAddress.selector;
        accessManager.setTargetFunctionRole(token, functions, TokenRolesLib.AGENT_RECOVERY_ADDRESS);

        // ------ AGENT_FORCED_TRANSFER role ------
        functions = new bytes4[](1);
        functions[0] = Token.forcedTransfer.selector;
        accessManager.setTargetFunctionRole(token, functions, TokenRolesLib.AGENT_FORCED_TRANSFER);

        // ------ AGENT_PAUSER role ------
        functions = new bytes4[](2);
        functions[0] = Token.pause.selector;
        functions[1] = Token.unpause.selector;
        accessManager.setTargetFunctionRole(token, functions, TokenRolesLib.AGENT_PAUSER);

        // ------ Labeling roles ------
        accessManager.labelRole(TokenRolesLib.ADMIN, "Token Admin");

        accessManager.labelRole(TokenRolesLib.AGENT_MINTER, "Token Agent: Minter");
        accessManager.labelRole(TokenRolesLib.AGENT_BURNER, "Token Agent: Burner");
        accessManager.labelRole(TokenRolesLib.AGENT_PARTIAL_FREEZER, "Token Agent: Partial Freezer");
        accessManager.labelRole(TokenRolesLib.AGENT_ADDRESS_FREEZER, "Token Agent: Address Freezer");
        accessManager.labelRole(TokenRolesLib.AGENT_RECOVERY_ADDRESS, "Token Agent: Recovery Address");
        accessManager.labelRole(TokenRolesLib.AGENT_FORCED_TRANSFER, "Token Agent: Forced Transfer");
        accessManager.labelRole(TokenRolesLib.AGENT_PAUSER, "Token Agent: Pauser");
    }

}
