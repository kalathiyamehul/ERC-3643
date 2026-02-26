import { ethers, upgrades } from 'hardhat';
import * as fs from 'fs';
import * as path from 'path';

async function main() {
    console.log('🚀 Starting ERC-3643 Token Suite Deployment to Sepolia...\n');

    const [deployer] = await ethers.getSigners();

    console.log('Deploying contracts with account:', deployer.address);
    console.log(
        'Account balance:',
        ethers.utils.formatEther(
            await ethers.provider.getBalance(deployer.address)
        ),
        'ETH\n'
    );

    const deploymentData: any = {
        network: 'sepolia',
        deployer: deployer.address,
        timestamp: new Date().toISOString(),
        contracts: {},
    };

    /* -------------------------------------------------------------------------- */
    /*                           ClaimTopicsRegistry                               */
    /* -------------------------------------------------------------------------- */

    console.log('📝 Deploying ClaimTopicsRegistry...');
    const ClaimTopicsRegistry = await ethers.getContractFactory('ClaimTopicsRegistry');
    const claimTopicsRegistry = await upgrades.deployProxy(
        ClaimTopicsRegistry,
        [],
        { initializer: 'init' }
    );
    await claimTopicsRegistry.deployed();

    const claimTopicsRegistryAddress = claimTopicsRegistry.address;
    console.log('✅ ClaimTopicsRegistry deployed to:', claimTopicsRegistryAddress);
    deploymentData.contracts.claimTopicsRegistry = claimTopicsRegistryAddress;

    /* -------------------------------------------------------------------------- */
    /*                         TrustedIssuersRegistry                               */
    /* -------------------------------------------------------------------------- */

    console.log('\n📝 Deploying TrustedIssuersRegistry...');
    const TrustedIssuersRegistry = await ethers.getContractFactory('TrustedIssuersRegistry');
    const trustedIssuersRegistry = await upgrades.deployProxy(
        TrustedIssuersRegistry,
        [],
        { initializer: 'init' }
    );
    await trustedIssuersRegistry.deployed();

    const trustedIssuersRegistryAddress = trustedIssuersRegistry.address;
    console.log('✅ TrustedIssuersRegistry deployed to:', trustedIssuersRegistryAddress);
    deploymentData.contracts.trustedIssuersRegistry = trustedIssuersRegistryAddress;

    /* -------------------------------------------------------------------------- */
    /*                         IdentityRegistryStorage                               */
    /* -------------------------------------------------------------------------- */

    console.log('\n📝 Deploying IdentityRegistryStorage...');
    const IdentityRegistryStorage = await ethers.getContractFactory('IdentityRegistryStorage');
    const identityRegistryStorage = await upgrades.deployProxy(
        IdentityRegistryStorage,
        [],
        { initializer: 'init' }
    );
    await identityRegistryStorage.deployed();

    const identityRegistryStorageAddress = identityRegistryStorage.address;
    console.log('✅ IdentityRegistryStorage deployed to:', identityRegistryStorageAddress);
    deploymentData.contracts.identityRegistryStorage = identityRegistryStorageAddress;

    /* -------------------------------------------------------------------------- */
    /*                              IdentityRegistry                                */
    /* -------------------------------------------------------------------------- */

    console.log('\n📝 Deploying IdentityRegistry...');
    const IdentityRegistry = await ethers.getContractFactory('IdentityRegistry');
    const identityRegistry = await upgrades.deployProxy(
        IdentityRegistry,
        [
            trustedIssuersRegistryAddress,
            claimTopicsRegistryAddress,
            identityRegistryStorageAddress,
        ],
        { initializer: 'init' }
    );
    await identityRegistry.deployed();

    const identityRegistryAddress = identityRegistry.address;
    console.log('✅ IdentityRegistry deployed to:', identityRegistryAddress);
    deploymentData.contracts.identityRegistry = identityRegistryAddress;

    /* -------------------- Bind IdentityRegistry to Storage --------------------- */

    console.log('\n🔗 Binding IdentityRegistry to IdentityRegistryStorage...');
    const txBind = await identityRegistryStorage.bindIdentityRegistry(
        identityRegistryAddress
    );
    await txBind.wait();
    console.log('✅ IdentityRegistry bound to storage');

    /* -------------------------------------------------------------------------- */
    /*                             ModularCompliance                                */
    /* -------------------------------------------------------------------------- */

    console.log('\n📝 Deploying ModularCompliance...');
    const ModularCompliance = await ethers.getContractFactory('ModularCompliance');
    const modularCompliance = await upgrades.deployProxy(
        ModularCompliance,
        [],
        { initializer: 'init' }
    );
    await modularCompliance.deployed();

    const modularComplianceAddress = modularCompliance.address;
    console.log('✅ ModularCompliance deployed to:', modularComplianceAddress);
    deploymentData.contracts.modularCompliance = modularComplianceAddress;

    /* -------------------------------------------------------------------------- */
    /*                                    Token                                     */
    /* -------------------------------------------------------------------------- */

    console.log('\n📝 Deploying Token...');
    const Token = await ethers.getContractFactory('Token');

    const tokenName = 'Security Token';
    const tokenSymbol = 'SEC';
    const tokenDecimals = 18;
    const tokenOnchainID = ethers.constants.AddressZero;

    const token = await upgrades.deployProxy(
        Token,
        [
            identityRegistryAddress,
            modularComplianceAddress,
            tokenName,
            tokenSymbol,
            tokenDecimals,
            tokenOnchainID,
        ],
        { initializer: 'init' }
    );
    await token.deployed();

    const tokenAddress = token.address;
    console.log('✅ Token deployed to:', tokenAddress);

    deploymentData.contracts.token = tokenAddress;
    deploymentData.tokenInfo = {
        name: tokenName,
        symbol: tokenSymbol,
        decimals: tokenDecimals,
    };

    /* ----------------------------- Grant AGENT_ROLE ---------------------------- */

    /* ----------------------------- Add Agent ---------------------------- */

    console.log('\n🔑 Adding deployer as Agent...');
    const txAgent = await token.addAgent(deployer.address);
    await txAgent.wait();
    console.log('✅ Deployer added as Agent');


    /* -------------------------------------------------------------------------- */
    /*                               Save Deployment                                */
    /* -------------------------------------------------------------------------- */

    // const deploymentsDir = path.join(__dirname, '..', 'deployments');
    // if (!fs.existsSync(deploymentsDir)) {
    //     fs.mkdirSync(deploymentsDir, { recursive: true });
    // }

    // const deploymentFile = path.join(deploymentsDir, 'sepolia-deployment.json');
    // fs.writeFileSync(deploymentFile, JSON.stringify(deploymentData, null, 2));

    // console.log('\n💾 Deployment data saved to:', deploymentFile);

    /* -------------------------------------------------------------------------- */
    /*                                  Summary                                     */
    /* -------------------------------------------------------------------------- */

    console.log('\n' + '='.repeat(80));
    console.log('🎉 DEPLOYMENT COMPLETE');
    console.log('='.repeat(80));

    console.log('\nDeployed Contracts:');
    console.log('ClaimTopicsRegistry     :', claimTopicsRegistryAddress);
    console.log('TrustedIssuersRegistry  :', trustedIssuersRegistryAddress);
    console.log('IdentityRegistryStorage :', identityRegistryStorageAddress);
    console.log('IdentityRegistry        :', identityRegistryAddress);
    console.log('ModularCompliance       :', modularComplianceAddress);
    console.log('Token                   :', tokenAddress);

    console.log('\nToken Info:');
    console.log('Name     :', tokenName);
    console.log('Symbol   :', tokenSymbol);
    console.log('Decimals :', tokenDecimals);

    console.log('\n📋 Next Steps:');
    console.log('1. Verify proxy contracts on Etherscan');
    console.log('2. Add claim topics');
    console.log('3. Add trusted issuers');
    console.log('4. Unpause token');
    console.log('5. Mint tokens');

    console.log('\n' + '='.repeat(80) + '\n');
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
