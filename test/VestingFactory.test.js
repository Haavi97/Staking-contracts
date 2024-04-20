const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VestingFactory", function () {
  let VestingFactory;
  let vestingFactory;
  let TestToken;
  let testToken;
  let owner;
  let otherAccount;

  beforeEach(async function () {
    TestToken = await ethers.getContractFactory("TestToken");
    VestingFactory = await ethers.getContractFactory("VestingFactory");
    [owner, otherAccount] = await ethers.getSigners();
    testToken = await TestToken.deploy(owner);
    vestingFactory = await VestingFactory.deploy();
    console.log("TestToken deployed to:", testToken.address);
    console.log("VestingFactory deployed to:", vestingFactory.address);
  });

  it("should deploy a Vesting contract", async function () {
    const tokenAddress = testToken.address;
    const baseReward = 5;
    const apy = 120;
    const swapRate = 10;
    const timePeriod = 60;
    const tx = await vestingFactory.createVestingContract(
      tokenAddress,
      baseReward,
      apy,
      swapRate,
      timePeriod
    );
    await tx.wait();

    const vestingContractAddress =
      await vestingFactory.deployedVestingContracts(0);
    const vestingContract = await ethers.getContractFactory("Vesting");
    const contractInstance = await vestingContract.attach(
      vestingContractAddress
    );

    expect(await contractInstance.getAddress()).to.not.be.undefined;
  });

  it("should set the caller as the owner of the newly created Vesting contract", async function () {
    const tx = await vestingFactory.createVestingContract();
    await tx.wait();

    const vestingContractAddress =
      await vestingFactory.deployedVestingContracts(0);
    const vestingContract = await ethers.getContractFactory("Vesting");
    const contractInstance = await vestingContract.attach(
      vestingContractAddress
    );

    const ownerAddress = await contractInstance.owner();
    expect(ownerAddress).to.equal(owner.address);
  });
});

describe("Vesting", function () {
  let Vesting;
  let vesting;
  let owner;
  let otherAccount;

  beforeEach(async function () {
    Vesting = await ethers.getContractFactory("Vesting");
    [owner, otherAccount] = await ethers.getSigners();
    vesting = await Vesting.deploy(owner);
  });

  it("should be able to change the token set", async function () {
    await vesting.setToken(otherAccount);

    expect(await vesting.tokenA()).to.be.equal(otherAccount);
  });

  // it("should stake an amount", async function () {
  //   const amount = 0;

  //   await expect(await vesting.stake(amount)).to.be.revertedWith(
  //     "stake must be > 0"
  //   );
  // });

  // it("should calculate the reward", async function () {
  //   const index = 0;

  //   await vesting.calculateReward(index);

  //   // Add assertions here to check if the calculateReward function is working as expected
  // });

  // it("should claim the reward", async function () {
  //   const index = 0;
  //   const amount = 100; // replace with the actual staked amount
  //   const startTime = 1635000000; // replace with the actual start time of the stake
  //   const apy = 5; // replace with the actual APY value

  //   const expectedReward = calculateReward(amount, startTime, apy);

  //   await vesting.claimReward(index);

  //   // Add assertions here to check if the claimReward function is working as expected
  //   const reward = await vesting.getReward(index);
  //   expect(reward).to.equal(expectedReward);
  // });

  // it("should stake the reward", async function () {
  //   const index = 0;

  //   await vesting.stakeReward(index);

  //   // Add assertions here to check if the stakeReward function is working as expected
  // });

  // it("should decrease the stake", async function () {
  //   const index = 0;

  //   await vesting.decreaseStake(index);

  //   // Add assertions here to check if the decreaseStake function is working as expected
  // });

  // it("should unstake", async function () {
  //   const index = 0;

  //   await vesting.unstake(index);

  //   // Add assertions here to check if the unstake function is working as expected
  // });
});
