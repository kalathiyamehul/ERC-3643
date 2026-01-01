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

import "@onchain-id/solidity/contracts/interface/IIdentity.sol";
import "@onchain-id/solidity/contracts/libraries/KeyPurposes.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "../../errors/InvalidArgumentErrors.sol";
import "../interface/IGlobalIdentityRegistryStorage.sol";

/// @dev Thrown when the recovered signer does not match the wallet being registered.
error InvalidSignature();

/// @dev Thrown when the provided signature has expired.
/// @param expiry provided expiry timestamp.
error SignatureExpired(uint256 expiry);

/// @dev Thrown when the wallet does not hold a management key on the identity.
error MissingManagementKey();

/// @dev Thrown when the wallet is not linked to msg.sender during removal.
error WalletNotLinked();

contract GlobalIdentityRegistryStorage is IGlobalIdentityRegistryStorage {

    using ECDSA for bytes32;

    mapping(address wallet => address onchainId) private _walletToIdentity;

    /**
     *  @dev See {IGlobalIdentityRegistryStorage-registerWalletToIdentity}.
     */
    function registerWalletToIdentity(address wallet, bytes calldata signature, uint256 expiry) external {
        if (wallet == address(0)) {
            revert ZeroAddress();
        }

        if (block.timestamp > expiry) {
            revert SignatureExpired(expiry);
        }

        address identity = msg.sender;
        bytes32 structHash = keccak256(abi.encode(wallet, identity, expiry, address(this), block.chainid));

        address signer = _recoverWalletSigner(structHash, signature);
        if (signer != wallet) {
            revert InvalidSignature();
        }

        // require the wallet is a MANAGEMENT key on the identity
        bytes32 key = keccak256(abi.encode(wallet));
        bool hasManagement = IIdentity(identity).keyHasPurpose(key, KeyPurposes.MANAGEMENT);

        if (!hasManagement) {
            revert MissingManagementKey();
        }

        _walletToIdentity[wallet] = identity;
        emit WalletLinked(wallet, identity);
    }

    /**
     *  @dev See {IGlobalIdentityRegistryStorage-unregisterWalletFromIdentity}.
     */
    function unregisterWalletFromIdentity(address wallet) external {
        if (wallet == address(0)) {
            revert ZeroAddress();
        }
        if (_walletToIdentity[wallet] != msg.sender) {
            revert WalletNotLinked();
        }

        delete _walletToIdentity[wallet];
        emit WalletUnlinked(wallet, msg.sender);
    }

    /**
     *  @dev See {IGlobalIdentityRegistryStorage-identityOf}.
     */
    function identityOf(address wallet) external view returns (address) {
        return _walletToIdentity[wallet];
    }

    /**
     *  @dev Recovers the wallet signer from a structHash using the eth_sign prefix.
     *  @param structHash hashed payload binding wallet, identity, expiry, contract and chain id.
     *  @param signature signature provided by the wallet.
     *  @return signer recovered address or address(0) on recover error.
     */
    function _recoverWalletSigner(bytes32 structHash, bytes calldata signature) internal pure returns (address) {
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", structHash));

        (address signer, ECDSA.RecoverError error,) = ECDSA.tryRecover(digest, signature);
        if (error != ECDSA.RecoverError.NoError) {
            return address(0);
        }
        return signer;
    }

}
