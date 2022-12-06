// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/security/ReentrancyGuard.sol";

//for testing/learning purposes only -- not production code
contract rpsv1 is ReentrancyGuard{
    mapping (address => uint) public playerBalances;
    
    event Received(address, uint);
    
    //give the contract something to bet with
    function fundContract() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    //deposit a player's funds
    function deposit() external payable {
        playerBalances[msg.sender] += msg.value;
    }
    
    //withdraw a player's funds
    function withdraw() external nonReentrant {
        uint playerBalance = playerBalances[msg.sender];
        require(playerBalance > 0);
        
        playerBalances[msg.sender] = 0;
        (bool success, ) = address(msg.sender).call{ value: playerBalance }("");
        require(success, "withdraw failed to send");
    }
    
    function getContractBalance() external view returns(uint contractBalance) {
        return address(this).balance;
    }
    
    function playGame(string calldata _playerOneChoice, string calldata _playerTwoChoice, uint _gameStake) external returns(uint gameOutcome) {
        require(playerBalances[msg.sender] >= _gameStake * (1 ether), "Not enough funds to place bet - please deposit more Ether.");
        
        //concatenation keeps it as close to the react example of Rock, Paper, Scissors as possible
        //React example here: https://github.com/nathan-websculpt/reactsolidity_frontend/blob/master/src/components/RPS.js
        bytes memory b = bytes.concat(bytes(_playerOneChoice), bytes(_playerTwoChoice));
        
        uint rslt;
        
        if(keccak256(b) == keccak256(bytes("rockrock"))
            || keccak256(b) == keccak256(bytes("paperpaper"))
            || keccak256(b) == keccak256(bytes("scissorsscissors")))
        {
            //this is a draw
            rslt = 0;
        } else if(keccak256(b) == keccak256(bytes("scissorspaper"))
            || keccak256(b) == keccak256(bytes("rockscissors"))
            || keccak256(b) == keccak256(bytes("paperrock")))
        {
            //player 1 wins
            playerBalances[msg.sender] += _gameStake * (1 ether);
            rslt = 1;
        } else if(keccak256(b) == keccak256(bytes("paperscissors"))
            || keccak256(b) == keccak256(bytes("scissorsrock"))
            || keccak256(b) == keccak256(bytes("rockpaper")))
        {
            //player 2 wins (the contract wins)
            playerBalances[msg.sender] -= _gameStake * (1 ether);
            rslt = 2;
        }
        else {
            //there was a problem with this game...
            rslt = 3;
        }
        return rslt;
        
    }
}