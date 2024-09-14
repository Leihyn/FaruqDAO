// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

error NotEnough__Funds();

contract FakeNFTMarketplace {
    //maintain  a mapping of fake ID to owner address    
    mapping(uint256 => address) public tokens;

    //set the purtchase price of each fake NFT
    uint256 nftPrice = 0.1 ether;

    // purchasing accepts eth and makes buyer/caller address the owner of the fake NFT wuth tokenID
    //_tokenID = the fake NFT tokenID
    function purchase(uint256 _tokenID) external payable {
        if(msg.value < nftPrice) {
            revert NotEnough__Funds();
        } 
        tokens[_tokenID] = msg.sender;
    }

    //returns the price of one NFT
    function getPrice() external view returns (uint256) {
        return nftPrice;
    }

    //checks if the given NFT(tokenID) is available
    function available(uint256 _tokenID) external view returns (bool) {
        if (tokens[_tokenID] ==address(0)) {
            return true;
        }
        return false;
    }
}