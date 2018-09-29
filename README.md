# Token_ICO
Smart contract for creating a token and implementation of ICO.

---------------- 
(This is my experience of programming solidity Smart contract, dated June 2017. This contract is not a sample of the standard and contains a lot of strange logic, but it still interesting for me to watch my progress, so I'll post it as my first works. In addition, I wrote this contract for a company that has already completed the preICO, so some things may not be fully understandable.)
---------------- 
 
Smart contract contains such contracts as Ownable.sol, ERC20Basic.sol (they are also the standard ERC179) and StrandardToken.sol, which contains the implementation of this standard.

The basic logic is contained in the contract TokenICO.sol

## Main characteristics of smart contract
- Total contract creates 1md. tokens.
- 2 million tokens are sold at preICO.
- 98 million are stored on purse for payment of lotteries and bounty.
- 100 million tokens are sent to the purse, from which tokens will be withdrawn. The percentage  of the sold tokens after each stage is calculated and sent to the team
- Exchange rate token to ether set manually (due to a strong change ether rate)
- The cost of the token increases as the number of tokens sold increases.
- All ICO stages will "switched on" and "off" manually.
- If at some stage not all tokens are sold - unsold tokens are burned.
- All test are written on JavaScript in the 'test' folder. 

Below are the dates of the stages of ICO and how many tokens should be sold at each of the stages.

![default](https://user-images.githubusercontent.com/29926552/33488871-cc3ac7de-d6ba-11e7-9689-8b0bc6abd54d.png)
 
## How to setup development environment and run tests?

use this link to install all u needed -> http://truffleframework.com/tutorials/how-to-install-truffle-and-testrpc-on-windows-for-blockchain-development

1. Install truffle if you don't have it.
2. Clone this repo.
3. Run 'testrpc'.
4. Run 'truffle test' in your local directory, wich contain this repo.    

I did not use migrations in truffle, instead I downloaded the Mist (or EthereumWallet) with full node ethereum, inserted all the contract .sol into one file and loaded it into blockchain.
