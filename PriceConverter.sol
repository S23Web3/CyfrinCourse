// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

//0x694AA1769357215DE4FAC081bf1f309aDC325306 is sepolia eth price address
// this is a library and we make the functions internal for now
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


library PriceConverter {
        function getPrice() internal view returns (uint256) {
        // wee need the price and the abi 0x694AA1769357215DE4FAC081bf1f309aDC325306

        /*  get the price of the AggregatorV3Interface with the sepolia address and store in pricefeed 
            then apply the latestrounddata function and select only price, removing the others but respecting their existence with a comma. price is an int and not a uint
            Patrick says it is because some price feeds could be negative. How do you have a negative price for 
            price will be in ETH representing the value in USD
            we need to typecast it since it comes in int not uint
            we are not modifying any state function so after public comes view
            and we return the price as uint256 so we add returns (uint256) above
        */  
        
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e18);
        }

        function getConversionRate (uint256 ethAmount) internal view  returns (uint256){
        /*  convert msg.value from ETH to USD with the getPrice function, 
            get ethAmount and convert to USD 
            no state is modified so it is a view
            so we do the ethPrice (which is from the getPrice function) times the ethAmount
            ethPrice will be in 1e18 so we divide later on
        */
        uint256 ethPrice = getPrice();
        //multiply before divide because in solidity we only work with whole numbers
        uint256 ethAmountinUSD = (ethPrice * ethAmount)/1e18;
        return ethAmountinUSD;
        }
        
        function getVersion () internal view returns (uint256){
            
            // gets the version of the av3i version which is a function for the address
            return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
        }

}
