// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Error declarations
error NotADaoMemeber();
error NftNotAvailable();
error DeadlineExceeded();
error NoNFTs();
error DeadlineNotExceeded(uint256 currentTime, uint256 deadline);
error ProposalAlreadyExecuted();
error NotEnoughFunds(uint256 available, uint256 required);
error FailedToWithdrawEther();
error AccountIsEmpty();
error AlreadyVoted();

/**
 * Interface for the fakeNFTMarket
 */
interface IFakeNFTMarket {
    // GETTING THE PRICE OF NFT and RETURNS IN WEI
    function getPrice() external view returns (uint256);

    // CHECKING IF THE GIVEN NFTTOKENID IS AVAILABLE and BOOL
    function available(uint256 _tokenId) external view returns (bool);

    // PURCHASE NFT FROM THE MARKET
    function purchase(uint256 _tokenId) external payable;
}

interface IDaoNFT {
    // get balance/number of NFTs by the address
    function balanceOf(address owner) external view returns (uint256);

    // get the tokenID at given index for owner
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract FaruqDAO is Ownable, ReentrancyGuard {
    IFakeNFTMarket nftMarketplace;
    IDaoNFT daoNFT;

    // Constructor for initializing the contract
    constructor(address _nftMarketplace, address _daoNft) payable Ownable(msg.sender){
        nftMarketplace = IFakeNFTMarket(_nftMarketplace);
        daoNFT = IDaoNFT(_daoNft);
    }

    // Struct Proposal for all the relevant info
    struct Proposal {
        uint256 nftTokenId;
        uint256 deadline;
        uint256 yesVotes;
        uint256 nahVotes;
        bool executed;
        mapping(uint256 => bool) voters;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals;

    // Modifier that allows only owners of >= 1 DaoNFTs
    modifier nftHolderOnly() {
        if (daoNFT.balanceOf(msg.sender) == 0) {
            revert NotADaoMemeber();
        }
        _;
    }

    // createProposal allows a DaoNFT holder to create a new proposal in the DAO
    function createProposal(uint256 _nftTokenId) external nftHolderOnly returns (uint256) {
        if (!nftMarketplace.available(_nftTokenId)) {
            revert NftNotAvailable();
        }

        uint256 currentProposalId = numProposals;
        // Initialize the Proposal struct and set its fields
        Proposal storage newProposal = proposals[currentProposalId];
        newProposal.nftTokenId = _nftTokenId;
        newProposal.deadline = block.timestamp + 5 minutes;
        newProposal.yesVotes = 0;
        newProposal.nahVotes = 0;
        newProposal.executed = false;

        numProposals++;
        return currentProposalId;
    }

    // Modifier to check if the proposal deadline has not exceeded
    modifier activeProposalOnly(uint256 proposalIndex) {
        if (proposals[proposalIndex].deadline <= block.timestamp) {
            revert DeadlineExceeded();
        }
        _;
    }

    // Enum for possible options for a vote
    enum Vote {
        YAY,
        NAY
    }

    // voteOnProposal allows DaoNFT holder to cast their vote on active proposal
    function voteOnProposal(uint256 proposalIndex, Vote vote)
        external
        nftHolderOnly
        activeProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = daoNFT.balanceOf(msg.sender);
        if (voterNFTBalance == 0) {
            revert NoNFTs();
        }

        uint256 numVotes = 0;
        address voter = msg.sender;

        for (uint256 i = 0; i < voterNFTBalance; i++) {
            uint256 tokenId = daoNFT.tokenOfOwnerByIndex(voter, i);

            if (!proposal.voters[tokenId]) {
                numVotes++;
                proposal.voters[tokenId] = true;
            }
        }

        if (numVotes == 0) {
            revert AlreadyVoted();
        }

        if (vote == Vote.YAY) {
            proposal.yesVotes += numVotes;
        } else {
            proposal.nahVotes += numVotes;
        }
    }

    // Modifier to check if proposal deadline has been exceeded and if the proposal has not yet been executed
    modifier inactiveProposalOnly(uint256 proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];

        if (proposal.deadline > block.timestamp) {
            revert DeadlineNotExceeded(block.timestamp, proposal.deadline);
        }

        if (proposal.executed) {
            revert ProposalAlreadyExecuted();
        }
        _;
    }

    // Function to execute proposal
    function executeProposal(uint256 proposalIndex)
        external
        nftHolderOnly
        nonReentrant
        inactiveProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        if (proposal.executed) {
            revert ProposalAlreadyExecuted();
        }

        if (proposal.yesVotes <= proposal.nahVotes) {
            proposal.executed = true;
            return;
        }

        uint256 nftPrice = nftMarketplace.getPrice();

        if (address(this).balance < nftPrice) {
            revert NotEnoughFunds(address(this).balance, nftPrice);
        }

        nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
        proposal.executed = true;
    }

    // withdrawEther allows the contract owner to withdraw ETH from the contract
    function withdrawEther() external onlyOwner nonReentrant {
        uint256 amount = address(this).balance;
        if (amount == 0) {
            revert AccountIsEmpty();
        }

        (bool sent, ) = payable(owner()).call{value: amount}("");
        if (!sent) {
            revert FailedToWithdrawEther();
        }
    }

    receive() external payable {}
    fallback() external payable {}
}
