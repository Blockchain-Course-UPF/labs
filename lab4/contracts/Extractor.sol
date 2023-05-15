pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "./Exchange1.sol";
import "./Exchange2.sol";

contract Extractor {
    

    IERC20 public token;
    address public owner;

    constantPriceDEX public dexConstantPrice;
    basicUniswapV2 public dexUniV2;
    bool buyOpportunityDEXConstantPrice=true;
    uint256 tokenAmount=0;
    uint256 ethAmount=0;
    uint256 public precisionPoints;
    
    
    constructor(IERC20 _tokenAddress, basicUniswapV2 _dex2, constantPriceDEX _dex1, uint256 pps ) {
        token= _tokenAddress;
        dexConstantPrice=_dex1;
        dexUniV2=_dex2;
        precisionPoints=pps;
        owner=msg.sender;
        token.approve(address(dexUniV2), 1000000000*10**18);
        token.approve(address(dexConstantPrice), 1000000000*10**18);
    }



    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function deposit() public payable{}

    function withdraw(uint256 amount ) public {
        require(msg.sender==owner, "not owner");
        require(address(this).balance>=amount, "insufficient balance");
        payable(owner).transfer(amount);
    }


    function checkOpportunities() public returns(bool) {
        uint256 ethValueUniV2= div(dexConstantPrice.price()*address(dexUniV2).balance,10**precisionPoints);
        if (ethValueUniV2 == token.balanceOf(address(dexUniV2))){
            return false;
        }
        if (ethValueUniV2> token.balanceOf(address(dexUniV2))){
            tokenAmount=sqrt(div(dexConstantPrice.price()*dexUniV2.poolConstant(),(10**precisionPoints)**2))-token.balanceOf(address(dexUniV2));
            ethAmount=div(tokenAmount*10**precisionPoints,dexConstantPrice.price());
            buyOpportunityDEXConstantPrice==true;

        }
        else{
            tokenAmount=token.balanceOf(address(dexUniV2))-sqrt(div(dexConstantPrice.price()*dexUniV2.poolConstant(),(10**precisionPoints)**2));    
            ethAmount=sqrt(div(dexUniV2.poolConstant(),dexUniV2.price()))-address(dexUniV2).balance;
            buyOpportunityDEXConstantPrice==false;
        }
        return true;
    }

    function extract() payable public  {
        require(checkOpportunities(), "no opportunity to extract");
        if (buyOpportunityDEXConstantPrice){
            dexConstantPrice.buyToken{ value: ethAmount }();
            dexUniV2.sellToken(token.balanceOf(address(this)),0);
        }
        else{
            dexUniV2.buyToken{ value: ethAmount }(0);
            dexConstantPrice.sellToken(token.balanceOf(address(this)));
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            require(b > 0, "doesn't divide");
            return a / b;
        }
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }    
}
