import pytest
from brownie import Wei, reverts, chain

def test_token_swap(accounts, TokenERC20, constantPriceDEX,basicUniswapV2 ):
    initial_supply = 100000000

    lp1 = accounts[0]
    lp2= accounts[1]
    trader1= accounts[2]
    trader2=accounts[3]
    price=10

    # Deploy the token and transfer some to the token seller
    token = TokenERC20.deploy(initial_supply,"TokenERC20","MYT", {'from': lp1})
    token.transfer(lp2.address,int(initial_supply/2)*10**18,{"from":lp1})

    # deploy the auction contract
    dex1 = constantPriceDEX.deploy(token, price, {"from":lp1})
    dex2 = basicUniswapV2.deploy(token, {"from":lp2})
    
    for i in range(0,10):
        token.approve(dex1.address, initial_supply*10**18, {"from":accounts[i]})
        token.approve(dex2.address, initial_supply*10**18, {"from":accounts[i]})


   
    dex1.deposit({"from":lp1, 'value':10*10**18 })
    print(dex1.balance(), token.balanceOf(dex1), token.balanceOf(dex1)/dex1.balance())
    dex2.deposit(100*10**18,{"from":lp2, 'value':10*10**18 })
    print(dex2.balance(), token.balanceOf(dex2), token.balanceOf(dex2)/dex2.balance())
    

    # trader2 uses DEX 2 to buy tokens
    dex2.buyToken(0,{"from":trader2, 'value':1*10**18 })
    print(dex2.balance(), token.balanceOf(dex2), token.balanceOf(dex2)/dex2.balance())
    print(dex2.price())

    # trader1 tries to execute a profitable trade
    initialBalanceT1=trader1.balance()
    
    dex1.buyToken({"from":trader1, 'value':1*10**18 })
    print(trader1.balance()-initialBalanceT1)
    dex2.sellToken(token.balanceOf(trader1),0,{"from":trader1 })

    profit=trader1.balance()-initialBalanceT1

    print(profit)

    print(dex2.price())