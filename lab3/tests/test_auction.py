import pytest
from brownie import Wei, reverts, chain

def test_token_swap(accounts, TokenERC20, Auction):
    initial_supply = 100000000

    seller = accounts[0]
    bidder1 = accounts[1]
    bidder2 = accounts[2]

    auction_tokens = 10**18

    bid1 = 3*10**18
    bid2 = 2*10**18
    bid3 = 5*10**18

    # Deploy the token and transfer some to the token seller
    token = TokenERC20.deploy(initial_supply,"TokenERC20","MYT", {'from': seller})

    print(token.balanceOf(seller)> auction_tokens)

    start_block = chain.height + 1
    end_block = start_block + 100
    auction = Auction.deploy(start_block, end_block, token.address, auction_tokens, {"from": seller})
    
    auction.bid(bid1, {"from": bidder1, 'value': bid1})
    token.transfer(auction.address,auction_tokens,{"from":seller})
    
    assert auction.highestBidder() == bidder1
    assert auction.highestBid() == bid1
    assert auction.balance() == bid1

    try:
        auction.bid(bid2, {"from": bidder2, 'value': bid2})
        print("FAIL")
    except Exception as e:
        # This exception is expected, as the highest bid is 3
        assert "Bid not high enough" in str(e)
    
    
    auction.bid(bid3, {"from": bidder2, 'value': bid3})



    try:
        auction.endAuction({"from": seller})
        print("FAIL")
    except Exception as e:
        # This exception is expected, as the auction has not ended yet
        assert "Auction has not ended yet" in str(e)
    
    # mine to the end of the auction
    chain.mine(auction.endBlock() + 1)

    previousSellerBalance=seller.balance()
    auction.endAuction({"from": seller})
    assert previousSellerBalance + auction.highestBid()==seller.balance()
    assert token.balanceOf(bidder2)==auction_tokens

    
    