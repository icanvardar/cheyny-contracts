const { expect } = require("chai");
const { ethers } = require("hardhat");

const TOKEN_URI = "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/1";
const ONLY_ISSUER_REVERTED_MESSAGE = "onlyIssuer: You are not issuer!";

describe("Cheyny", async function () {
  let owner, issuer, nonIssuer, tokenReceiver, addrs;
  let Cheyny;
  let cheyny;

  beforeEach(async () => {
    Cheyny = await hre.ethers.getContractFactory("Cheyny");
    cheyny = await Cheyny.deploy();
    await cheyny.deployed();
    [owner, issuer, nonIssuer, tokenReceiver, ...addrs] =
      await ethers.getSigners();
  });

  it("Should check contract is deployed", async function () {
    expect(await cheyny.name()).to.equal("Cheyny");
    expect(await cheyny.symbol()).to.equal("CHEY");
  });

  it("Should claim & disclaim issuer", async function () {
    const claimIssuerTx = await cheyny
      .connect(owner)
      .claimIssuer(issuer.address);

    await claimIssuerTx.wait();

    expect(await cheyny.issuers(issuer.address)).to.equal(true);

    const disclaimIssuerTx = await cheyny
      .connect(owner)
      .disclaimIssuer(issuer.address);

    await disclaimIssuerTx.wait();

    expect(await cheyny.issuers(issuer.address)).to.equal(false);
  });

  it("Should mint a new NFT", async function () {
    await cheyny.connect(owner).claimIssuer(issuer.address);
    const mintItemTx = await cheyny
      .connect(issuer)
      .mintItem(issuer.address, TOKEN_URI);

    await mintItemTx.wait();

    expect(await cheyny.ownerOf(1)).to.equal(issuer.address);
    expect(await cheyny.tokenURI(1)).to.equal(TOKEN_URI);

    await expect(
      cheyny.connect(nonIssuer).mintItem(nonIssuer.address, TOKEN_URI)
    ).to.be.revertedWith(ONLY_ISSUER_REVERTED_MESSAGE);
  });

  it("Should transfer NFT", async function () {
    await cheyny.connect(owner).claimIssuer(issuer.address);
    const mintItemTx = await cheyny
      .connect(issuer)
      .mintItem(issuer.address, TOKEN_URI);

    await mintItemTx.wait();

    const transferFromTx = await cheyny
      .connect(issuer)
      .transferFrom(issuer.address, tokenReceiver.address, 1);

    await transferFromTx.wait();

    expect(await cheyny.ownerOf(1)).to.equal(tokenReceiver.address);

    // approve sent token to nonIssuer via tokenReceiver
    const approveTx = await cheyny
      .connect(tokenReceiver)
      .approve(nonIssuer.address, 1);

    await approveTx.wait();

    const safeTransferTx = await cheyny
      .connect(nonIssuer)
      ["safeTransferFrom(address,address,uint256)"](
        tokenReceiver.address,
        issuer.address,
        1
      );

    await safeTransferTx.wait();

    expect(await cheyny.ownerOf(1)).to.equal(issuer.address);
  });

  it("Should approve for all", async function () {
    const setApprovalForAllTx = await cheyny
      .connect(issuer)
      .setApprovalForAll(tokenReceiver.address, true);

    await setApprovalForAllTx.wait();

    expect(
      await cheyny.isApprovedForAll(issuer.address, tokenReceiver.address)
    ).to.equal(true);
  });
});
