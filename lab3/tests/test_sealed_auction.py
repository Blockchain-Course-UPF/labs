import pytest
from brownie import Wei, reverts, chain, web3

def test_SealedBidAuction(accounts, TokenERC20, SealedBidAuction):

    seller = accounts[0]
    bidder1 = accounts[1]
    bidder2 = accounts[2]
    collateral= 100*10**18

    # the number of tokens to be sold by the seller in the auction
    auction_tokens = 10**18

    bid1 = 3*10**18
    bid2 = 5*10**18
    rand1=1234
    rand2=5678

    # these will be the hashes that we commit to in our solidity auction.
    # we need to add randomness, as otherwise players might be able to guess our bids from the hash
    hashed_bid1 = web3.solidityKeccak(["uint256", "uint256"], [bid1,rand1])
    hashed_bid2 = web3.solidityKeccak(["uint256", "uint256"], [bid2,rand2])

    # Deploy the token and transfer some to the token seller
    token = TokenERC20.deploy(1000000,"TokenERC20","MYT", {'from': seller})


    start_block = chain.height + 1
    biddingEnd= start_block+ 100
    revealEnd= biddingEnd+ 100


    auction = SealedBidAuction.deploy(biddingEnd, revealEnd, token.address, auction_tokens, {"from": seller})
    
    #This is cheating...
    token.transfer(auction.address,auction_tokens,{"from":seller})

    # try to send a bid with less collateral than required
    try:
        auction.placeBid(hashed_bid1,{"from":bidder1, 'value':19*10**18})
    except Exception as e:
        # This exception is expected, as deposit must be at least 100 ether
        assert "Bid must have correct collateral" in str(e)

    # place bids in auction    
    auction.placeBid(hashed_bid1,{"from":bidder1, 'value':collateral})
    auction.placeBid(hashed_bid2,{"from":bidder2, 'value':collateral})
    
    # mine to the end of the commit phase
    chain.mine(auction.biddingEnd() + 1)
    try:
        auction.revealBid(bid2+1, rand1, {"from":bidder1})
    except Exception as e:
        # This exception is expected, as the hash inputs are incorrect (Bidder1 trying to cheat)
        assert "Hash value does not match a valid bid" in str(e)

    # reveal bids
    auction.revealBid(bid1,rand1,{"from":bidder1})
    auction.revealBid(bid2,rand2,{"from":bidder2})

    # mine to the end of the reveal phase
    chain.mine(auction.revealEnd() + 1)

    #verify the balances of the seller and winning bidder have updated correctly
    prev_BalanceSeller=seller.balance()
    prev_tokenBalanceWinner=token.balanceOf(bidder2)
    auction.auctionEnd({"from":seller})
    assert prev_BalanceSeller+bid2==seller.balance()
    assert prev_tokenBalanceWinner+auction_tokens==token.balanceOf(bidder2)