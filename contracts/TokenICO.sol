pragma solidity ^0.4.13;

import './StandardToken.sol'; 

//--------------Work_contract--------------
contract TokenICO is StandardToken { 
    string public name = "Token"; 
    string public symbol = "TKN"; 
    uint8 public decimals = 2; 

    
    event Burn(address indexed burner, uint256 value);
    event RateEtherChanged(uint newRate);
 
    uint8 StageICO = 0;
    string public CurrentStageICO = "ICO not started.";
    
    uint256[11] coef;
    uint256[9] amountToConvert;
    uint8 indxCurCoeffic = 0; // 

    bool activeBuy = false; 
    uint decPlace = 100;
    uint weiPerToken = 0.0001 ether;
    uint public rate = 300; 
    bool isGoICO = false; 
    uint256 tokensPurchasedOtherCryptocurrency = 0;  

    function TokenICO() public
    { 
        totalSupply = 100000000000; 
         
        coef[0] = 4700000000000000; //* weiPerToken; 00000000000000
        coef[1] = 4800000000000000;
        coef[2] = 5800000000000000;
        coef[3] = 10800000000000000;
        coef[4] = 11800000000000000;
        coef[5] = 12800000000000000;
        coef[6] = 13800000000000000;
        coef[7] = 18800000000000000;
        coef[8] = 21800000000000000;
        coef[9] = 24800000000000000;
        coef[10] = 27800000000000000;
         
        amountToConvert[0] = 75000000000;
        amountToConvert[1] = 70000000000; 
        amountToConvert[2] = 64000000000;
        amountToConvert[3] = 57000000000;
        amountToConvert[4] = 49000000000;
        amountToConvert[5] = 40000000000;
        amountToConvert[6] = 30000000000;
        amountToConvert[7] = 20000000000;
        amountToConvert[8] = 10000000000;
        
        transferBasicTokens(); 
    }  

    function transferBasicTokens() internal { 
        balances[addressTokensForOwners] = 9975561152;
        Transfer(this, addressTokensForOwners, 9975561152);
        
        balances[addressTokensLotery] = 9800000000; 
        Transfer(this, addressTokensLotery, 9800000000);
        
        balances[addressTokensICO] = 80000000000;
        Transfer(this, addressTokensICO, 80000000000);

        balances[addressTeam] = 24438848;
        Transfer(this, addressTokensICO, 24438848);

        balances[addressInvestors] = 200000000;//insted of this -- write method to send tokens investors
        Transfer(this, addressInvestors, 200000000);
    }
 
    function setEtherExchangeRate(uint16 rateETH) onlyOwner external {
        rate = rateETH;
        RateEtherChanged(rateETH);
    } 
 
    function setActiveBuy (bool val) external onlyOwner {
         activeBuy = val; 
    }

    /// @notice Set number of Stage ICO
    /// @param isActive turns "go" and "stop" the Stage
    /// @param numStage sets the Stage number
    function setStageICO(bool isActive, uint8 numStage) onlyOwner external { 

        if (!isActive) { 
            isGoICO = isActive; 
            
            uint256 currentBalance = balances[addressTokensICO];
            uint256 tokensShouldBe;
            if (StageICO == 1) { 
                sendTokensOwners(StageICO, currentBalance - 700000000 * decPlace);
                StageICO = 2;
                tokensShouldBe = 700000000 * decPlace;
                _transfer(addressTokensForOwners, addressSmithy, 200000000);
                if (currentBalance != tokensShouldBe) { 
                    Transfer(addressTokensICO, 0x0, currentBalance - 700000000 * decPlace);
                    balances[addressTokensICO] = tokensShouldBe; //burn unsold tokens after each stage
                }   
                CurrentStageICO = "The first stage ICO is finished. Expect the second stage."; 
            } else if (StageICO == 2) { 
                sendTokensOwners(StageICO, currentBalance - 400000000 * decPlace);
                StageICO = 3;
                tokensShouldBe = 400000000 * decPlace;
                if (currentBalance != tokensShouldBe) {
                    Transfer(addressTokensICO, 0x0, currentBalance - 400000000 * decPlace);
                    balances[addressTokensICO] = tokensShouldBe;
                } 
                indxCurCoeffic = 3; 
                CurrentStageICO = "The second stage ICO is finished. Expect the third stage.";
            } else if (StageICO == 3) {
                sendTokensOwners(StageICO, currentBalance);  
                Transfer(addressTokensICO, 0x0, balances[addressTokensICO]);
                Transfer(addressTokensForOwners, 0x0, balances[addressTokensForOwners]);
                balances[addressTokensICO] = 0;
                balances[addressTokensForOwners] = 0;
                CurrentStageICO = "The ICO is finished.";
            } else { 
                CurrentStageICO = "waiting for the value";
            }
        }  else {
            if (numStage >= 1 || numStage < 4) {
                isGoICO = isActive;
                StageICO = numStage; 
                CurrentStageICO = "The ICO is go."; 
            } else {
                revert();
            }
        }
    } 
    
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool success) { 
        if (activeBuy) { 
             burn(_value, msg.sender);
        } else {
            super.transfer(_to, _value); 
        } 
        return true;
    }  
      
    function burn(uint256 _value, address _burner) public {
        require(_value > 0); 
        require (balances[_burner] >= _value);
            
        balances[_burner] -= _value;
        totalSupply -= _value;

        Burn(_burner, _value);
    } 

    function transferLoteryTokens(address[] _winners, uint256[] _value) onlyOwner public returns(bool) {
        for (uint i = 0; i < _winners.length; i++) {
            if (balances[addressTokensLotery] >= _value[i]) {
                balances[addressTokensLotery] -= _value[i];
                balances[_winners[i]] += _value[i];
                Transfer(addressTokensLotery, _winners[i], _value[i]);
            } else {
                revert();
            }
        }
        return true;
    }
     
    function () payable public {
        buyTokens();
    }
    
    function buyTokens() payable public {   
        require(isGoICO);
        require(msg.value > 0);
        uint256 weiEther = msg.value; 

        uint256 amount = getAmountToken(weiEther); 
        if (!limitOfTokens(amount)) {
            revert();
        } 

        if (_transfer(addressTokensICO, msg.sender, amount)) {
             addressTeam.transfer(msg.value);
        } else {
            revert();
        } 
    }    
  
    function getAmountToken (uint256 eth) internal returns (uint256) { 
         var curBalanceOwner = balances[addressTokensICO]; 
         var tempAmount = eth / (coef[indxCurCoeffic] / rate);
         uint256 tokenResult = 0;

         for (uint8 i = 0; i < amountToConvert.length; i++) {

            if (curBalanceOwner > tempAmount) {
                var tempAllToken = curBalanceOwner - tempAmount;
            } else {
                revert();
            }

            if (changeCoeffic(tempAllToken)) {
                var tokenByOldCoef = curBalanceOwner - amountToConvert[indxCurCoeffic-1];
                tokenResult += tokenByOldCoef;
                curBalanceOwner = curBalanceOwner - (curBalanceOwner - amountToConvert[indxCurCoeffic-1]);
                
                var partExpendEther = tokenByOldCoef * (coef[indxCurCoeffic-1]/rate);
                eth -= partExpendEther;  
                tempAmount = eth / (coef[indxCurCoeffic] / rate);
            } else {
                tokenResult += tempAmount;
                break;
            } 
        }
        return tokenResult;
           
    } 

    function changeCoeffic (uint256 countTokens) internal returns (bool) {
        if (indxCurCoeffic >= 0 && indxCurCoeffic < coef.length-1 && countTokens <= amountToConvert[indxCurCoeffic]) {
            ++indxCurCoeffic; 
            return true;
        }
        return false;
    } 
    
    function limitOfTokens(uint256 amount) internal constant returns (bool) {
        if (StageICO == 1) {
            if (balances[addressTokensICO] - amount < 700000000 * decPlace) 
                return false;
        } else if (StageICO == 2) {
            if (balances[addressTokensICO] - amount < 400000000 * decPlace) 
                return false;
        } else if (StageICO == 3) {
            if (balances[addressTokensICO] - amount < 0) 
                return false;
        } else {
            return false;
        } 
        return true;
    }
  
    function sendTokensOwners(uint8 numStage, uint256 tokens) internal returns(bool) { 
        if (tokens < 0) {
            return false;
        } else {
            uint256 earnedTokens;
            uint procOfSale = 0;
            if (numStage == 1) {
                earnedTokens = (100000000 * decPlace) - tokens; 
                if (earnedTokens > 802) {
                    procOfSale = earnedTokens / 802 * 98;
                } 
            } else if (numStage == 2) {
                earnedTokens = (300000000 * decPlace) - tokens; 
                if (earnedTokens > 802) {
                    procOfSale = earnedTokens / 802 * 98;
                }
            } else if (numStage == 3) {
                earnedTokens = (400000000 * decPlace) - tokens; 
                if (earnedTokens > 802) {
                    procOfSale = earnedTokens / 802 * 98;
                }
            }
            if (procOfSale > 0 && procOfSale <= balances[addressTokensForOwners]) {
                balances[addressTokensForOwners] -= procOfSale;  
                balances[addressTeam] += procOfSale;
                Transfer(addressTokensForOwners, addressTeam, procOfSale);
            } 
        } 
        return true;
    }

    function removeTokensByOtherCryptoCurrencies (uint256 _amountTokens) external onlyOwner { 
        if (limitOfTokens(_amountTokens)) {
            balances[addressTokensICO] -= _amountTokens;
            setNewIndex(indxCurCoeffic, balances[addressTokensICO]);
            Transfer(addressTokensICO, 0x0, _amountTokens);
            tokensPurchasedOtherCryptocurrency += _amountTokens;
        } else {
            revert();
        }
    }

    function setNewIndex(uint8 indx, uint256 _curAmount) internal onlyOwner {
        if (_curAmount <= 100000000 * decPlace) {
            indxCurCoeffic = 10;
        } else {
            while (amountToConvert[indx] > _curAmount) {
                indx++;
            }
            indxCurCoeffic = indx;
        } 
    }

    function payTokensBougthOtherCryptocurrencies (address[] _receivers, uint256[] _amountTokens) onlyOwner public returns (bool) {
        for (uint i = 0; i < _receivers.length; i++) {
            if (tokensPurchasedOtherCryptocurrency >= _amountTokens[i]) {
                tokensPurchasedOtherCryptocurrency -= _amountTokens[i];
                balances[_receivers[i]] += _amountTokens[i];
                Transfer(this, _receivers[i], _amountTokens[i]);
            } else {
                revert();
            }  
        }
        tokensPurchasedOtherCryptocurrency = 0;
        return true;
    }
    
    function convertEtherToToken(uint256 eth) public constant returns (uint) {
        uint256 weiEther = eth * 1 ether;
 
        uint8 saveIndex = indxCurCoeffic;
        uint256 amount = getAmountToken(weiEther); 
        indxCurCoeffic = saveIndex;

        return amount / decPlace;
    }

    function leftTokensOnCurrentStage() public constant returns(uint) {
        if (isGoICO && StageICO == 1) {
            return balances[addressTokensICO] / decPlace - 700000000;
        }else if (isGoICO && StageICO == 2) {
            return balances[addressTokensICO] / decPlace - 400000000;
        } else if (isGoICO && StageICO == 3) {
            return balances[addressTokensICO] / decPlace;
        } else {
            return 0;
        }
    } 

    function TokensBougthByOtherCryptocurrency () public constant returns (uint256) {
        return tokensPurchasedOtherCryptocurrency;
    } 

    function StageOfICO() public constant returns (uint8) {
        return StageICO;
    }  
 
    /////////////For_TESTS////////// 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) { 
        _transfer(_from, _to, _value); 
        return true;              //
    }                             //
    function CurCoeffic () public constant returns(uint) {
        return indxCurCoeffic;    //
    }                             //
    ////////////////////////////////
}   