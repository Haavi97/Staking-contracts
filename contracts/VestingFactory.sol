// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vesting.sol";

contract VestingFactory {
    address[] public deployedVestingContracts;

    function createVestingContract(
        address _tokenAddress,
        uint _baseReward,
        uint _apy,
        uint _swapRate,
        uint _timePeriod,
        address _initialOwner
    ) public {
        address newVestingContract = address(
            new Vesting(
                _tokenAddress,
                _baseReward,
                _apy,
                _swapRate,
                _timePeriod,
                _initialOwner
            )
        );
        deployedVestingContracts.push(newVestingContract);
    }

    function getDeployedVestingContracts()
        public
        view
        returns (address[] memory)
    {
        return deployedVestingContracts;
    }
}
