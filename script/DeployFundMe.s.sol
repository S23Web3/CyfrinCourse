//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //before the broadcast we create a new Helperconfig, so we save gas

        HelperConfig helperConfig = new HelperConfig();
        // this is a Networkconfig struct, not an address but there is only one parameter.
        address ethUSDpriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUSDpriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}
