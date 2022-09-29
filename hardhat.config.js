/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
require("hardhat-gas-reporter");
const { PRIVATE_KEY } = process.env;
module.exports = {
  solidity: {
    version: "0.8.9",
  },
  networks: {
    hardhat: {},
    PolygonMumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [PRIVATE_KEY],
    },
  },
  paths: {
    artifacts: "./clients/src/artifacts",
  },
};
