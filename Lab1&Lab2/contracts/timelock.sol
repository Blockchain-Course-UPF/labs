// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLock {
    address payable public owner;
    address payable public receiver;
    uint256 public lockEndTime;
    uint256 public lockedAmount;
    bool public withdrawn;

    // Lock duration set to 1 day
    uint256 constant LOCK_DURATION = 1 days;
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier onlyReceiver {
        require(msg.sender == receiver, "Only receiver can call this function.");
        _;
    }
    constructor(address payable _receiver) {
        require(_receiver != address(0), "Invalid receiver address.");
        owner = payable(msg.sender);
        receiver = _receiver;
    }

    function deposit() external payable onlyOwner {
        require(lockedAmount == 0, "Funds already locked.");
        require(msg.value > 0, "Amount must be greater than 0.");

        lockedAmount = msg.value;
        lockEndTime = block.timestamp + LOCK_DURATION;
    }

    function withdraw() external onlyReceiver {
        require(!withdrawn, "Funds already withdrawn.");
        require(block.timestamp >= lockEndTime, "Lock period not ended yet.");

        withdrawn = true;
        receiver.transfer(lockedAmount);
    }

    fallback() external payable {
        revert("Do not send Ether during deployment.");
    }
}
