// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vesting is Ownable {
    event WorkerAdded(address indexed worker);
    event RewardWithdrawn(address indexed worker, uint256 amount);

    //***********STATE VARIABLES*************
    struct Worker {
        uint256 startTime; // The time when the worker starts earning tokens
        uint256 tokensEarned;
    }

    mapping(address => Worker) public workersMapping; // Maps worker addresses to their details
    address[] public workersArray;

    IERC20 public tokenA; // vesting token
    uint public baseReward; // amount of token rewards per month per worker
    uint public apy; //Will be used for distribute rewards function after company profit reporting
    //apy "1" means %0,1
    //apy "10" means %1
    //apy "100" means %10
    uint public swapRate; //Swap rate for usdt.
    //swapRate "1" means 10 company token is equal to 1 usdt token
    //swapRate "10" means 10 company token is equal to 10 usdt token
    //swapRate "100" means 10 company token is equal to 100 usdt token
    //Calculations are done
    uint public timePeriod; //number of months that needs to pass before company profit reporting. Like 6, 12
    //this will be used to prevent workers to claim final rewards before vesting period ends
    bool public isPaused = false;

    //*********CONSTRUCTOR*************
    constructor(
        address _tokenAddress,
        uint _baseReward,
        uint _apy,
        uint _swapRate,
        uint _timePeriod,
        address initialOwner
    ) Ownable(initialOwner) {
        tokenA = IERC20(_tokenAddress);
        baseReward = _baseReward;
        apy = _apy;
        swapRate = _swapRate;
        timePeriod = _timePeriod;
    }

    //MODIFIERS
    error NotWorker(address caller, string message);
    modifier onlyWorkers() {
        if (workersMapping[msg.sender].startTime == 0) {
            revert NotWorker(msg.sender, "you have 0 rewards");
        }
        _;
    }

    //********SUPPORT FUNCTIONS**************

    // Function to add a worker and start vesting
    function addWorker(address _worker) external onlyOwner {
        require(
            workersMapping[_worker].startTime == 0,
            "Worker already exists"
        );
        workersMapping[_worker] = Worker(block.timestamp, 0);
        workersArray.push(_worker);
        emit WorkerAdded(_worker);
    }

    // Function to set token token address dynamically
    function setToken(address _tokenAddress) external onlyOwner {
        tokenA = IERC20(_tokenAddress);
    }

    function togglePause() external onlyOwner {
        isPaused = !isPaused;
    }

    //Company will provide liquidity to the contract so that we can distribute rewards later.
    //approval of this contract will be needed by the company before sending tokens. Approval button
    //will be created by using token contract instance on the frontend. I can help with that.
    //decimals handled inside the function.
    function provideLiquidity(uint _amount) external onlyOwner {
        require(msg.sender != address(0), "Invalid depositor");
        require(_amount > 0, "deposit amount must be > 0");
        uint amount = _amount * (10 ** 18);
        tokenA.transferFrom(msg.sender, address(this), amount);
    }

    //People can see how much will earn by entering any number of months
    function calculateReward(uint _numberMonths) external view returns (uint) {
        require(
            _numberMonths < 100 && _numberMonths > 0,
            "please enter a valid number"
        );
        uint rewardAmount = (((apy / 1000) * _numberMonths) + baseReward) *
            _numberMonths;
        return rewardAmount;
    }

    //**********MAIN FUNCTION************
    //Workers will be able to withdraw tokens before company profit reporting
    //decimals handled inside the function.
    function withdrawTokens() external onlyWorkers {
        require(isPaused == false, "Contract is paused");
        //first we calculate how many months passed
        uint rewardStart = workersMapping[msg.sender].startTime;
        uint monthsPassed = (block.timestamp - rewardStart) / (30 days);
        if (monthsPassed > timePeriod) {
            monthsPassed = timePeriod;
        }
        //Divide apy by 1000 to accommodate apy under 10. Then multiply with monthsPassed. Then add baseReward
        //Then multiply with months passed
        uint rewardAmount = (((apy / 1000) * monthsPassed) + baseReward) *
            monthsPassed;

        workersMapping[msg.sender].startTime = block.timestamp;
        workersMapping[msg.sender].tokensEarned += rewardAmount;
        //The weird calculation here is to accommodate decimal swap rates such as %0.1
        uint amount = (rewardAmount / (10 / swapRate)) * (10 ** 18);
        tokenA.transfer(msg.sender, amount);
        emit RewardWithdrawn(msg.sender, rewardAmount);
    }

    //add a pauseStatus security check to the contract
    //withdraw tokens will be called by user account or else?

    function displayRewards() external view onlyWorkers returns (uint) {
        uint rewardStart = workersMapping[msg.sender].startTime;
        uint monthsPassed = (block.timestamp - rewardStart) / (30 days);
        if (monthsPassed > timePeriod) {
            monthsPassed = timePeriod;
        }
        //Divide apy by 1000 to accommodate apy under 10. Then multiply with monthsPassed. Then add baseReward
        //Then multiply with months passed
        uint rewardAmount = (((apy / 1000) * monthsPassed) + baseReward) *
            monthsPassed;
        return rewardAmount;
    }
}
