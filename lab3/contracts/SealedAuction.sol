pragma solidity ^0.8.0;
import "../interfaces/IERC20.sol";
contract SealedBidAuction {
    
    uint256 public highestBid=0;
    address public seller;
    address payable public highestBidder;
    uint256 public auctionAmount;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;
    uint256 public constant collateral =100 ether;


    IERC20 public token;
    mapping(address => bytes32) public bids;
    event AuctionEnded(address winner, uint256 highestBid);
    
    constructor(
        uint256 _biddingEnd, 
        uint256 _revealEnd,
        address _tokenAddress,
        uint256 _auctionAmount
     ) {
        seller = payable(msg.sender);
        biddingEnd = _biddingEnd;
        revealEnd = _revealEnd;
        token = IERC20(_tokenAddress);
        auctionAmount = _auctionAmount;
    }
    function placeBid(bytes32 _hashedBid) public payable {
        require(block.number <= biddingEnd, "Auction has ended");
        require(msg.value >= collateral, "Bid must have correct collateral");
        require(bids[msg.sender] == 0, "Bidder already has a collateral deposit");
        bids[msg.sender] = _hashedBid;
    }

    //this is the function which verifies if 
    function checkHash(uint256 _value,uint256 _randomness, address _sender) private returns (bool) {
        require(bids[_sender]== keccak256(abi.encodePacked(_value, _randomness)), "Hash value does not match a valid bid");
        return true;
    }

    function revealBid(uint256 _value, uint256 _randomness) public{
        require(checkHash(_value,_randomness, msg.sender)==true);
        require(block.number > biddingEnd, "Auction has not ended");
        require(block.number <= revealEnd, "Reveal phase has ended");
        
        require(_value <= collateral, "Bid is too big");
    
        if (_value > highestBid) {
            payable(msg.sender).send(collateral - _value);
            highestBidder.send(highestBid);
            highestBid = _value;
            highestBidder=payable(msg.sender);
        } else {
            payable(msg.sender).send(collateral);
        }
        // For the final exercise, the following should have been commented out
        // bids[msg.sender]=0;
        
    }
    function auctionEnd() public {
        require(msg.sender == seller, "Only the seller can end the auction");
        require(block.number > revealEnd, "Reveal phase has not ended");
        require(!ended, "Auction has already ended");
        ended = true;
        
        emit AuctionEnded(highestBidder, highestBid);
        payable(seller).transfer(highestBid);
        token.transfer(highestBidder, auctionAmount);
    }
}
