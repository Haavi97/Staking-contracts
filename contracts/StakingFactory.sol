// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Staking.sol";

contract StakingFactory {
    address[] public deployedStakingContracts;

    function createStakingContract() public {
        address newStakingContract = address(new Staking(msg.sender));
        deployedStakingContracts.push(newStakingContract);
    }

    function getDeployedStakingContracts() public view returns (address[] memory) {
        return deployedStakingContracts;
    }
}