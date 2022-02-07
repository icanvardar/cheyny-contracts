// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Cheyny is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => bool) public issuers;

    event MintItem(uint256 tokenId, address issuer, string tokenURI);
    event ClaimIssuer(address newIssuer);
    event DisclaimIssuer(address issuer);

    constructor() ERC721("Cheyny", "CHEY") {
        issuers[msg.sender] = true;
    }

    modifier onlyIssuer() {
        require(issuers[msg.sender] == true, "onlyIssuer: You are not issuer!");
        _;
    }

    function claimIssuer(address newIssuer) public onlyOwner {
        issuers[newIssuer] = true;
        emit ClaimIssuer(newIssuer);
    }

    function disclaimIssuer(address issuer) public onlyOwner {
        issuers[issuer] = false;
        emit DisclaimIssuer(issuer);
    }

    function mintItem(address issuer, string memory tokenURI)
        public
        onlyIssuer
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(issuer, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit MintItem(newItemId, issuer, tokenURI);
        return newItemId;
    }
}
