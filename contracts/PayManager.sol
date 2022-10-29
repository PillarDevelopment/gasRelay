// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./utils/FullMath.sol";
import "./utils/StrategyConfig.sol";
import "./interfaces/IRelayHub.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PayManager is Context {

    address public gsnToken;

    address[] private _gasRelayers;

    mapping(address => bool) private _isRelayers;

    mapping(address => uint256) private _accumulatedGasFee; // gas Relayer

    mapping(address => uint256) private _lastNonce;

    uint256 private _rate;

    address private _strategy;

    //DEBUG
    // _rate - abstract variable for conversation used gas to GSN tokens
    function setRate(uint256 newRate) public {
        _rate = newRate;
    }


    function claimGasCompensation() public {
        // checking epoch (???)
        uint256 costs = _accumulatedGasFee[_msgSender()];
        uint256 tokenAmount = costs * _rate; // todo ????
        _accumulatedGasFee[_msgSender()] = 0;
        IERC20(gsnToken).transfer(_msgSender(), tokenAmount);
    }


    function getCosts(address _gasRelayer) public view returns(uint256) {
        return _accumulatedGasFee[_gasRelayer];
    }


    function getRate() public view returns(uint256) {
        return _rate;
    }


    function getAvailableTokens(address gasRelayer) public view returns(uint256) {
        return _accumulatedGasFee[gasRelayer] * _rate;
    }


    function getAccumulatedGasFee() public view returns(uint256) {
        uint256 aggregatedCosts;
        for(uint i = 0; i < _gasRelayers.length; i++) {
            aggregatedCosts += _accumulatedGasFee[_gasRelayers[i]];
        }
        return aggregatedCosts;
    }



    function _addCosts(address gasRelayer, uint256 costs) internal {
        // require(msgForSign.nonce >= _lastNonce[gasRelayer] && msgForSign.nonce > 0, "PayManager: incorrect nonce");
        if (!_isRelayers[gasRelayer]) {
            _gasRelayers.push(gasRelayer);
        }
        _accumulatedGasFee[gasRelayer] += costs;
    }
}