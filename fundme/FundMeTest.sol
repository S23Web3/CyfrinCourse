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
    address USER = makeAddr("user");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        /*
        new instance of a Fundme contract with small f. THe () go after the new FundMe
        fundMe variable of type FundMe is going to be a new FundMe contract
        overwriting the state variable that is previous declared called fundMe

        this is the old way, fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployFundMe is a smart contract launching the run
        */
        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();

        // we create a temp User and give the some eth
        vm.deal(USER, STARTING_BALANCE);
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
        assertEq(fundMe.getOwner(), msg.sender);

        //initially fails because the maker of the contract is this test.
    }

    /*
    I wanted to test if the mapping runs correctly,
    The bump to do so now comes from sending ether to the function
    This is solved below


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

    function testFundFailsdidNotSendEnoughEth() public {
        //next line of code after expectRevert should fail
        vm.expectRevert();
        // sending no funds with the function should make a revert
        fundMe.fund();
    }
    // next 2 tests, the mapping getAddressToAmountFunded and the list getFunders

    function testFundUpdatesFundedDataStructure() public funded {
        /*
        the fund function in the FundMe contract
        funds of msg.value should reflect in the mapping array of addressToAmountFunded
        need to spoof some eth and see if it is reflected in the mapping at the index (msg.sender)
        also the address needs to be added to the funders array
        |
        so need to break away, create getters and set to private 
        */
        // made 2 getters getFunders & getAddresstoAmountFunded

        //don't forget the brackets after the fund function or it will not call a function.

        //added a modifier so commenting some parts that were previously repeated

        //vm.prank(USER);
        //we send the value of 10 eth to the fund function which is a payable function
        //fundMe.fund{value: SEND_VALUE}();
        // we are checking that the address who sent the function is in the getAddressToAmountFunded mapping and what value there is
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        // now comparing both, if it works it should prove that the sent along amount is reflected in the mapping
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddressToArrayOfFunders() public funded {
        //added a modifier so commenting some parts that were previously repeated
        //Have a user that has an address
        //vm.prank(USER);
        // send some funds to a FundMe contract
        //fundMe.fund{value: SEND_VALUE}();
        //should be user because we only have one funder that calls the address and we need to give the index
        //1 address only because every time we start the test it runs the setup and then the test.
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testMultipleFunders() public {
        // Define multiple users up in the contract with address userx = makeAddr("user");
        // address user1 = /* user1 address */;
        // address user2 = /* user2 address */;
        // address user3 = /* user3 address */;

        // Prank each user and send some funds

        vm.prank(user1);
        vm.deal(user1, STARTING_BALANCE);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(user2);
        vm.deal(user2, STARTING_BALANCE);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(user3);
        vm.deal(user3, STARTING_BALANCE);
        fundMe.fund{value: SEND_VALUE}();

        // Test if each user is added to the funders array and the mapping
        assertEq(fundMe.getFunders(0), user1);
        assertEq(fundMe.getFunders(1), user2);
        assertEq(fundMe.getFunders(2), user3);

        assertEq(fundMe.getAddressToAmountFunded(user1), SEND_VALUE);
        assertEq(fundMe.getAddressToAmountFunded(user2), SEND_VALUE);
        assertEq(fundMe.getAddressToAmountFunded(user3), SEND_VALUE);
    }

    function testMultipleAddressesToArrayOfFunders() public {
        // Define multiple users
        address[3] memory users = [user1, user2, user3];
        vm.deal(user1, STARTING_BALANCE);
        vm.deal(user2, STARTING_BALANCE);
        vm.deal(user3, STARTING_BALANCE);

        // Send some funds to the FundMe contract for each user
        for (uint256 i = 0; i < users.length; i++) {
            // Set the prank to the current user
            vm.prank(users[i]);
            vm.deal(users[i], STARTING_BALANCE);

            // Call the fund function with a different value for each user
            uint256 sendValue = (i + 6) * 10e18;
            fundMe.fund{value: sendValue}();

            // Retrieve the address at the current index from the funders array
            address funder = fundMe.getFunders(i);
            console.log(funder);

            // Assert that the retrieved address matches the current user's address
            assertEq(fundMe.getFunders(i), users[i]);
        }
    }

    function testOnlyOwnerCanWithdraw() public funded {
        //first thing to do is fund the contract
        vm.prank(USER);
        //we send the value of 10 eth to the fund function which is a payable function
        fundMe.fund{value: SEND_VALUE}();
        //it should revert if not the owner calls the function
        vm.expectRevert();
        // user will attempt withdraw and should fail meaning the test passes, vm.expectRevert ignores the vm.xxx calls
        vm.prank(USER);
        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testWithdrawSingleFunder() public funded {
        //Now we get to work with the arrange, act and assert methodology

        //Arrange, get it setup

        // first check what the balance is before the withdraw, then we can compare it after, creating a getOwner in the fundMe contract.
        uint256 startingOwnerBalanc = fundMe.getOwner().balance;
        //set the balance of the contract in a variable
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        //all money is withdrawn so balance shoudl be 0
        assertEq(endingFundMeBalance, 0);
        //the money balance of the owner in the end should be what he got in the beginning plus the money of the contract
        assertEq(startingOwnerBalanc + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded {
        //Arrange, setup the contract
        uint160 numberOfFunders = 10;
        //using a higher starting address because there might be issues with address (0)
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            //instead of vm.prank and vm.deal we use hoax, casting the address as uint160?
            // when they are funded they should be added to the list and the mapping as the fund function gets populated
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }
        //set the balance of the contract in a variable
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        //get the balance of the contract
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 endingFundMeBalance = address(fundMe).balance;
        vm.stopPrank();

        //all money is withdrawn so balance should be 0
        assert(address(fundMe).balance == 0);
        //the money balance of the owner in the end should be what he got in the beginning plus the money of the contract
        console.log(startingOwnerBalance);
        console.log(endingFundMeBalance);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }
}
