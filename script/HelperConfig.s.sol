//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/*
1 deploy mocks when on an anvil chain
2 keep track of contract addresses of chains
*/

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // local chain presence is deploy mocks else get live network
    // we make a type because repetitiveness of the function
    // the idea is that if chainId is x then rpc is y else down the line

    struct NetworkConfig {
        address priceFeed;
    }

    //cleaning up the code with constants that are going to be used to set a mock in getAnvilConfig

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        //set which activeNetworkConfig is selected.
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //explicit declaration of pricefeed thus it needs {} inside the brackets
        // also memory must be used as where to store the value
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    //made an error in the signature, I have to return a Networkconfig object but i kept it at Networkconfig memory.
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //deploy mock contract and get address
        // if there is already an anvil spun up then we skip

        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        //make a new MockV3Aggregator with 2000 USD as ETH price
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        // make a new instance of Networkconfig called anvilConfig with the address of the mockPricegfeed
        NetworkConfig memory anvilNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});

        return anvilNetworkConfig;
    }

    /*
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        // Check to see if we set an active network config
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        //emit HelperConfig__CreatedMockPriceFeed(address(mockPriceFeed));

        anvilNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
    */
}
