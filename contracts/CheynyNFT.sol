// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CheynyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => bool) public issuers;

    constructor() ERC721("CheynyNFT", "CHEY") {
        issuers[msg.sender] = true;
    }
    
    event ClaimIssuer(address newIssuer);
    event DisclaimIssuer(address newIssuer);

    modifier onlyIssuer() {
        bool isIssuerVal = isIssuer(msg.sender);
        require(isIssuerVal == true, "You have to be issuer.");
        _;
    }

    function isIssuer(address issuer) public view returns (bool) {
        if (!issuers[issuer] == false) return false;
        return true;
    }

    function claimIssuer(address newIssuer) public onlyOwner {
        issuers[newIssuer] = true;
        emit ClaimIssuer(newIssuer);
    }

    function disclaimIssuer(address newIssuer) public onlyOwner {
        issuers[newIssuer] = false;
        emit DisclaimIssuer(newIssuer);
    }

    function awardItem(address player, string memory tokenURI)
        public
        onlyIssuer
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
