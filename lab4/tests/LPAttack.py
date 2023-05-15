import pytest
from brownie import Wei, reverts, chain

def test_token_swap(accounts, TokenERC20, constantPriceDEX,basicUniswapV2, Extractor ):
    initial_supply = 100000000

    liquidityProvider1 = accounts[0]
    liquidityProvider2= accounts[1]
    trader1= accounts[2]
    trader2=accounts[3]
    price=10
    precisionPoints=10

    # Deploy the token and transfer some to the token seller
    token = TokenERC20.deploy(initial_supply,"TokenERC20","MYT", {'from': liquidityProvider1})
    token.transfer(liquidityProvider2.address,int(initial_supply/2)*10**18,{"from":liquidityProvider1})

    # deploy the aDEX contracts
    dex1 = constantPriceDEX.deploy(token, price*10**precisionPoints, precisionPoints,{"from":liquidityProvider1})
    dex2 = basicUniswapV2.deploy(token, precisionPoints, {"from":liquidityProvider2})
    
    for i in range(0,10):
        token.approve(dex1.address, initial_supply*10**18, {"from":accounts[i]})
        token.approve(dex2.address, initial_supply*10**18, {"from":accounts[i]})


    # add liquidity
    dex1.deposit({"from":liquidityProvider1, 'value':10*10**18 })
    dex2.deposit(100*10**18,{"from":liquidityProvider2, 'value':10*10**18 })
  

    # trader2 uses DEX 2 to buy tokens
    dex2.buyToken(0,{"from":trader2, 'value':1*10**18 })
