// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RelayHub is Ownable {

    address public gsnToken;

    address private _relayRegistrar;

    address private _penalizer;

    address private _stakeManager;

    uint256 public baseSlashRateForContravention;

    mapping(address => bool) private _processingRelayers;

    mapping(address => uint256) private _balances;

    // maps ERC-20 token address to a minimum stake for it
    uint256 private _minimumStakePerToken;


    constructor(address gsnToken_,
                address stakeManager_,
                address penalizer_,
                address relayRegistrar_,
                uint256 baseSlashRateForContravention_) {
        require(baseSlashRateForContravention_ < 100, "RelayHubConstructor");
        gsnToken = gsnToken_;
        _stakeManager = stakeManager_; // IStakeManager
        _penalizer = penalizer_;
        _relayRegistrar = relayRegistrar_;
        baseSlashRateForContravention = baseSlashRateForContravention_;
    }


    // ADMIN
    function setMinimumStakes(uint256 minimumStake) public {
        require(_msgSender() == _stakeManager, "RelayHub: Caller is not stakeManager");
        _minimumStakePerToken = minimumStake;
    }


    function registerNewRelayer(address newRelay, uint256 stake) public  {
        require(_msgSender() == _relayRegistrar, "RelayHub: Sender is not registrar");
        require(!isRelayer(newRelay), "RelayHub: Relayer already exist");
        require(stake >= _minimumStakePerToken, "RelayHub: insufficient tokens");
        _processingRelayers[newRelay] = true;
    }


    function remove(address relay) public {
        require(_msgSender() == _relayRegistrar, "RelayHub: Sender is not registrar");
        require(isRelayer(relay), "RelayHub: Relayer isn't exist");
        _processingRelayers[relay] = false;
        IERC20(gsnToken).transferFrom(address(this), relay, _balances[relay]);
        _balances[relay] = 0;
    }


    function penalize(address relayWorker, uint256 beneficiary) public {
        // todo require - penalizer integrity check
        _penalize(relayWorker, beneficiary);
    }

    // RELAY
    function depositFor(address target, uint256 amount) public {
        _balances[target] += amount;
        IERC20(gsnToken).transferFrom(_msgSender(), address(this), amount);
    }


    function getStakeManager() public view returns (address) { // IStakeManager
        return _stakeManager;
    }


    function getPenalizer() public view returns (address) {
        return _penalizer;
    }


    function getRelayRegistrar() public view returns (address) {
        return _relayRegistrar;
    }


    function getMinimumStakePerToken() public view returns (uint256) {
        return _minimumStakePerToken;
    }


    function balanceOf(address target) public view returns (uint256) {
        return _balances[target];
    }


    function isRelayer(address relayer) public view returns(bool) {
        return _processingRelayers[relayer];
    }


    function isActiveRelayer(address relayer) public view returns(bool) {
        return (_balances[relayer] >= _minimumStakePerToken);
    }


    function _penalize(address _processingRelayer, uint256 _amount) private returns(uint256 result) {
        uint256 slashAmount = (_amount * baseSlashRateForContravention) / 100;
        _balances[_processingRelayer] -= slashAmount;
        result -= slashAmount;
    }
}