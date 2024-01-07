//SPDX-License-Identifier MIT

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

//importing a devops tool that helps...
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

//importing a Fundme contract
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentDeployed) public {
        //mostRecentDeployed must be casted as a payable function?
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract with %s", SEND_VALUE);
    }

    function run() external {
        //typically fund the most recent deployed contract
        // looks inside the broadcast folder based on the chainid
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        fundFundMe(mostRecentDeployed);
    }
}

contract WithdrawFundMe is Script {
    //mostRecentDeployed must be casted as a payable function?
    function withdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        //typically fund the most recent deployed contract
        // looks inside the broadcast folder based on the chainid
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        withdrawFundMe(mostRecentDeployed);
    }
}
