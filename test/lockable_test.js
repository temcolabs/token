var assert = require('chai').assert;
var expect = require('chai').expect;

const ganache = require('ganache-cli');
const Web3 = require('web3');

const Lockable = artifacts.require('Lockable');


contract('Lockable', accounts => {
  let lockableContract;
  let currentTime;
  beforeEach(async function() {
    return Lockable.deployed().then(function(instance) {            
      lockableContract = instance;                 
    });
  });

  it("assign constract current time", function() {                
    return lockableContract.nowTime.call().then(function(smartContractTime) {      
      //console.log("current time : " + smartContractTime);              
      currentTime = smartContractTime;
    });
  });
  
  it("no lock up for account", function() {            
    
    return lockableContract.lockedUp.call(accounts[1]).then(function(lockedUpPeriod) {      
      //console.log("account1 address : " + accounts[1] + ", lock up duration : " + lockedUpPeriod);      
      assert.equal(lockedUpPeriod, 0, "account 1 does not have lock up");      
    });
  });

  it("insert lock up to account 1", function() {    
    return lockableContract.addLockUp(accounts[1], 60).then(function() {                
      return lockableContract.lockedUp.call(accounts[1]);
    }).then(function(lockedUpPeriod) {      
      //console.log("account1 address : " + accounts[1] + ", current time :  " + currentTime + ", lock up duration : " + lockedUpPeriod);      
      let diff = (lockedUpPeriod - currentTime) / 60 / 60 / 24;
      //console.log("diff : " + diff.toFixed(0));            
      assert.equal(60, diff.toFixed(0), "account 1 lock up duration is 2 months");      
    });
  });  

  it("remove account 1 lock up", function() {    
    return lockableContract.removeLockUp(accounts[1]).then(function() {                
      return lockableContract.lockedUp.call(accounts[1]);
    }).then(function(lockedUpPeriod) {      
      //console.log("account1 address : " + accounts[1] + ", lock up duration : " + lockedUpPeriod);      
      assert.equal(lockedUpPeriod, 0, "account 1 does not have lock up");      
    });
  });  

  it("account 1 lockup status check function", function() {            
    return lockableContract.nolockedUp.call(accounts[1]).then(function(lockUpStatus) {      
      //console.log("account1 address : " + accounts[1] + ", lock up status : " + lockUpStatus);      
      assert.equal(lockUpStatus, true, "account 1 does not have lock up");      
    });
  });

  it("insert account 1 to lock up period with status check function", function() {    
    return lockableContract.addLockUp(accounts[1], 60).then(function() {                
      return lockableContract.nolockedUp.call(accounts[1]);
    }).then(function(lockUpStatus) {            
      assert.equal(lockUpStatus, false, "account 1 locked up");      
    });
  });  

  it("remove account 1 lock up with status check function", function() {    
    return lockableContract.removeLockUp(accounts[1]).then(function() {                
      return lockableContract.nolockedUp.call(accounts[1]);
    }).then(function(lockUpStatus) {            
      assert.equal(lockUpStatus, true, "account 1 does not have up");      
    });
  });  




});
