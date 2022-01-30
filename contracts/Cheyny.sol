// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Cheyny is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => bool) public issuers;

    constructor() ERC721("Cheyny", "CHEY") {
        issuers[msg.sender] = true;
    }

    modifier onlyIssuer() {
        require(issuers[msg.sender] == true, "onlyIssuer: You are not issuer!");
        _;
    }

    function claimIssuer(address newIssuer) public onlyOwner {
        issuers[newIssuer] = true;
    }

    function disclaimIssuer(address issuer) public onlyOwner {
        issuers[issuer] = false;
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

        return newItemId;
    }
}
