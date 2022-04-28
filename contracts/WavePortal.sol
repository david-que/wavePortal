// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver; // the address of the user who waved
        string message; // the message the user sent
        uint256 timestamp; // the timestamp when the user waved
    }

    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("I am a smart contract");
        // set initial seed
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        //make sure the current timestamp is at least 15 minutes bigger than the last timestamp
        require(
            lastWavedAt[msg.sender] + 20 seconds < block.timestamp, 
            "Wait 20 seconds before waving agian"
        );

        //update current timestamp we have for the user
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        //generate a new seed for the next user that sends a wave
        seed = (block.difficulty + block.timestamp + seed) % 100;

        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require( 
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);

        uint256 prizeAmount = 0.001 ether;
        require(
            prizeAmount <= address(this).balance,
            "Trying to withdraw more money than the contrac has."
        );
        (bool success, ) = (msg.sender).call{value: prizeAmount}("");
        require(success, "Failed to withdraw money from contract.");
    }

      /*
     * I added a function getAllWaves which will return the struct array, waves, to us.
     * This will make it easy to retrieve the waves from our website!
     */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}