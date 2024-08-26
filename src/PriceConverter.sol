//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// line abv crucial for integrating Chainlink price feeds into a Solidity smart contract.
// Specifically, it allows the smart contract to interact with Chainlink's decentralized oracle network to fetch off-chain data, such as asset prices, in a reliable and secure manner.
// AggregatorV3Interface: This is the interface that defines the functions and events required to interact with a Chainlink aggregator contract. The aggregator contract collects and aggregates data from multiple oracles to provide a reliable data feed.


//cocnept of libraries



library PriceConverter{function getPrice() public view returns(uint256){

//the .roundData returns 5 things. all this info is gotten from the chainlink docs
//destructuring in solidity is done using a tuple form ie round brackets
//  This code unpacks the various components returned by the latestRoundData() function from a Chainlink price feed. Each variable provides important context about the price data, including when it was reported, which round it was part of, and the actual value (answer) itself. This information is essential for ensuring that the data used by your smart contract is accurate, timely, and reliable, especially in scenarios where the timing of the data could influence the outcomes of financial transactions or other smart contract functions.
//getting price of ether
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
// specify addr of asset that address points to the contract that aggregates price data from multiple oracles and provides the latest price for a particular asset
//the addr of asset in this case is sepolia eth


 (
            uint80 roundID,
            int answer,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData(); 
        return uint(answer*1e10);
        //price / answer has 8dp so x by 1e10 to give the 18 dp that msg.value has
    }

    function getConversionRate(uint256 ethAmount)public view returns (uint256){
        uint256 ethPrice=getPrice();
        uint256 ethAmountUsd=(ethPrice*ethAmount)/1e18;
        return ethAmountUsd;


    }
}