pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "./Ex1.sol";
import "./Ex2.sol";

contract Extractor {
    

    IERC20 public token;

    constantPriceDEX public dex1;
    basicUniswapV2 public dex2;
    bool buyOpportunityDEX1=true;
    uint256 buyAmount=0;
    uint256 sellAmount=0;

    
    
    constructor(IERC20 _tokenAddress, basicUniswapV2 _dex2, constantPriceDEX _dex1 ) {
        token= _tokenAddress;
        dex1=_dex1;
        dex2=_dex2;
    }


    function checkOpportunities() public returns(bool) {
        return false;
    }

    function extract() public {
        require(checkOpportunities(), "no opportunity to extract");
        if (buyOpportunityDEX1){
            dex1.buyToken{ value: buyAmount }();
            dex2.sellToken(sellAmount,0);
        }
        else{

            dex2.buyToken{ value: buyAmount }(0);
            dex1.sellToken(sellAmount);
        }
    }



    
}