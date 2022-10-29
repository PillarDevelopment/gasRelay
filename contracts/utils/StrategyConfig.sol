// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library StrategyConfig {

    struct StrategyInfo {
        uint256 managementFee; // processing Relayer
        uint256 successFee;
        uint256 gsnFee; // static init Param
        uint256 performanceFee; // Author of strategy - only if success
        address stableToken;
        address dexProtocol;
        address lendingProtocol;
        address derivativesProtocol;
        address assetsProtocol;
        address configOwner;
    }
}
