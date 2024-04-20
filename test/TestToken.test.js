const { expect } = require("chai");

describe("TestToken", function () {
  let TestToken;
  let owner;
  let otherAccount;

  async function deployTestToken() {
    [owner, otherAccount] = await ethers.getSigners();

    TestToken = await ethers.getContractFactory("TestToken");
    const testToken = await TestToken.deploy(owner.address);

    console.log("TestToken deployed with owner:", owner.address);

    return { testToken, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { testToken, owner } = await deployTestToken();

      console.log("TestToken owner:", await testToken.owner());

      expect(await testToken.owner()).to.equal(owner.address);
    });

    it("Should mint tokens to owner", async function () {
      const { testToken, owner } = await deployTestToken();
      const amountToMint = 1000;

      await testToken.mint(owner.address, amountToMint);

      console.log(amountToMint + " tokens minted to owner:", owner.address);

      const ownerBalance = await testToken.balanceOf(owner.address);
      console.log("Owner balance:", ownerBalance.toString());

      expect(ownerBalance).to.equal(amountToMint);
    });
  });
});
