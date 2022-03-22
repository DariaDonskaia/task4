const hre = require("hardhat"); 

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address); 

  const MarketPlace = await hre.ethers.getContractFactory("Marketplace"); 
  const marketplace = await MarketPlace.deploy(); 

  await marketplace.deployed(); 

  console.log("Marketplace deployed to:", marketplace.address); 
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 