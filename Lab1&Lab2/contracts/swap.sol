pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

contract TokenSwap {
    IERC20 private _token;
    uint256 private constant LOCK_TIME = 1 days;

    struct Swap {
        uint256 tokenAmount;
        uint256 minEthAmount;
        uint256 lockTimestamp;
        bool locked;
    }

    mapping(address => Swap) public swaps;

    constructor(IERC20 token) {
        _token = token;
    }

    function lockTokens(uint256 tokenAmount, uint256 minEthAmount) external {
        require(tokenAmount > 0, "Must specify token amount");
        require(minEthAmount > 0, "Must specify minimum ETH amount");
        require(swaps[msg.sender].locked == false, "Tokens already locked");

        _token.transferFrom(msg.sender, address(this), tokenAmount);

        swaps[msg.sender] = Swap(tokenAmount, minEthAmount, block.timestamp, true);
    }

    function unlockTokens() external {
        require(swaps[msg.sender].locked, "No locked tokens");
        require(block.timestamp >= swaps[msg.sender].lockTimestamp + LOCK_TIME, "Tokens still locked");

        uint256 tokenAmount = swaps[msg.sender].tokenAmount;

        delete swaps[msg.sender];

        _token.transfer(msg.sender, tokenAmount);
    }

    function performSwap(address tokenSeller) external payable {
        Swap storage swap = swaps[tokenSeller];

        require(swap.locked, "Tokens not locked by seller");
        require(msg.value >= swap.minEthAmount, "ETH amount not sufficient");

        uint256 tokenAmount = swap.tokenAmount;

        delete swaps[tokenSeller];

        (bool success, ) = tokenSeller.call{value: msg.value}("");
        require(success, "ETH transfer failed");

        _token.transfer(msg.sender, tokenAmount);
    }
}
