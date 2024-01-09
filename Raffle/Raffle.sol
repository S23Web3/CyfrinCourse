// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title A sample Raffle contract
 * @author Malik
 * @notice creating a sample raffle contract
 * @dev implements Chainlink VRF2
 */

/*
https://docs.soliditylang.org/en/v0.8.23/style-guide.html#order-of-layout
Elements

Pragma statements
Import statements
Events
Errors
Interfaces
Libraries
Contracts
*/

contract Raffle is VRFConsumerBaseV2 {
    /*
    Declarations

    State variables
    Events
    Errors
    Modifiers
    Functions
        https://docs.soliditylang.org/en/v0.8.23/style-guide.html#order-of-functions
        constructor
        receive function (if exists)
        fallback function (if exists)
        external
        public
        internal
        private
    */

    error Raffle__NotEnoughETHSent();
    error Raffle__TransferFailed();
    error Raffle__RaffleIsNotOpen();

    /*Type Declarations*/

    enum RaffleState {
        OPEN, // this will be
        CALCULATING // this will be 1

    }

    /*State variables*/
    // number of block confirmations for the random number to be considered good, needs to be uint16
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    //only need one word for number of random winners (1), needs to be uint32
    uint32 private constant NUM_WORDS = 1;

    //the price a player has to pay to enter the raffle
    uint256 private immutable i_entranceFee;
    // @dev duration of the lottery in seconds
    uint256 private immutable i_interval;
    //address of the vrfCoordinator typecasted as VRFCoordinatorV2Interface so we can use the things in the contract
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    //gasLane is a variable which is also immutable and blockchain different
    bytes32 private immutable i_gasLane;
    //chainlink subscription id
    uint64 private immutable i_subscriptionId;
    //max gas to use
    uint32 private immutable i_callbackGasLimit;

    //the array of the players that joined the raffle
    address payable[] private s_players;
    address[] private s_winners;
    address private s_recentWinner;
    uint256 private s_lastTimeStamp;
    // the state of the raffle is defaulted to open (0) at the start of the contract
    RaffleState private s_raffleState;

    /**
     * Events (verb based naming, indexed so we can easily look them up, costs more gas)
     */
    event EnteredRaffle(address indexed player);
    event WinnerPicked(address indexed player);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        //start the clock at launch
        s_lastTimeStamp = block.timestamp;
        //typecast the address as the interface, then i_vrfCoordinator is of type VRFCoordinatorV2Interface
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        // the state of the raffle is defaulted to open (0) at the start of the contract
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value >= i_entranceFee) {
            revert Raffle__NotEnoughETHSent();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleIsNotOpen();
        }
        s_players.push(payable(msg.sender));

        //after the player entered we log out of the contract that this player has joined
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() external {
        //get random number, use to pick a player, once a lottery is done

        //check to see if enough time has passed
        //get current time is block.timestamp
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }

        //now we change the RaffleState to calculating in order to pick a winner without new entries while it is being calculated
        s_raffleState = RaffleState.CALCULATING;

        //to proveably random pick a winner, we use chainlink vrf, we request a number and then use some formula to pick a winner
        //from the docs we get the variable, getting the chainlink vrf coordinator address (COORDINATOR) which is different chain to chain which is why it is in the constructor
        //returning a requestid
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gas lane depending on the chain
            i_subscriptionId, // my id at chainlink
            REQUEST_CONFIRMATIONS, //number of block confirmations for the random number to be considered good
            i_callbackGasLimit, // to make sure we do not overspend on this call, different chains have different cost per gas so it is in the constructor
            NUM_WORDS // number of random words (numbers)
        );
    }

    //now that it is generated, we need to get the number back, needs a request id and temp randomwords array (I use 1 randomword but yeah, many can be requested and they need to be stored somewhere)
    //function is in vrfconsumerbase so that needs to be imported
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        //using modulo to find a remainder out of the randomnumber to pick a winner.
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        // once the index of the winner is clear, get the address of that winner and pay him/her/it
        address payable winner = s_players[indexOfWinner];
        //reset the players array after the winner is picked

        s_recentWinner = winner;
        //i want an array to keep track of the winners. Maybe also get a mapping in the future of how much they won?
        s_winners.push(winner);
        //I want to reset the array and timestamp  before I open the raffle, Patrick has it after, one might have an entry missing out on some fun in that millisecond
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(winner);

        (bool success,) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        //once the winner is selected, the raffle is open to entries again
        s_raffleState = RaffleState.OPEN;
    }

    /**
     * Getter function is external and a view
     */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
