// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable {
  using Counters for Counters.Counter;

  Counters.Counter private currentTokenId;
  string public baseTokenURI;
  uint256 private _tokenId;
  address private _owner;
  address private _marketplace;

  constructor() ERC721("Contract For Marketplace", "CFM") {
    _owner = msg.sender;
  }

  function setTokenId(uint256 tokenId) public{
    _tokenId = tokenId;
  }

  function getTokenId() public view returns (uint256) {
    return _tokenId;
  }

  function mintTo(address recipient, string memory _baseTokenURI) public onlyOwner {
    require(recipient != address(0), "Recipient don't be equal zero address");
    uint256 tokenId = currentTokenId.current();
    setBaseTokenURI(_baseTokenURI);
    currentTokenId.increment();
    uint256 newItemId = currentTokenId.current();
    _safeMint(recipient, newItemId);
    setTokenId(newItemId);
  }

  function _ownerOf(uint256 tokenId) public view returns (address) {
    return ownerOf(tokenId);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseTokenURI;
  }

  function setBaseTokenURI(string memory _baseTokenURI) public {
    baseTokenURI = _baseTokenURI;
  }
}
