var assert = require('chai').assert;
var expect = require('chai').expect;

const ganache = require('ganache-cli');
const Web3 = require('web3');

const CrowdSale = artifacts.require('CrowdSale');

contract('CrowdSale', accounts=> {

  let crowdsaleContract;
      
  beforeEach(async function() {
    return CrowdSale.deployed().then(function(instance) {            
      crowdsaleContract = instance;                 
    });
  });
  
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
  
});
