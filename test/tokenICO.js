var TokenICO = artifacts.require("./TokenICO.sol");
const assertJump = require('./assertJump.js');

contract ('TokenICO', function(accounts) {
    let instance = null;
  
    describe('Test_contract_with_global_instance', function() {
        it("Can't but tokens before active ICO", async () => {
            instance = await TokenICO.new();

            try {
                await instance.buyTokens({from: accounts[1], value: 10});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            }
        });

        it('totalSupply must be 1 000 000 000', async () => {
            let totalSup = await instance.totalSupply();
            assert.equal(totalSup, 100000000000);//with 2 decimals
        });

        it('should correctly transfer reserved tokens', async () => { 
            let accICO = await instance.balances("0xc2a6b764c4C429e9a7786575122c794aE078E380");
            let accOwners = await instance.balanceOf("0xdC6ce9e2E546156A2cC4EfAaDC0cA94B0f3007E3");
            let accLotery = await instance.balanceOf("0x7e6b99a311327Ddd00E4640eF091BaEaBEF2db9F"); 
  
            assert.equal(accICO.toNumber(), 80000000000);
            assert.equal(accOwners.toNumber(), 9975561152);
            assert.equal(accLotery.toNumber(), 9800000000); 
        }); 

        it('can buy tokens only on ether_value > 0', async () => {
            await instance.setStageICO(true, 1);

            try {
                await instance.buyTokens({from: accounts[1], value: 0});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            }
            try {
                await instance.buyTokens({from: accounts[1], value: -1});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
        });

        it('Cant send tokens on reserved address (owners/tokens_store/lotery/contract)', async () => {
            
            await instance.transferFrom("0x7e6b99a311327Ddd00E4640eF091BaEaBEF2db9F", 
                                        accounts[1], 10000, {from: accounts[0]});

            try {
                await instance.transfer("0xc2a6b764c4C429e9a7786575122c794aE078E380", 
                                        50, {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            }
            try {
                await instance.transfer("0xdC6ce9e2E546156A2cC4EfAaDC0cA94B0f3007E3",
                                        50, {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
            try {
                await instance.transfer("0x7e6b99a311327Ddd00E4640eF091BaEaBEF2db9F", 
                                        50, {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error); 
            } 
        });

        it ('Cant send token < 0', async () => { 
            try {
                await instance.transfer(accounts[5], -1, {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch (error) {
                assertJump(error);
            }
        });

        it('should throw an error when trying to transfer to 0x0', async () => {
            try {
                await instance.transfer(0x0, 100, {from: accounts[1]});
                assert.fail('should have thrown before');
            } catch(error) {
                assertJump(error);
            }
        });

        it ('should correctly send tokens between accounts', async () => {
            await instance.transfer(accounts[2], 1488, {from: accounts[1]});
            await instance.transfer(accounts[3], 666, {from: accounts[1]});
            await instance.transfer(accounts[4], 666, {from: accounts[3]});
  
            let acc2 = await instance.balanceOf(accounts[2]);
            let acc3 = await instance.balanceOf(accounts[3]);
            let acc4 = await instance.balanceOf(accounts[4]);
  
            assert.equal(acc2, 1488);
            assert.equal(acc3, 0);
            assert.equal(acc4, 666);
        });

        it ('coorectly amount of tokens bougth on 0.0016 ether', async () => { 
            let val = web3.toWei('0.0016', 'ether');
            await instance.buyTokens( {from: accounts[5], value: val} );
            let fiveAccBalance = await instance.balanceOf(accounts[5]); 
            
            let generalResult = fiveAccBalance.toNumber();
            //console.log(generalResult);
            assert.equal(generalResult, 102); 
        });
    });
    //-----------------------------------------------------------------------------------------------------

    let token = null;
    
        describe('Each_test_with_individual_scenarios', function() {
            
            beforeEach(async () => {
                // Create contract and start ICO
                token = await TokenICO.new();
                await token.setStageICO(true, 1);
              });
    
            it('coorectly amount of tokens purchased with a modified coefficient', async () => {
                await token.setEtherExchangeRate(600000);
                let val = web3.toWei('42', 'ether');
                await token.buyTokens({from: accounts[1], value: val});
                let firstAccountBalance = await token.balanceOf(accounts[1]); 
                //console.log(generalResult);
                assert.equal(firstAccountBalance.toNumber(), 90934468);
            });
    
            it('cant buy tokens between stages', async () => {
                await token.setStageICO(false, 1);
                
                let amount = web3.toWei('4', 'ether');
                try {
                    await token.buyTokens({from: accounts[1], value: amount});
                    assert.fail('should have thrown before');
                } catch(error) {
                    assertJump(error); 
                } 
            });
    
            it('after ICO token balance on reserved accounts is equal 0', async () => {
                await token.setStageICO(false, 3); 
                let accICO = await token.balanceOf(accounts[9]);
                let accOwners = await token.balanceOf(accounts[8]);
    
                assert.equal(accICO, 0);//80000000000
                assert.equal(accOwners, 0);//9975561152
            });
    
            it('send tokens bougth by other cryptocurrecy (correct accounts balances and current index)', async () => {
                await token.removeTokensByOtherCryptoCurrencies(25000000000);
    
                await token.payTokensBougthOtherCryptocurrencies([accounts[3], accounts[4], accounts[5]],
                                                                [13000000000, 2000000000, 10000000000]);
    
                let balanceAcc3 = await token.balanceOf(accounts[3]);
                let balanceAcc4 = await token.balanceOf(accounts[4]);
                let balanceAcc5 = await token.balanceOf(accounts[5]);

                // let index = await token.CurCoeffic();
                
                // assert.equal(index, 5, 'wrong index');
                assert.equal(balanceAcc3, 13000000000, 'wrong acc3 balance');
                assert.equal(balanceAcc4, 2000000000, 'wrong acc3 balance');
                assert.equal(balanceAcc5, 10000000000, 'wrong acc4 balance');
            });
    
            it('cant remove more then limit of tokens on stage (bougth by other cryptocurrency))', async () => {
                await token.setStageICO(false, 1);
                await token.setStageICO(true, 2);
                
                try {
                    await token.payTokensBougthOtherCryptocurrencies([accounts[6]], [35000000000]);
                    assert.fail('should have thrown before');
                } catch (error) {
                    assertJump(error);
                }
            });
    
            // it ('cant send more tokens, then sold out by other cryptocurrency', async () => {
            //     await token.setStageICO(false, 1);
            //     await token.setStageICO(true, 2);
    
            //     try {
            //         await token.payTokensBougthOtherCryptocurrencies([accounts[3], accounts[4]],
            //                                                         [20000000000, 10500000000]);
            //         assert.fail('should have thrown before');     
            //     } catch (error) {
            //         assertJump(error);
            //     } 
            // });
    
            it ('should correctly send lotery tokens (correct remaining lotery_tokens & account balance)', async () => {
                await token.transferLoteryTokens([accounts[3], accounts[4]], [300000000, 4000000000]);
                let acc3Balance = await token.balanceOf(accounts[3]);
                let acc4Balance = await token.balanceOf(accounts[4]);
    
                let loteryTokens = await token.balanceOf("0x7e6b99a311327Ddd00E4640eF091BaEaBEF2db9F");
                //console.log(loteryTokens);
                assert.equal(loteryTokens, 5500000000);
                assert.equal(acc3Balance, 300000000);
                assert.equal(acc4Balance, 4000000000);
            });
    
            it ('cant send more than lotery account balance', async () => {
                try {
                    await token.transferLoteryTokens([accounts[3]], [9900000000]);
                    assert.fail('should have thrown before'); 
                } catch (error) {
                    assertJump(error);
                }
            });
    
            it ('should return correct totalSupply and balance buyer, after buy services for tokens', async () => {
                await token.transferFrom("0xc2a6b764c4C429e9a7786575122c794aE078E380", accounts[5], 5000000000);
                await token.setActiveBuy(true, {from: accounts[0]})
                await token.transfer(token.address, 4000000000, {from: accounts[5]});
                let totalSupp = await token.totalSupply();
                let balanceAcc5 = await token.balanceOf(accounts[5]);
                //console.log(totalSupp);
                assert.equal(totalSupp, 96000000000);
                assert.equal(balanceAcc5, 1000000000);
            });
        });
});