// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';

contract LuminaExchange is Ownable {
    using ECDSA for bytes32;

    address public signerAddress;
    mapping(uint256 => bool) public usedNonces;

    event TradeExecuted(address indexed token, address indexed seller, address indexed buyer, uint256 amount, uint256 price, uint256 nonce);

    constructor(address _signerAddress) {
        signerAddress = _signerAddress;
    }

    function setSignerAddress(address _signerAddress) external onlyOwner {
        signerAddress = _signerAddress;
    }

    function executeTrade(
        address token,
        address seller,
        address buyer,
        uint256 amount,
        uint256 price,
        uint256 nonce,
        bytes calldata signature
    ) external {
        require(!usedNonces[nonce], 'Nonce already used');

        // Verify signature
        bytes32 messageHash = keccak256(abi.encodePacked(token, seller, buyer, amount, price, nonce));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        address recoveredSigner = ethSignedMessageHash.recover(signature);
        require(recoveredSigner == signerAddress, 'Invalid signature');

        usedNonces[nonce] = true;

        // Execute transfer
        // Note: Seller must have approved this contract
        require(IERC20(token).transferFrom(seller, buyer, amount), 'Token transfer failed');

        emit TradeExecuted(token, seller, buyer, amount, price, nonce);
    }

    // Emergency withdrawal of tokens if any get stuck
    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }
}
