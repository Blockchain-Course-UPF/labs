pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

contract constantPriceDEX {
    

    address public owner;
    uint256 public price;
    IERC20 public token;
    
    
    
    event Bought(address buyer, uint256 amount);
    event Sold(address seller,  uint256 amount);


    constructor(IERC20 _tokenAddress, uint256 _price) {
        owner=msg.sender;
        token=_tokenAddress;
        price=_price;
    }



    function deposit() payable public {
        require(token.balanceOf(msg.sender)>=msg.value*price );
        token.transferFrom(msg.sender,address(this),msg.value*price);

    }

    function withdraw(uint256 ethAmount) public {
        require(msg.sender==owner);
        require(ethAmount<=address(this).balance);
        payable(msg.sender).transfer(ethAmount);
        token.transfer(msg.sender,ethAmount*price);

    }

    function buyToken() payable public  {
        require(token.balanceOf(address(this))>=msg.value*price, "Token balance overflow");
        token.transfer(msg.sender,msg.value*price);
        emit Bought(msg.sender, msg.value*price);
    }

    function sellToken(uint256 amount) public {
        require(token.balanceOf(msg.sender)>=amount);
        uint256 tokensToBuy=div(amount,price);
        require(address(this).balance>=tokensToBuy);
        payable(msg.sender).transfer(tokensToBuy);
        emit Sold(msg.sender, amount);

    }

    // as we are dealing with unsigned integers with no decimal places, division needs to be done carefully
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            require(b > 0, "doesn't divide");
            return a / b;
        }
    }
}