import { ethers } from 'hardhat';

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log('Deploying contracts with the account:', deployer.address);

    const PropertyGovernance = await ethers.getContractFactory('PropertyGovernance');
    const governance = await PropertyGovernance.deploy();

    await governance.deployed();

    console.log('PropertyGovernance deployed to:', governance.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
