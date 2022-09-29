const { ethers } = require("hardhat");
// const { ethers } = require("ethers");

async function main() {
  [owner] = await ethers.getSigners();

  const Aviral = await ethers.getContractFactory("Aviral", owner);
  aviral = await Aviral.deploy();

  const address = aviral.address;

  const Staking = await ethers.getContractFactory("Staking", owner);
  const staking = await Staking.deploy(170538, address, 20);

  const Chainlink = await ethers.getContractFactory("Chainlink", owner);
  chainlink = await Chainlink.deploy();
  // const Aviral = await ethers.getContractFactory("Aviral", owner);
  // aviral = await Aviral.deploy();
  const Jeevansh = await ethers.getContractFactory("Jeevansh", owner);
  jeevansh = await Jeevansh.deploy();
  const Amulya = await ethers.getContractFactory("Amulya", owner);
  amulya = await Amulya.deploy();

  console.log("Staking:", staking.address);
  console.log("Chainlink:", chainlink.address);
  console.log("Jeevansh:", jeevansh.address);
  console.log("Amulya:", amulya.address);

  await chainlink
    .connect(owner)
    .approve(staking.address, ethers.utils.parseEther("100"));
  chainlink.approve(staking.address, 20);
  await staking.connect(owner).stakeTokens(ethers.utils.parseEther("100"));

  await aviral
    .connect(owner)
    .approve(staking.address, ethers.utils.parseEther("100"));
  await staking
    .connect(owner)
    .stakeTokens("AVI", ethers.utils.parseEther("100"));

  await jeevansh
    .connect(owner)
    .approve(staking.address, ethers.utils.parseEther("100"));
  await staking
    .connect(owner)
    .stakeTokens("JEEV", ethers.utils.parseEther("100"));

  await amulya
    .connect(owner)
    .approve(staking.address, ethers.utils.parseEther("100"));
  await staking
    .connect(owner)
    .stakeTokens("AMUL", ethers.utils.parseEther("100"));

  const provider = waffle.provider;
  const block = await provider.getBlock();
  const newCreatedDate = block.timestamp - 86400 * 365;
  await staking.connect(owner).modifyCreateDate(1, newCreatedDate);
  await staking.connect(owner).modifyCreateDate(2, newCreatedDate);
  await staking.connect(owner).modifyCreateDate(3, newCreatedDate);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
