import pytest
from brownie import accounts, MyToken, network

# Constants
INITIAL_SUPPLY = 1_000_000 
TRANSFER_AMOUNT = 1_000 * 10 ** 18

# Fixture to deploy the MyToken contract
# @pytest.fixture
# def mytoken():
#     return MyToken.deploy(INITIAL_SUPPLY, {"from": accounts[0]})

# def test_token_transfer_to_addresses(mytoken):


def helicopter(recipient_addresses,amount,my_token):
     # Perform token transfers
    for address in recipient_addresses:
        tx = my_token.transfer(address, TRANSFER_AMOUNT, {"from": accounts[0]})

def test_token_transfer_to_addresses():
# List of addresses to receive tokens

    recipient_addresses = [accounts[1], accounts[2], accounts[3]]
    mytoken = MyToken.deploy(INITIAL_SUPPLY, {"from": accounts[0]})
    # Initial balances
    initial_balances = [mytoken.balanceOf(address) for address in recipient_addresses]

    # Perform token transfers
    helicopter(recipient_addresses,TRANSFER_AMOUNT,mytoken)

    # Check new balances
    for i, address in enumerate(recipient_addresses):
        assert mytoken.balanceOf(address) == initial_balances[i] + TRANSFER_AMOUNT

    print(mytoken.balanceOf(accounts[0]), INITIAL_SUPPLY - 3 * TRANSFER_AMOUNT)
