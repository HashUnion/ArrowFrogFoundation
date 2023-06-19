import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';
import "@nomiclabs/hardhat-etherscan";
import "./tasks/deploy";
import "./tasks/upgrade";

require('dotenv').config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    }
  },
  networks: {
    hardhat: {
      // forking: {
      //   url: "https://eth-mainnet.g.alchemy.com/v2/fwuqKRRhwulnPAcVtxf-lEGrvLt_nuIL",
      //   blockNumber: 17505190
      // },
      mining: {
        auto: true,
        interval: 5000
      },
      accounts: {
        mnemonic: process.env["MNEMONIC"] as string
      },
      loggingEnabled: true
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
    mumbai: {
      url: process.env["RPC_URL_MUMBAI"] as string,
      accounts: {
        mnemonic: process.env["MNEMONIC"] as string
      },
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env["ETHERSCAN_API_KEY_MUMBAI"] as string
    }
  }
};

export default config;