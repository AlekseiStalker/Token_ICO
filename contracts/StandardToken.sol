pragma solidity ^0.4.10;

import './ERC20Basic.sol';
import './Owned.sol';

contract StandardToken is ERC20Basic, Owned {
 
    mapping (address => uint256) public balances; 

    //accounts in Testnet
    address addressTeam = 0x5E90BD0f0d9fc7d4BC9F6e943ff8246B6906E4C1;//
    address addressInvestors = 0x463685Dd9a4bDEADa66281031241e0602353d83D;
    address addressTokensForOwners = 0xdC6ce9e2E546156A2cC4EfAaDC0cA94B0f3007E3;//100
    address addressTokensLotery = 0x7e6b99a311327Ddd00E4640eF091BaEaBEF2db9F;//98s
    address addressTokensICO = 0xc2a6b764c4C429e9a7786575122c794aE078E380;//802
    address addressSmithy = 0xB33CCDCd882D283EE77095BC7C8A54e466388312;

    modifier safetyTransfer (address to){
        if (msg.sender != owner) {
            require(to != addressTokensForOwners && to != addressTokensLotery &&
                    to != address(this) && to != addressTokensICO);
        }
        _;
    }

    modifier onlyPayloadSize(uint size) { 
        require(msg.data.length >= size + 4);
        _;
    }

    function _transfer(address _from, address _to, uint _value) safetyTransfer(_to) internal returns (bool) { 
      require (_to != 0x0); 
      require (balances[_from] >= _value);                
      require (balances[_to] + _value > balances[_to]);

      balances[_from] -= _value;                         
      balances[_to] += _value;        
      Transfer(_from, _to, _value);
      return true;
    }
 
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool success) {  
        _transfer(msg.sender, _to, _value); 
        return true;
    }  

    function balanceOf(address _who) public constant returns(uint) {
        return balances[_who];
    }
}
