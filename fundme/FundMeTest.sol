//SPDX-License identifier: MIT

pragma solidity ^0.8.18;

//importing the standard Test contract from foundry
import {Test, console} from "forge-std/Test.sol";
// importing our own contract
import {FundMe} from "../src/FundMe.sol";

//importing the deploy script in order to have one point of deployment
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    //first thing to do is deploy the contrcat FundMe, later this is done in Script
    // we need it as a state variable for other functions to be able to call them.

    FundMe fundMe;

    function setUp() external {
        // new instance of a Fundme contract with small f. THe () go after the new FundMe
        //fundMe variable of type FundMe is going to be a new FundMe contract
        //overwriting the state variable that is previous declared

        // this is the old way, fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // deployFundMe is a smart contract

        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();
    }

    function testMinimumDollarIsFive() public {
        //check in the fundMe made contract if the variable is indeed 5 dollars
        //assertEq comes from the forge-std test contract
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisMessageSender() public {
        /* I can not compare two strings in solidity, i can compare their hash: invalid: assertEq(msg.sender, fundMe.i_owner);
         I use this function keccak256() along with abi.encodePacked() to convert the strings 
         into bytes and then compute their hash values. If the hash values are equal, the strings are considered equal.
         function compareStrings(string memory a, string memory b) public pure returns (bool) {
         return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
         that is too expensive in gas
        
        function compareStrings(string memory a, string memory b) public pure returns (bool) {
            if (bytes(a).length != bytes(b).length) {
                return false;
            }
            return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
        }

        with
        require(compareStrings(msg.sender, fundMe.i_owner), "The sender is not the owner")
        in this function.

        But Patrick might have a different look on it         
         */
        assertEq(fundMe.i_owner(), msg.sender);

        //initially fails because the maker of the contract is this test.
    }

    /*
    I wanted to test if the mapping runs correctly,
    The bump to do so now comes from sending ether to the function

    I will have to come back to this later
    function testMapping() public {
        // Send 1 ether to the contract
        address(fundMe).transfer(1 ether);
        // Then call the fund function
        fundMe.fund();
        // Check if the mapping contains the correct amount
        if (fundMe.addressToAmountFunded(address(this)) != 1 ether) {
            revert("The mapping did not update correctly");
        }
    }
    */

    function testGetVersion() public {
        //this is the first time I test a function so forge coverage should me updated from 0
        //it should fail because the sepolia rpc is not configured yet (when uploading it works)
        uint256 version = fundMe.getVersion();
        uint256 expectedVersion = 4;
        assertEq(version, expectedVersion);
    }
}
