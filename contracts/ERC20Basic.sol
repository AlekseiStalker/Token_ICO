pragma solidity ^0.4.13;

contract ERC20Basic { 
    uint256 public totalSupply;  
    function transfer(address _to, uint256 _value) public returns (bool); 
    function balanceOf(address _who) public constant returns(uint);
    event Transfer(address indexed from, address indexed to, uint256 value);
}