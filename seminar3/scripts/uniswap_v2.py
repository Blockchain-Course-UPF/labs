from brownie import accounts, network, Contract
from pathlib import Path
import json


 
# Connect to Ethereum network
network.connect('mainnet')

# Uniswap V2 Factory contract address
uniswap_v2_factory_address = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"

# Token addresses for the pair
token1_address = "0x6B175474E89094C44Da98b954EedeAC495271d0F"  # DAI
token2_address = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"  # WETH

# Load the Uniswap V2 Factory contract
with open(Path("uniswap_factory.json")) as f:
    factory_json = json.load(f)
UniswapV2Factory = Contract.from_abi("UniswapV2Factory", uniswap_v2_factory_address, abi=factory_json)

# Get the pool address
pool_address = UniswapV2Factory.getPair(token1_address, token2_address)
print(f"Pool address: {pool_address}")

# Load the Uniswap V2 Pool contract
with open(Path("UniswapV2Pair.json")) as f:
    pair_json = json.load(f)
UniswapV2Pair = Contract.from_abi("UniswapV2Pair", pool_address, abi=pair_json)

# Get reserves of the token pair
reserves = UniswapV2Pair.getReserves()
reserve1, reserve2, _ = reserves

# Compute the price
price = reserve2 / reserve1
price2 = reserve1 / reserve2

print(f"Price: 1 DAI = {price} ETH")
print(f"Price: 1 ETH = {price2} DAI")



# Get the PairCreated events
pair_created_filter = UniswapV2Factory.events.PairCreated.createFilter(fromBlock=10000835, toBlock=10000835+10**5)

pair_created_events = pair_created_filter.get_all_entries()

# Print the first few PairCreated events
for i, event in enumerate(pair_created_events):
    print(f"Event {i + 1}:")
    print(f"  token0: {event['args']['token0']}")
    print(f"  token1: {event['args']['token1']}")
    print(f"  pair: {event['args']['pair']}")
    print(f"  ----")

    # Stop after printing first few events
    if i >= 10:
        break


