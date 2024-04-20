const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StakingFactory", function () {
  let StakingFactory;
  let stakingFactory;
  let owner;
  let otherAccount;

  beforeEach(async function () {
    StakingFactory = await ethers.getContractFactory("StakingFactory");
    [owner, otherAccount] = await ethers.getSigners();
    stakingFactory = await StakingFactory.deploy();
  });

  it("should deploy a Staking contract", async function () {
    const tx = await stakingFactory.createStakingContract();
    await tx.wait();

    const stakingContractAddress =
      await stakingFactory.deployedStakingContracts(0);
    const stakingContract = await ethers.getContractFactory("Staking");
    const contractInstance = await stakingContract.attach(
      stakingContractAddress
    );

    expect(await contractInstance.getAddress()).to.not.be.undefined;
  });

  it("should set the caller as the owner of the newly created Staking contract", async function () {
    const tx = await stakingFactory.createStakingContract();
    await tx.wait();

    const stakingContractAddress =
      await stakingFactory.deployedStakingContracts(0);
    const stakingContract = await ethers.getContractFactory("Staking");
    const contractInstance = await stakingContract.attach(
      stakingContractAddress
    );

    const ownerAddress = await contractInstance.owner();
    expect(ownerAddress).to.equal(owner.address);
  });
});

describe("Staking", function () {
  let Staking;
  let staking;
  let owner;
  let otherAccount;

  beforeEach(async function () {
    Staking = await ethers.getContractFactory("Staking");
    [owner, otherAccount] = await ethers.getSigners();
    staking = await Staking.deploy(owner);
  });

  it("should be able to change the token set", async function () {
    await staking.setToken(otherAccount);

    expect(await staking.tokenA()).to.be.equal(otherAccount);
  });

  // it("should stake an amount", async function () {
  //   const amount = 0;

  //   await expect(await staking.stake(amount)).to.be.revertedWith(
  //     "stake must be > 0"
  //   );
  // });

  // it("should calculate the reward", async function () {
  //   const index = 0;

  //   await staking.calculateReward(index);

  //   // Add assertions here to check if the calculateReward function is working as expected
  // });

  // it("should claim the reward", async function () {
  //   const index = 0;
  //   const amount = 100; // replace with the actual staked amount
  //   const startTime = 1635000000; // replace with the actual start time of the stake
  //   const apy = 5; // replace with the actual APY value

  //   const expectedReward = calculateReward(amount, startTime, apy);

  //   await staking.claimReward(index);

  //   // Add assertions here to check if the claimReward function is working as expected
  //   const reward = await staking.getReward(index);
  //   expect(reward).to.equal(expectedReward);
  // });

  // it("should stake the reward", async function () {
  //   const index = 0;

  //   await staking.stakeReward(index);

  //   // Add assertions here to check if the stakeReward function is working as expected
  // });

  // it("should decrease the stake", async function () {
  //   const index = 0;

  //   await staking.decreaseStake(index);

  //   // Add assertions here to check if the decreaseStake function is working as expected
  // });

  // it("should unstake", async function () {
  //   const index = 0;

  //   await staking.unstake(index);

  //   // Add assertions here to check if the unstake function is working as expected
  // });
});
