// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.18;

// remix can plug straight from github (via npm) so we get the Av3I which gives the pricefeed from chainlink decentralized

//import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//updates to the code. a new version than the older one in my git.
// focus is to be more gas efficient. For example miminum usd and owner are only set once.
// such as constant and immutable
// next is to create customerrors as every string character takes gas, Pat left to convert all but the modifier so did I.
import{PriceConverter} from "./PriceConverter.sol";

error notEnoughETH();
error NotOwner();
error withdrawFail();


contract FundMe  {

    //the library gets pasted into all uint256 and now you can call a uint256 which can accesss the functions in the library Price converter
    // i need to review this part. 
    // it seems this way all the major math is done inside the library
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5;
    //array of funders who send us money, will be public to use and call as a blue button in remix, and use internal by a function
    address[] public funders;
    address public immutable i_owner;

    // mapping how much they sent
    mapping(address funder =>uint256 amountFunded)funderAmountFunded;

    
    constructor(){
        // important not to use address owner but just owner, because then a shadow variable is made.
        // then you need to do something which will cost too much gas.
        /*constructor(){
            address _owner = msg.sender;
            owner = _owner;
        */
        i_owner = msg.sender;        
    }



    function fund () public payable{
        /*
            Get funds
            get eth, this will be where the value field is populated of the wallet or in remix, that is why it says payable
            access the amount with msg.value
            minimum amount required to pass 
            
        */
        require (msg.value.getConversionRate() > MINIMUM_USD, "notEnoughETH");
        // add address to funders array
        funders.push(msg.sender);
        //add to mapping + whatever they previous had funded, one can also make a static list of per funding but Pat chose to aggregate.
        funderAmountFunded[msg.sender] = funderAmountFunded[msg.sender] + msg.value;
    }

   

    function withdraw () public onlyOwner{
        //withdraw funds, can only be called by the owner or whoever is set in the constructor
        // modifier checks if it is the owner.
        
        uint256 approxTotal = 0;

        /*
        we loop through an array to see if there is funds and keep increasing the funderindex until it is the length of the array
        then we will execute code for every index point of the array. 
         solidity uses ; not , to separate the arguments defining the loop. also the starting index needs to be a uint256
        the initializer is executed once before the loop starts. 
        Then, before every iteration, the condition is checked. If the condition is true, 
        the loop body is executed. After that, the increment is performed. 
        This process repeats until the condition becomes false
        for (initializer; condition; increment) {

        */
        for (uint256 funderindex = 0; funderindex < funders.length; funderindex++){
            //first we get the address of the funder at the index starting at 0 and store it in a temp variable memory is not needed since it can not be used for array and struct or mapping
            address funder = funders[funderindex];
            //then we nulify the funder in the mapping address, but we get the value and store it in uint256 approxTotal = 0;. 
            
            approxTotal += funderAmountFunded[funder];
            funderAmountFunded[funder] = 0;
        }
        //now we can reset the funders array. 
        funders = new address[](0);

        /*and finally we can transfer the msg.value onto the caller of the function. 
        there are three ways, transfer, send and call
        we need to typecast from address to a payable(address)
        payable(msg.sender).transfer(address.(this).balance);
        the 2 problems with transfer
        capped at 2300 or thorws an error
        
        with send it returns a boolean
        bool sendSuccess = payable(msg.sender).send(address.(this).balance);
        require(sendSuccess,"Withdraw failed");
        but then the contract stops
        */
        //call returns two variables that is why parenthesis are used on the left side of the equal sign
        // bytes returns array so it needs to be memory,
        // bytes memory data but it is not used after callsuccess so it is left empty after the comma
        (bool callSuccess, ) = payable(msg.sender).call{value : address(this).balance}("");
        require(callSuccess,"Withdraw failed");
    }

    modifier onlyOwner() {
        // old gas inefficient version require(msg.sender == i_owner,"You are not the owner calling the function");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        //this _ below means continue and is different from _tempvariable
        _;
    }

    

    // This function is called whenever a call is made to this contract.
    receive() external payable {
       // This function is called for all messages sent to
       // this contract (there is no other function).
       // Sending Ether to this contract will cause an exception,
       // because the fallback function does not have the `payable`
       // modifier.
        // when you receive ether with an empty calldata, just call the fund function.
        fund();
        revert("No receive function");
    }
    
    fallback() external {
        // some calldata was there but not defining any function that we have
        revert("No fallback function");
    }

}


