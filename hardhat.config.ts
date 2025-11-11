import "@nomicfoundation/hardhat-foundry";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomiclabs/hardhat-solhint";
import type { HardhatUserConfig } from "hardhat/config";

const AMOY_RPC="https://polygon-amoy.drpc.org";
const AMOY_PK="0e895bd8dcb30ef51bfb93338fc19dc482dc8efadf7d1a979c1be5f70e9b96b7";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.26",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {},
    btp: {
      url: process.env.BTP_RPC_URL || "",
      gasPrice: 3200000000,
    },
    amoy: {
      url: AMOY_RPC,
      chainId: 80002,
      accounts: AMOY_PK ? [AMOY_PK] : []
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
