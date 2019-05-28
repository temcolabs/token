var assert = require('chai').assert;
var expect = require('chai').expect;

const ganache = require('ganache-cli');
const Web3 = require('web3');

const CrowdSale = artifacts.require('CrowdSale');

contract('CrowdSale', accounts=> {

  let crowdsaleContract;
      
  beforeEach(async function() {
    this.temcoAddress = '0x0000000000000000000000000000000000000001';
    this.temcoTokenContractAddress = '0x0000000000000000000000000000000000000002';
    this.etherAddress = '0x0000000000000000000000000000000000000003';
    this.crowdStartInDays = 14;
    this.crowdDurationInDays = 7;
    this.minEther = 1;
    this.fundingGoal = 250;
    this.rate = 1.5;  

    this.crowdsale = await CrowdSale.new(
      this.temcoAddress, this.temcoTokenContractAddress, this.etherAddress, this.crowdStartInDays, this.crowdDurationInDays, 
      this.minEther, this.fundingGoal, this.rate,
      { from: accounts[0] }
    );

    return CrowdSale.deployed().then(function(instance) {            
      //crowdsaleContract = instance;                 
    });
  });

  it("check supply amount", async function() {            
    let goal = await this.crowdsale.goal.call();

    console.log("goal : " + goal);
    console.log("fundingGoal : " + this.fundingGoal);
    //assert.equal(goal, this.fundingGoal);      
  });


  it("send money", async function() {      

    let someData = {
      

    }
    
    
    //let amount = new web3.BigNumber(web3.toWei(1, 'ether'));

    let amount = web3.toWei(0.3, 'ether');
    console.log('amount : ' + amount);
    
    await this.crowdsale.send({ value: amount, from: accounts[1]});
     

    //await this.crowdsale.send({ value: '0x00', from: accounts[1], gasPrice: 0 });
    //await this.crowdsale.send({ value: new web3.BigNumber(web3.toWei(1, 'ether')), from: accounts[1], gasPrice: 0 });
    //await this.crowdsale.send({ value: amount, from: accounts[1], gasPrice: 0 });

    //await this.crowdsale.send({ value: web3.toWei(2, 'ether'), from: accounts[1]});

    //await this.crowdsale.send(accounts[1], { value: web3.toWei(2, 'ether') });

    //let amountRaised = await this.crowdsale.amountRaised.call();

    /**
    web3.eth.getBalance(accounts[1], function(err,res) {
      console.log("balance : " + res.toString(10)); // because you get a BigNumber
    });
     */

    
    //console.log("value : " + balance);    
    
    //await this.crowdsale.send({ value: value, from: accounts[1], gasPrice: 0 });
    //console.log("amountRaised : " + amountRaised);    

    //console.log("value : " + value);    
    //assert.equal(goal, this.fundingGoal);      
  });
  
  /**
  it("add whitelist", function() {    
    return crowdsaleContract.addWhiltelist(accounts[1]).then(function() {                
      return crowdsaleContract.whitelistMap.call(accounts[1]);
    }).then(function(whitelistStatus) {                  
      assert.equal(true, whitelistStatus, "account 1 is in whitelist");      
    });
  });  

  it("remove whitelist", function() {    
    return crowdsaleContract.removeEachWhiteList(accounts[1]).then(function() {                
      return crowdsaleContract.whitelistMap.call(accounts[1]);
    }).then(function(whitelistStatus) {                  
      assert.equal(false, whitelistStatus, "account 1 is not in whitelist");      
    });
  });
   */    
});
