const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const OWNER = '0x3C7aEF7d580D82A679CC3B287934b894d99043Db';

module.exports = buildModule("StakingModule", (m) => {
  const owner = m.getParameter("initialOwner", OWNER);

  const stakingContract = m.contract("Staking", [owner]);

  return { stakingContract };
});
