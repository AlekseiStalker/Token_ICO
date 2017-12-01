 
var TokenICO = artifacts.require("./TokenICO.sol");
const assertJump = require('./assertJump.js');

contract ('Owned', function(accounts) {
    let token = null; 

    it ('execute onlyOwner method call by owner (correctly change rateEther)', async () => {
        token = await TokenICO.new();//for all tests

        await token.setEtherExchangeRate(420, {from: accounts[0]});
        let newRate = await token.rate();

        assert.equal(newRate, 420);
    });

    it ('should get exeption when somebody call onlyOwner method', async () => {
        try {
            await token.setEtherExchangeRate(420, {from: accounts[2]});
            assert.fail('should have thrown before');
        } catch(error){
            assertJump(error);
        }
    });

    it ('should get exeption when somebody try to change stage ICO', async () => {
        try {
            await token.setStageICO(true, 1, {from: accounts[2]});
            assert.fail('should have thrown before');
        } catch(error){
            assertJump(error);
        }
    });

    it ("should get exeption when somebody call 'transferLoteryTokens'", async () => {
        try {
            await token.transferLoteryTokens([accounts[3], accounts[4]], [300000000, 4000000000], {from: accounts[1]});
            assert.fail('should have thrown before');
        } catch(error){
            assertJump(error);
        }
    });

    it ("should get exeption when somebody call 'payTokensBougthOtherCryptocurrencies'", async () => {
        try {
            await token.payTokensBougthOtherCryptocurrencies([accounts[3], accounts[4], accounts[5]],
                [13000000000, 2000000000, 10000000000], {from: accounts[1]});
            assert.fail('should have thrown before');
        } catch(error){
            assertJump(error);
        }
    });

    it ("should get exeption when somebody call 'removeTokensByOtherCryptoCurrencies'", async () => {
        try {
            await token.removeTokensByOtherCryptoCurrencies(1000, {from: accounts[1]});
            assert.fail('should have thrown before');
        } catch(error){
            assertJump(error);
        }
    });
}); 