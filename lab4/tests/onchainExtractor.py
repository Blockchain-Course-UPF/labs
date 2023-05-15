import pytest
from brownie import Wei, reverts, chain

def test_extractor(accounts, TokenERC20, constantPriceDEX,basicUniswapV2, Extractor ):
    initial_supply = 100000000

    lp1 = accounts[0]
    lp2= accounts[1]
    trader1= accounts[2]
    trader2=accounts[3]
    price=10
    precisionPoints=10

    # Deploy the token and transfer some to the token seller
    token = TokenERC20.deploy(initial_supply,"TokenERC20","MYT", {'from': lp1})
    token.transfer(lp2.address,int(initial_supply/2)*10**18,{"from":lp1})

    # deploy the auction contract
    dex1 = constantPriceDEX.deploy(token, price*10**precisionPoints, precisionPoints,{"from":lp1})
    dex2 = basicUniswapV2.deploy(token, precisionPoints, {"from":lp2})
    
    for i in range(0,10):
        token.approve(dex1.address, initial_supply*10**18, {"from":accounts[i]})
        token.approve(dex2.address, initial_supply*10**18, {"from":accounts[i]})


   
    dex1.deposit({"from":lp1, 'value':10*10**18 })
    dex2.deposit(100*10**18,{"from":lp2, 'value':10*10**18 })
  

    # trader2 uses DEX 2 to buy tokens
    dex2.buyToken(0,{"from":trader2, 'value':5*10**18 })


    # trader1 tries to execute a profitable trade using a contract
    initialBalanceT1=trader1.balance()
    extractor=Extractor.deploy(token,dex2,dex1,precisionPoints,{'from': trader1})

    extractor.deposit({"from":trader1, 'value':100*10**18})

    extractor.extract()

    print("profit ",(trader1.balance()+extractor.balance()-initialBalanceT1)/10**18)





