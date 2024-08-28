//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
contract FundMeTest is Test{
FundMe fundMe;

//contract itself deployed in the setUp func
//deploying involves just creating an instance of it really

function setUp()external{
 fundMe = new FundMe();
}
//after deploying then you do your tests

function testMinDollar()public view{
 assertEq(fundMe.minUsd(), 5e18);
}
function onlyOwnerWithdraws()public view{
    assertEq(fundMe.owner(), address(this));
    //reason to check addr of this FundMeTest instead of msg,sender is cos the FundMeTest deployed the FundMe contract
    //and remember our logic includes that the deployer is basically the owner you barb
}

}