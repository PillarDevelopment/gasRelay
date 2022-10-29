require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('@nomiclabs/hardhat-truffle5');
require('dotenv').config();
require('hardhat-deploy');
require('hardhat-gas-reporter');
require('solidity-coverage');
require('hardhat-contract-sizer');
require('hardhat-spdx-license-identifier');
require('hardhat-abi-exporter');
require('hardhat-storage-layout');
require('@openzeppelin/hardhat-upgrades');
require('@primitivefi/hardhat-marmite');

const {MAINNET_ETHERSCAN_KEY} = process.env;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: {
      compilers: [
          {
              version: "0.8.17",
              settings: {
                  optimizer: {
                      enabled: true,
                      runs: 1000000,
                  },
                  outputSelection: {
                      "*": {
                          "*": ["storageLayout"],
                      },
                  },
              },
          }
      ],
  },
    networks: {
        localhost: {
        }
    },
    etherscan: {
        apiKey: MAINNET_ETHERSCAN_KEY
  },
    gasReporter: {
    enable: true,
    currency: 'USD',
  },
    contractSizer: {
      alphaSort: true,
        disambiguatePaths: true,
        runOnCompile: true,
        strict: false,
    },
    spdxLicenseIdentifier: {
        overwrite: false,
        runOnCompile: true,
    },
     abiExporter: {
        path: './abi',
         runOnCompile: true,
         clear: true,
         flat: true,
         only: [''],
         spacing: 2,
         pretty: true,
    }
};