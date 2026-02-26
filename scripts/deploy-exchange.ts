import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying LuminaExchange with the account:", deployer.address);

    // Use the deployer address as the initial signer for convenience,
    // or a specific treasury address if known.
    const signerAddress = deployer.address;

    const LuminaExchange = await ethers.getContractFactory("LuminaExchange");
    const exchange = await LuminaExchange.deploy(signerAddress);

    await exchange.deployed();

    console.log("LuminaExchange deployed to:", exchange.address);
    console.log("Signer address set to:", signerAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
