// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract DaoNFT is ERC721Enumerable  {
    //initialize the erc721 contract
    constructor() ERC721("Dao", "CD") {}

    //public mint function anyone can call to get the nft
    function mint() public {
        _safeMint(msg.sender, totalSupply());
    }
}