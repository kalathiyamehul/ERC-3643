# ERC-3643 Token Deployment Guide

## Prerequisites

Before deploying, ensure you have:

1. **Node.js and npm** installed
2. **Sepolia testnet ETH** in your deployer wallet (get from [Sepolia Faucet](https://sepoliafaucet.com/))
3. **RPC Provider** account (Infura, Alchemy, or similar)
4. **Etherscan API Key** for contract verification

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
npm install --save-dev dotenv
```

### 2. Configure Environment Variables

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Edit `.env` and fill in your credentials:

```env
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key
```

> ⚠️ **IMPORTANT**: Never commit the `.env` file to version control!

### 3. Compile Contracts

```bash
npm run build
```

### 4. Deploy to Sepolia

```bash
npx hardhat run scripts/deploy-sepolia.ts --network sepolia
```

The deployment script will:
- Deploy all 6 contracts (ClaimTopicsRegistry, TrustedIssuersRegistry, IdentityRegistryStorage, IdentityRegistry, ModularCompliance, Token)
- Initialize each contract with proper parameters
- Link dependencies between contracts
- Grant deployer the AGENT_ROLE on the Token contract
- Save deployment addresses to `deployments/sepolia-deployment.json`

### 5. Verify Contracts on Etherscan

After deployment, verify each contract:

```bash
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

For contracts with constructor arguments, you'll need to provide them:

```bash
npx hardhat verify --network sepolia <IDENTITY_REGISTRY_ADDRESS> <TRUSTED_ISSUERS_REGISTRY> <CLAIM_TOPICS_REGISTRY> <IDENTITY_STORAGE>
```

## Deployed Contracts

After successful deployment, you'll find all contract addresses in:
- `deployments/sepolia-deployment.json`

## Post-Deployment Configuration

### 1. Configure Claim Topics (Optional)

If you want to require specific claims from token holders:

```typescript
// Add a claim topic (e.g., KYC verification)
await claimTopicsRegistry.addClaimTopic(1);
```

### 2. Add Trusted Issuers (Optional)

If you're using claim-based verification:

```typescript
// Add a trusted claim issuer
await trustedIssuersRegistry.addTrustedIssuer(issuerAddress, [1]);
```

### 3. Unpause the Token

The token is deployed in a paused state. To enable transfers:

```typescript
await token.unpause();
```

### 4. Mint Tokens

As an agent, you can mint tokens to verified addresses:

```typescript
// First, register the investor's identity
await identityRegistry.registerIdentity(investorAddress, identityContract, countryCode);

// Then mint tokens
await token.mint(investorAddress, amount);
```

## Troubleshooting

### "Insufficient funds" Error
- Ensure your deployer wallet has enough Sepolia ETH
- Deployment typically costs 0.05-0.1 ETH on testnets

### "Invalid Implementation Authority" Error
- This usually means contracts weren't deployed in the correct order
- Re-run the deployment script

### "Module not found: dotenv"
- Run: `npm install --save-dev dotenv`

## Security Notes

- The deployer address is automatically granted AGENT_ROLE
- The token starts in a paused state for safety
- Keep your private key secure and never share it
- Consider using a hardware wallet for mainnet deployments

## Contract Addresses

After deployment, your contract addresses will be saved in `deployments/sepolia-deployment.json`. Keep this file for reference!
