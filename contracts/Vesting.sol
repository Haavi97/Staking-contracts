// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vesting is Ownable {
    event TokensVested(address indexed worker, uint256 tokens);
    //***********STATE VARIABLES*************
    struct Worker {
        uint256 startTime; // The time when the worker starts earning tokens
        bool hasWithdrawn;
        uint256 finalBalance;
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
    bool public isClaimOpen = false;

    //*********CONSTRUCTOR*************
    constructor(
        address _tokenAddress,
        uint _baseReward,
        uint _apy,
        uint _swapRate,
        uint _timePeriod
    ) {
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
            revert NotWorker(msg.sender, "you have 0 reward");
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

        workersMapping[_worker] = Worker(block.timestamp, false, 0);
        workersArray.push(_worker);
    }
    // Function to set token token address dynamically
    function setToken(address _tokenAddress) external onlyOwner {
        tokenA = IERC20(_tokenAddress);
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

    //workers can see how much they will earn if they stick to the end of vesting period
    uint public unbrokenAmount;
    //Company will use this function to calculate unbrokenAmount and later workers who did
    //not withdraw will be rewarded this exact amount. It will save finalizeVesting function
    //from making unnecessary computations
    function calculateUnbroken() external onlyOwner {
        uint balance;
        for (uint256 index = 1; index < timePeriod + 1; index++) {
            balance = balance + (baseReward + (((balance) * apy) / 1000));
        }
        unbrokenAmount = balance;
    }

    //**********MAIN FUNCTIONS************
    function finalizeVesting() external onlyOwner {
        for (uint256 i = 0; i < workersArray.length; i++) {
            address targetWorker = workersArray[i];

            // Workers who didn not withdraw, we know their total reward+apy
            // For workers who withdraw, we need to calculate as below
            if (workersMapping[targetWorker].hasWithdrawn == true) {
                //First find how many months passed since last withdraw
                uint rewardStart = workersMapping[targetWorker].startTime;
                uint monthsPassed = (block.timestamp - rewardStart) / (30 days);
                //Then we create balance variable to store total reward+apy
                uint balance;
                for (uint256 index = 1; index < monthsPassed + 1; index++) {
                    balance =
                        balance +
                        (baseReward + (((balance) * apy) / 1000));
                }
                workersMapping[targetWorker].finalBalance = balance;
            } else {
                workersMapping[targetWorker].finalBalance = unbrokenAmount;
            }
        }
        isClaimOpen = true;
    }

    // Function to declare profits and reward workers proportionally
    function claimReward() external onlyWorkers {
        require(isClaimOpen, "Claiming is not open yet");
        uint rewardAmount = workersMapping[msg.sender].finalBalance;
        require(rewardAmount > 0, "You have already withdrawn final reward");
        workersMapping[msg.sender].finalBalance = 0;
        //The weird calculation here is to accommodate decimal swap rates such as %0.1
        uint amount = (rewardAmount / (10 / swapRate)) * (10 ** 18);
        tokenA.transfer(msg.sender, amount);
    }

    //Workers will be able to withdraw tokens before company profit reporting
    //decimals handled inside the function.
    function withdrawTokens() external onlyWorkers {
        //first we calculate how many months passed
        uint rewardStart = workersMapping[msg.sender].startTime;
        uint monthsPassed = (block.timestamp - rewardStart) / (30 days);
        uint reward = (apy*baseReward*monthsPassed + baseReward)*monthsPassed;
        //Then we create balance variable to store total reward+apy
        uint balance;
        for (uint256 index = 1; index < monthsPassed + 1; index++) {
            balance = balance + (baseReward + (((balance) * apy) / 1000));
        }
        workersMapping[msg.sender].startTime = block.timestamp;
        workersMapping[msg.sender].hasWithdrawn = true;
        //The weird calculation here is to accommodate decimal swap rates such as %0.1
        uint amount = (balance / (10 / swapRate)) * (10 ** 18);
        tokenA.transfer(msg.sender, amount);
    }

    //MORE FUNCTIONS:
    //Resetting mapping after each profit declation by the company
    //Security checks
    //more view functions
    //Integrate vestTokens function to declareProfits with a forLoop
    //add a pauseStatus security check to the contract
    //withdraw tokens will be called by user account or else?
}
