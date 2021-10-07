#LiveBot Protocol

Specialized Token for Trading Bot # Specialized Token for Trading Bot

  

![](https://www.forex.academy/wp-content/uploads/2020/09/Crypto-Trading-Bots.jpg)



  
 

**A  new way to develop deflationary ERC20/BEP20 Tokens**

  
  
  

 - [ ] What does LiveBot's protocol solve?

  
  

**- Facilitating to add new fees**

  

> The main differentiator for  this protocol is the easy way to configure distribution rates using Struct in solidity.

```javascript

function  _addFeeLiveBotContracts() private {

_addFeeLiveBotContract(LiveFeeType.Burn, 10, burnAddress );

_addFeeLiveBotContract(LiveFeeType.Liquidity, 40, address(this) );

_addFeeLiveBotContract(LiveFeeType.External, 30, traddingBot);

_addFeeLiveBotContract(LiveFeeType.External, 20, marketingAddress);

_addFeeLiveBotContract(LiveFeeType.External, 20, devAddress);

}

```

----

  

This way, each configured rate becomes a structured index in the struct.

> feesterotype.burn =  0
> 
> feesterotype.liquidity =  1
> 
> feesterotype.external (traddingbot) =  2
> 
> feesterotype.external (marketingaddress) =  2
> 
> feesterotype.external (devaddress) =  2

  

**- Change reflection addresses by struct  index**

```javascript

function  _updateFeeLiveBotRecipient(uint256 index, address recipient) internal {

FeeStero storage fee =  _getFeeLiveBotStruct(index);

fee.recipient = recipient;

}

```

> We can thus change the address of the rate indicating the index.

  

> Let's say you want to change your marketing address, where "_setMAddress"  is index 3 set in _addFeeLiveBotContracts:

```javascript

function  _setMktAdress (address _setMAddress ) virtual internal {

//Update index from _addFeeLiveBotContracts

_updateFeeLiveBotRecipient(3,_setMAddress);

marketingAddress = _setMAddress;

}

```

```javascript

function  setMarketingAddress(address MktAddress ) external onlyOwner {

_setMktAdress(MktAddress);

}

```

  

**- Change the amount of fees**

  

Rates can be changed in the simplest way using the struct  index.

  

See how the burn rate can be changed, for example:

  

```javascript

function  _setFeeLiveBotAmount(uint256 index, uint256 amount) internal {

FeeStero storage fee =  _getFeeLiveBotStruct(index);

sumOfFeeSteros = sumOfFeeSteros - fee.value + amount;

// update the total fees sum

fee.value = amount;

}

  

```

```javascript

function  setBurnFeeLiveBot(uint256 amount) external onlyOwner {

_setFeeLiveBotAmount(0,amount);

}

```

**- Withdrawal of ETH from the contract**

  

```javascript

function  WithdrawETH(address  payable to) public onlyOwner {

require(address(this).balance >  0,"07");

to.transfer(address(this).balance);

}

```

> This function  was implemented due to the increase of ETHs that were lost sent to the contract  address, this  is a solidarity in case someone proves that they sent BNBs to the contract  by accident.

**> Trading Bots rewards for holders**

The protocol that allows you to collect tokens and make trades in an external application and return profits 
to all holders.

* Each transaction collects some fees that are transferred to an address that contains all tokens to make trades:

* The Process consists of 3 steps:

1) Collects all fees tradingBot.

2) Convert the token to a stable asset like BNB/ETH/Cake.

3) Carry out Trades 24 hours on external platforms such as Underbit (https://trading.wunderbit.co/pt).

4) With the profits acquired in trading bots, the swap is made exchanging bnb/eth for Token LiveBot with the entire amount acquired in the month or week and redistributed to all holders through a Delivery function.
