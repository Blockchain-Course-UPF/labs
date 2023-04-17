pragma solidity ^0.8.0; // Version of Solidity

contract HelloWorld {
    event Message(string message);

    function sendHelloWorld() external {
        require(msg.value == 10 ether, "You must send exactly 10 ETH.");
        emit Message("Hello World");
    }
}
