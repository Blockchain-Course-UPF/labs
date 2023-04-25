pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

contract Auction {
    address payable public seller;
    uint256 public startBlock;
    uint256 public endBlock;
    uint256 public highestBid=0;
    address payable public highestBidder;
    uint256 auctionAmount;

    IERC20 public token;


    bool public ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(
        uint _startBlock,
        uint _endBlock,
        address _tokenAddress,
        uint256 _auctionAmount 
    ) {
        seller = payable(msg.sender);
        startBlock = _startBlock;
        endBlock = _endBlock;
        token = IERC20(_tokenAddress);
        auctionAmount = _auctionAmount;
    }


    function bid(uint amount) public payable {
        require(block.number >= startBlock, "Auction hasn't started yet");
        require(block.number <= endBlock, "Auction has ended");
        require(amount > highestBid, "Bid not high enough");

        if (highestBid != 0) {
            highestBidder.transfer(highestBid);
        }

        highestBid = amount;
        highestBidder = payable(msg.sender);

        emit HighestBidIncreased(highestBidder, highestBid);
    }

    function endAuction() public{
        require(msg.sender == seller, "Only the seller can end the auction");
        require(block.number > endBlock, "Auction has not ended yet");
        require(!ended, "Auction has already ended");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        seller.transfer(highestBid);
        token.transfer(highestBidder, auctionAmount);
    }
}