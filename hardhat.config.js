require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

/**  import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.24",
  networks: {
    mumbai: {
      url: process.env.PROVIDER_URL_TEST,
      accounts: [`0x${process.env.PRIVATE_KEY_TEST}`],
    },
    polygon: {
      url: process.env.PROVIDER_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
  gasReporter: {
    currency: "EUR",
    L1: "ethereum",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
};
