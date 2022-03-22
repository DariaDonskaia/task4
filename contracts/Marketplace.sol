//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./NFT.sol";

contract Marketplace is AccessControl {
    uint256 private TREEDAYS = 259200;

    //TODO: add roles in function
    bytes32 public constant BUYER_ROLE = keccak256("BUYER_ROLE");
    bytes32 public constant SELLER_ROLE = keccak256("SELLER_ROLE");
    bytes32 public constant BIDDERS_ROLE = keccak256("BIDDERS_ROLE");
    address payable MarketPlaceAdress;
    
    using SafeERC20 for IERC20;

    ERC20 erc20 = new ERC20("TestToken", "TT");
    NFT myNFT = new NFT();
    mapping(uint256 => Order) private idItemToOrders;
    mapping(uint256 => Auction) private idItemToAuctions;
  
    struct Order {
        address seller;
        uint256 price;
        bool status;
    }

    struct Auction {
        uint256 startTime;
        uint256 bidderCount;
        address lastBidder;
        uint256 price;
        address seller;
        bool status;
    }
    
    constructor() {
        MarketPlaceAdress = payable(msg.sender);
    }

    function createItem( address MarketPlaceAdress, string calldata tokenURI) public
    {
       require(MarketPlaceAdress != address(0), "Address don't be equal null");
       myNFT.mintTo(MarketPlaceAdress, tokenURI);
    }

    function listItem(uint256 tokenId, uint256 price) public {
        //_setupRole(SELLER_ROLE, msg.sender); //add role
        require(price > 0, "Price don't be equal 0");
        require(idItemToOrders[tokenId].status == false, "This token don't take part in order");
        idItemToOrders[tokenId] = Order(msg.sender, price, true);
    }

    function cancel(uint256 tokenId) public {
        require(idItemToOrders[tokenId].seller == msg.sender, "The token does not belong to you");
        myNFT.transferFrom(MarketPlaceAdress, msg.sender, tokenId);
        idItemToOrders[tokenId].status = false;
    }

    function buyItem(uint256 tokenId) public {
        require(idItemToOrders[tokenId].status, "Order no longer valid");
        IERC20(erc20).safeTransferFrom(msg.sender, idItemToOrders[tokenId].seller, idItemToOrders[tokenId].price);
        myNFT.transferFrom(MarketPlaceAdress, msg.sender, tokenId);
        idItemToOrders[tokenId].status = false;
    }

    function listItemOnAuction(uint256 tokenId, uint256 startPrice) public {
        myNFT.transferFrom(msg.sender, MarketPlaceAdress, tokenId);
        idItemToAuctions[tokenId] = Auction( block.timestamp, 0, address(0), startPrice, msg.sender, true);
    }

    function makeBid(uint256 tokenId, uint256 newPrice) public {
        require(idItemToAuctions[tokenId].startTime + TREEDAYS > block.timestamp, "Auction time has passed"); 
        require(idItemToAuctions[tokenId].price < newPrice, "Your new price is less than the current deal");
        if (idItemToAuctions[tokenId].bidderCount > 0) {
            IERC20(erc20).safeTransfer(idItemToAuctions[tokenId].lastBidder, idItemToAuctions[tokenId].price);
        }
        myNFT.safeTransferFrom(msg.sender, MarketPlaceAdress, newPrice);
        idItemToAuctions[tokenId].bidderCount += 1;
        idItemToAuctions[tokenId].lastBidder = msg.sender;
        idItemToAuctions[tokenId].price = newPrice;
    }

    function cancelAuction(uint256 tokenId) public {
        IERC20(erc20).safeTransfer(idItemToAuctions[tokenId].seller, idItemToAuctions[tokenId].price);
        myNFT.transferFrom(MarketPlaceAdress, idItemToAuctions[tokenId].seller, tokenId);
        idItemToAuctions[tokenId].status = false;
    }

    function finishAuction(uint256 tokenId) public {
        require(idItemToAuctions[tokenId].startTime + TREEDAYS < block.timestamp, "Time is over. end of the auction");
        if (idItemToAuctions[tokenId].bidderCount > 0) {
            IERC20(erc20).safeTransfer(idItemToAuctions[tokenId].seller, idItemToAuctions[tokenId].price);
            myNFT.transferFrom(MarketPlaceAdress, idItemToAuctions[tokenId].lastBidder, tokenId);
        } 
        else{
            cancelAuction(tokenId);
        }     
    }


}