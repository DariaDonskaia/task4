const { expect } = require("chai");
const { ethers, waffle} = require("hardhat");
const provider = waffle.provider;

describe("Marketplace", function () {
  USER_BALANCE_ERC20 = 10;
  const URIS = ['uri1','uri2','uri3','uri4','uri5'];
  const abi = [
    "function balanceOf(address owner) view returns (uint256)",
    "function decimals() view returns (uint8)",
    "function symbol() view returns (string)",
    "function mint(address account, uint256 amount) returns (bool)",
    "function transfer(address to, uint amount) returns (bool)",
    "event Transfer(address indexed from, address indexed to, uint amount)"
];
  const address = "0x83655aA60eF02228E09a7d9A421b250a59677FA2";
  const erc20 = new ethers.Contract(address, abi, provider);
  
  let mynft;
  let marketplace;
  beforeEach(async () => {
    [owner, user1, user2, user3, user4] = await ethers.getSigners();

    const MyNFT = await ethers.getContractFactory("NFT");
    const MarketPlace = await ethers.getContractFactory("Marketplace");

    mynft = MyNFT.connect(owner).deploy();
    marketplace = await MarketPlace.connect(owner).deploy();

    await erc20.connect(owner).mint(user1.address, USER_BALANCE_ERC20);
    await marketplace.connect(owner).createItem(owner.address, URIS[0]);

  });
  
  describe("Test base function marketplace function", function () {

  it("createItem", async function () {
    await marketplace.connect(owner).createItem(owner.address, URIS[0]);
  });

  it("listItem", async function () {
    await marketplace.connect(owner).listItem(1, 1);
  });

  it("buyItem", async function () {
    await marketplace.connect(owner).listItem(1, 1);
    await erc20.connect(owner).approve(owner.address, 1)
    await marketplace.connect(owner).buyItem(1);
  });

  it("cancel", async function () {

    await marketplace.connect(owner).cancel(URIS[0]);
  });

  it("listItemOnAuction", async function () {
    await marketplace.connect(owner).listItemOnAuction(URIS[0], 10);
  });

  it("makeBid", async function () {
    await marketplace.connect(owner).cancel(URIS[0], 10);
  });

  it("finishAuction", async function () {
    await marketplace.connect(owner).finishAuction(URIS[0]);
  });

  it("cancelAuction", async function () {
    await marketplace.connect(owner).cancelAuction(URIS[0]);
  });


});

});  
