// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRelayHub {

    function isRelayer(address _relayer) external view returns(bool);

    function reward(address _processingRelayer,
                    address _gasRelayer,
                    uint256 _amount,
                    bytes memory signature,
                    bytes32 msgForSign) external view returns(bool);
}
