pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

contract basicUniswapV2 {
    

    address public owner;
    uint256 public poolConstant;
    IERC20 public token;
    uint256 public price;
    
    
    
    event Bought(address buyer, uint256 amount);
    event Sold(address seller,  uint256 amount);


    constructor(IERC20 _tokenAddress) {
        owner=msg.sender;
        token=_tokenAddress;
    }



    function deposit(uint256 tokenAmount) payable public {
        require(token.balanceOf(msg.sender)>=msg.value*price );
        if(token.balanceOf(address(this))==0){
            token.transferFrom(msg.sender,address(this),tokenAmount);
        }
        else{
            token.transferFrom(msg.sender,address(this),msg.value*price);
        }
        poolConstant=address(this).balance*token.balanceOf(address(this));
        price=div(token.balanceOf(address(this)),address(this).balance);
    }

    function withdraw(uint256 ethAmount) public {
        require(msg.sender==owner);
        require(ethAmount<=address(this).balance);
        payable(msg.sender).transfer(ethAmount);
        token.transfer(msg.sender,ethAmount*price);
        poolConstant=address(this).balance*token.balanceOf(address(this));

    }

    function buyToken(uint256 minimumTokensToBuy) payable public  {
        require(token.balanceOf(address(this))>=minimumTokensToBuy, "Token balance overflow");
        require((token.balanceOf(address(this))-minimumTokensToBuy)*address(this).balance>=poolConstant, "price unacceptable");
        uint256 DEXtokensAfterBuy=div(poolConstant,address(this).balance);
        uint256 tokensBought=token.balanceOf(address(this))-DEXtokensAfterBuy;
        token.transfer(msg.sender,tokensBought);
        price=div(token.balanceOf(address(this)),address(this).balance);
        emit Bought(msg.sender, tokensBought);
    }

    function sellToken(uint256 tokensSold, uint256 minimumEthToReceive) public {
        require(address(this).balance>=minimumEthToReceive, "ETH balance overflow");
        require((token.balanceOf(address(this))+tokensSold)*(address(this).balance-minimumEthToReceive)>=poolConstant, "price unacceptable");
        uint256 DEXethAfterSell=div(poolConstant,tokensSold+token.balanceOf(address(this)));
        uint256 ethBought=address(this).balance-DEXethAfterSell;
        token.transferFrom(msg.sender,address(this),tokensSold);

        payable(msg.sender).transfer(ethBought);
        price=div(token.balanceOf(address(this)),address(this).balance);
        emit Sold(msg.sender, tokensSold);

    }

    // as we are dealing with unsigned integers with no decimal places, division needs to be done carefully
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            require(b > 0, "doesn't divide");
            return a / b;
        }
    }
}