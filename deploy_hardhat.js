const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deployer:", deployer.address);

  // Nustatyk parametrus. Keisk juos pagal poreikį.
  const name = "SXBX Token";
  const symbol = "SXBX";
  const initialSupply = hre.ethers.parseUnits("1000000", 18);
  const treasury = deployer.address;
  const feeBps = 50;

  const SXBX = await hre.ethers.getContractFactory("SXBXToken");
  const token = await SXBX.deploy(name, symbol, initialSupply, treasury, feeBps);
  await token.waitForDeployment();

  console.log("SXBX deployed to:", await token.getAddress());
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});