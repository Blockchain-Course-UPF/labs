pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

contract AuctionEx1 {
    address payable public seller;
    uint256 public startBlock;
    uint256 public endBlock;
    uint256 public highestBid;
    address payable public highestBidder;
    uint256 public auctionAmount;

    IERC20 public token;


    bool public ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(
        uint _startBlock,
        uint _endBlock,
        address _tokenAddress,
        uint256 _auctionAmountToSell 
    ) {
        
    }


    function bid(uint amount) public payable {
        

        emit HighestBidIncreased(highestBidder, highestBid);
    }

    function endAuction() public {

        emit AuctionEnded(highestBidder, highestBid);

    }
}