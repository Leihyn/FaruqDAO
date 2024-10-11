# FaruqDAO NFT Proposal System

This project implements a decentralized proposal system allowing holders of CryptoDevs NFTs to create proposals for purchasing other NFTs from an NFT marketplace. The system enables voting on these proposals, ensuring that every CryptoDevs NFT counts as one vote per proposal, with safeguards against multiple voting.

## Features

1. Proposal Creation: Any holder of a CryptoDevs NFT can create a proposal to purchase a specific NFT from an external marketplace.
2. Voting Mechanism: Every CryptoDevs NFT holder can vote for or against active proposals.
   - Each NFT counts as one vote per proposal.
   - Voters cannot vote multiple times on the same proposal with the same NFT.
3. Automatic Purchase: If a majority of voters approve the proposal by the specified deadline, the NFT purchase is executed automatically from the marketplace.

## Contracts Overview

### Proposal Contract

The main contract that facilitates creating proposals, voting, and executing purchases.

#### Key Functions:
- createProposal(string memory nftAddress, uint256 proposalId): Allows NFT holders to create a purchase proposal for a specific NFT.
- vote(uint256 proposalId, bool inFavor): Enables NFT holders to cast their votes on proposals.
- executeProposal(uint256 proposalId): Automatically executes the NFT purchase if the proposal is approved by the majority before the deadline.

### Voting Mechanism

- Each CryptoDevs NFT grants the holder a single vote on each proposal.
- Votes are tracked to ensure that each NFT can only vote once per proposal.

## Deployment Script

A deploy script is included to facilitate the deployment of the proposal system contract.

### Deploy Script (`DeployFaruqDAO.s.sol`)

This script automates the deployment of the main proposal contract.


### Example Script
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {ProposalSystem} from "../src/ProposalSystem.sol";

contract DeployProposalSystem is Script {
    function run() public {
        vm.broadcast();
        new ProposalSystem();
    }
}
```

## How to Use

1. Deploy the Proposal System: Use the deploy script to deploy the `FaruqDAO` contract.
2. Create Proposals: Holders of CryptoDevs NFTs can create proposals to purchase other NFTs from a marketplace.
3. Vote on Proposals: All NFT holders can vote on the proposals.
4. Automatic Execution: If a proposal receives majority support, the purchase is executed automatically.

## Requirements

- Solidity `^0.8.0`
- OpenZeppelin Contracts (for ERC-721 implementation)
- Ethereum development framework (Hardhat, Foundry, etc.)

## License

This project is licensed under the MIT License.
