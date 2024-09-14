// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/src/Script.sol";
import "../src/FaruqDAO.sol";

contract DeployFaruqDAO is Script {
    function run() external {
        address nftMarketplaceAddress = vm.envAddress("NFT_MARKETPLACE_ADDRESS");
        address daoNftAddress = vm.envAddress("DAO_NFT_ADDRESS");

        vm.startBroadcast();
        new FaruqDAO(nftMarketplaceAddress, daoNftAddress);
        vm.stopBroadcast();
    }
}