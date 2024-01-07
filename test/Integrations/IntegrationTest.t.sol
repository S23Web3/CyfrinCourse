//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//importing the standard Test contract from foundry
import {Test, console} from "forge-std/Test.sol";
// importing our own contract
import {FundMe} from "../../src/FundMe.sol";
//importing the deploy script in order to have one point of deployment
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract IntegrationTest is Test {
    //the start of the contract until the test function is a bit the same from the unit test
    FundMe fundMe;
    address USER = makeAddr("user");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        //deploy a new fund me contract
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();

        // we create a temp User and give the some eth
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        //testing if the funding and withdraw works using the scripts
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);

        // vm.prank(USER);

        // vm.deal(USER, 1e18);

        // fundFundMe.fundFundMe(address(fundMe));

        // address funder = fundMe.getFunders(0);
        // assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        vm.deal(USER, 1e18);

        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}
