// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract HelloWorld {
    event Message(string _messsage);
    event NewAdmin(address);
    address admin;
    string [] history;
    modifier onlyOwner() {
        require(admin[msg.sender], _);
    }
    constructor() {
        admin[msg.sender] = true;
    }
    function echo(string memory _message) public {
        emit Message(_message);
        history.push(_message);
    }
    function lookup(uint _index) public view returns (string memory) {
        return history[_index];
    }
    function addAdmin(address _admin) onlyOwner public {
        admin[admin] = true;
        emit NewAdmin(_admin);
    }
}