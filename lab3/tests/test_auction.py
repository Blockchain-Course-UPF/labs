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

    # set the start and end times for the auction
    start_block = chain.height + 1
    end_block = start_block + 100

    # deploy the auction contract
    auction = Auction.deploy(start_block, end_block, token.address, auction_tokens, {"from": seller})
    
    #This is cheating...
    token.transfer(auction.address,auction_tokens,{"from":seller})

    # submit a bid in the auction
    auction.bid(bid1, {"from": bidder1, 'value': bid1})

   
    
    # ensure bidder1 is the highest bid, the highest bid has been stored properly, and deposited to the auction contract
    assert auction.highestBidder() == bidder1
    assert auction.highestBid() == bid1
    assert auction.balance() == bid1

    # try to place a bid less than the current highest bid, but reject it
    try:
        auction.bid(bid2, {"from": bidder2, 'value': bid2})
        print("FAIL")
    except Exception as e:
        # This exception is expected, as the highest bid should be 3
        assert "Bid not high enough" in str(e)
    
    # successfully place a bid higher than current bid, and return funds to previous highest bidder
    # record balance of highest bidder before new highest bid
    prev_Balance=bidder1.balance()
    auction.bid(bid3, {"from": bidder2, 'value': bid3})
    # ensure the funds are returned when a new highest bidder exists.
    assert bidder1.balance()==prev_Balance+bid1

    #try to end auction early
    try:
        auction.endAuction({"from": seller})
        print("FAIL")
    except Exception as e:
        # This exception is expected, as the auction has not ended yet
        assert "Auction has not ended yet" in str(e)
    
    # mine to the end of the auction
    chain.mine(auction.endBlock() + 1)

    # verify the seller received the ether, and the winning bidder received the ERC20 tokens.
    previousSellerBalance=seller.balance()
    auction.endAuction({"from": seller})
    assert previousSellerBalance + auction.highestBid()==seller.balance()
    assert token.balanceOf(bidder2)==auction_tokens

    
    