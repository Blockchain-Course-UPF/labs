pragma solidity ^0.8.0;
import "../interfaces/IERC20.sol";
contract SealedBidAuction {
    
    uint256 public highestBid=0;
    address public seller;
    address payable public highestBidder;
    uint256 public auctionAmount;

    // times when the respective phases should end
    uint256 public biddingEnd;
    uint256 public revealEnd;

    bool public ended;
    uint256 public constant collateral =100 ether;


    IERC20 public token;

    // this mapping trackes the 
    mapping(address => bytes32) public bid_Hashes;


    event AuctionEnded(address winner, uint256 highestBid);
    
    constructor(
        uint256 _biddingEnd, 
        uint256 _revealEnd,
        address _tokenAddress,
        uint256 _auctionAmount
     ) {

    }

    //add the hash of a bid to the bid_Hashes mapping, and deposit the required collateral
    function commitBid(bytes32 _hashedBid) public payable {
        
    }

    //this is the function which verifies if 
    function checkHash(uint256 _value,uint256 _randomness, address _sender) private returns (bool) {
        require(bid_Hashes[_sender]== keccak256(abi.encodePacked(_value, _randomness)), "Hash value does not match a valid bid");
        return true;
    }

    // reveal the bid, and verify the bid matches a committed hash. HINT: Use the checkHash function
    function revealBid(uint256 _value, uint256 _randomness) public{
        
    }

    // this should send any tokens and/or ether back to the required players
    function auctionEnd() public {
        
    }
}