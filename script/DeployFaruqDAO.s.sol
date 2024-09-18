// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/src/Script.sol";
import "../src/FaruqDAO.sol";

contract DeployFaruqDAO is Script {
    function run() external {
        // Fetch addresses from environment variables
        address nftMarketplaceAddress = vm.envAddress("NFT_MARKETPLACE_ADDRESS");
        address daoNftAddress = vm.envAddress("DAO_NFT_ADDRESS");
        // Start the broadcast for the deployment
        vm.startBroadcast();

        // Deploy the FaruqDAO contract with all required arguments
        FaruqDAO dao = new FaruqDAO(nftMarketplaceAddress, daoNftAddress);

        // Stop the broadcast after deployment
        vm.stopBroadcast();
    }
}
