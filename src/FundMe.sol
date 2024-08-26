//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {PriceConverter} from "src/PriceConverter.sol";

//you can send and receive money using smart contracts

contract FundMe {
    //using the price converter library
    using PriceConverter for uint256;

    uint256 public minUsd = 50 * 1e18;
    //also keep a list of addresses of those who have sent you money
    address[] public funders;
    //also use a mapping so we know how much each funder sent
    mapping(address => uint256) public addrToAmountFunded;
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    function fund() public payable {
        //payable  enables contract receive money

        // msg.value (uint): number of wei sent with the message

        //so say you want to ensure that money sent is not below some threshold:
        // msg.value > 1e18;
        //e18 is basically ether so 1e18=1ETH
        //if you want to make it required then use required keyword like so:
        //and if condo is not met you can add some message optionaly to let user know as shown below

        require(
            msg.value.getConversionRate() > 1e18,
            "You did not send enough eth"
        );
        //we are using the price converter lib on uint256 types you barb
        //since msg.value is a uint256 it has access to the libraries functionalities
        //note that the getConversionRate takes a parameter. the fact that msg.value is callin the method means it passes itself as a param already you barb
        //so say there was another param to add then that one you explicitly add in the empty parentheses
        funders.push(msg.sender); //add sender of transaction to funder list
        addrToAmountFunded[msg.sender] += msg.value;
        //add new amnt sent to any previous amnt sent in the past
    }

    function withdraw() public onlyOwner {
        //to remove all the money sent to our smart contract

        //ensure only the owner is allowed to withdraw the funds
        //require(msg.sender==owner,"only owner can withdraw funds");
        //line abv will work just fine. But in cases where we have many functions that only the owner should be able to use it is stress to paste this line in each of em
        //hence we will use modifiers
        for (uint i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addrToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // The line of code funders = new address is a Solidity statement used to reinitialize or reset a dynamic array of Ethereum addresses, effectively clearing its contents.
        // (0): This specifies the initial length of the array. By setting this to 0, you are creating a new, empty array of addresses.
        //withdrawing the funds ankasa:
        //    1. UISNG TRANSFER
        // Automatic Revert: If the transfer fails (e.g., the recipient contract's fallback function uses more than 2300 gas), the transaction will automatically revert, meaning the Ether is not sent, and the contract state is unchanged.
        //Since it reverts automatically on failure, no need for manual error handling.
        payable(msg.sender).transfer(address(this).balance);
        //    payable(msg.sender):
        // msg.sender is a global variable in Solidity that refers to the address of the entity (either an external account or another contract) that called the current function.
        // payable is a keyword in Solidity that marks an address as capable of receiving Ether. By using payable(msg.sender), you're casting msg.sender to a payable address type, which is required to send Ether to this address.
        //    address(this) refers to the address of the current contract.
        // .balance is a property that returns the amount of Ether (in wei) currently held by the contract.

        //.   2. USING SEND
        //this does not throw an error back and revert hence we need to specify
        bool isSuccessful = payable(msg.sender).send(address(this).balance);
        require(isSuccessful, "Transaction failed");

        //  3. USING CALL
        //Flexibility: call is highly flexible and can be used to send Ether and invoke functions on other contracts. Unlike transfer and send, call allows sending more than 2300 gas if needed.
        //Gas Limit: It forwards all available gas unless specified otherwise, which can potentially lead to reentrancy attacks if not used carefully.
        //Error Handling: call returns a boolean indicating success (true) or failure (false). However, if you don’t handle the return value properly, it may lead to silent failures.

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        //it returns two things and we only need 1 which is if it was successful or not
        //solidity allows such that you do not have to put a var there you can just use a comma
        require(success, "Transaction failed");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can withdraw funds");
        _;
        //  the _ symbol within a modifier represents a placeholder for the code that will be executed at the point where the modifier is applied.
        // Essentially, it indicates where the modified function's code will be inserted.
    }
    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
}
