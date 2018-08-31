var assert = require('chai').assert;
var expect = require('chai').expect;

const ganache = require('ganache-cli');
const Web3 = require('web3');

const Ownable = artifacts.require('Ownable');

contract('Ownable', accounts => {
  let ownableContract;
  beforeEach(async function() {
    return Ownable.deployed().then(function(instance) {      
      //console.log("account address 0 : " + accounts[0]);      
      //console.log("account address 1 : " + accounts[1]);      
      //console.log("account address 2 : " + accounts[2]);      
      //console.log("account address 3 : " + accounts[3]);            
      ownableContract = instance;        
    });
  });

  it("account 1 does not have ownership", function() {              
    return ownableContract.owner.call(accounts[1]).then(function(ownership) {      
      //console.log("account1 address : " + accounts[1]);      
      assert.equal(ownership, false, "account1 does not have ownership");      
    });
  });

  it("insert account 1 to owner", function() {    
    return ownableContract.addOwnership(accounts[1]).then(function(ownership) {                
      return ownableContract.owner.call(accounts[1]);
    }).then(function(ownership) {      
      //console.log("account1 address : " + accounts[1] + ", ownership : " + ownership);      
      assert.equal(ownership, true, "account1 has ownership");      
    });
  });  

  it("remove account 0 itself not possible - owner cannot remove themself", async function() {    
    try{
      await ownableContract.removeOwner(accounts[0]); 
    }catch(event){
      //console.log("exception : " + event.message);      
      assert.include(event.message, 'revert');      
    }            
  });  

  it("remove not exist account from ownerhips", async function() {    
    return ownableContract.removeOwner(accounts[2]).then(function(ownership) {                
      return ownableContract.owner.call(accounts[2]);
    }).then(function(ownership) {            
      assert.equal(ownership, false, "account2 has not ownership");      
    });
  });  

  it("account 1 has ownership", function() {              
    return ownableContract.owner.call(accounts[1]).then(function(ownership) {      
      //console.log("account1 address : " + accounts[1]);      
      assert.equal(ownership, true, "account1 has ownership");      
    });
  });

  
  it("remove ownership from account 1", async function() {    
    return ownableContract.removeOwner(accounts[1]).then(function() {                
      return ownableContract.owner.call(accounts[1]);
    }).then(function(ownership) {            
      assert.equal(ownership, false, "account1 has not ownership");      
    });
  });  
  
});