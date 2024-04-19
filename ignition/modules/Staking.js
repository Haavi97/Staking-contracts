const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("StakingModule", (m) => {

  const stakingContract = m.contract("Staking");

  return { stakingContract };
});
