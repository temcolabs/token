var assert = require('chai').assert;
var expect = require('chai').expect;

const ganache = require('ganache-cli');
const Web3 = require('web3');

const Ownable = artifacts.require('Ownable')

contract('Ownable', accounts => {
  let ownableContract;
  it("check owner", function() {
    return Ownable.deployed().then(function(instance) {      
      console.log("account address 0 : " + accounts[0]);      
      console.log("account address 1 : " + accounts[1]);      
      console.log("account address 2 : " + accounts[2]);      
      console.log("account address 3 : " + accounts[3]);            
      ownableContract = instance;  
      return ownableContract.manager.call();
    }).then(function(manager) {      
      console.log("owner address : " + manager);      
      assert.equal(manager, "0x627306090abab3a6e1400e9345bc60c78a8bef57", "owner has ownable");
    });
  });

  it("account 1 does not have ownership ()", function() {              
    return ownableContract.owner.call(accounts[1]).then(function(ownership) {      
      console.log("account1 address : " + accounts[1]);      
      assert.equal(ownership, false, "account1 does not have ownership");      
    });
  });

  it("insert account 1 to owner", function() {    
    return ownableContract.addOwnership(accounts[1]).then(function(ownership) {                
      return ownableContract.owner.call(accounts[1]);
    }).then(function(ownership) {      
      console.log("account1 address : " + accounts[1] + ", ownership : " + ownership);      
      assert.equal(ownership, true, "account1 has ownership");      
    });
  });  

  it("remove account 0 itself not possible - owner cannot remove themself", async function() {    
    try{
      await ownableContract.removeOwner(accounts[0]); 
    }catch(event){
      console.log("exception : " + event.message);      
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
      console.log("account1 address : " + accounts[1]);      
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




 /*
const MyToken = artifacts.require('Ownable')

contract('Ownable', accounts => {
  let myToken = null
  const owner = accounts[0]

  beforeEach(async function() {
    myToken = await MyToken.new({ from: owner })
  })

  it('has a total supply and a creator', async function () {
    let a = 10;
    let b = 20;
    assert.eqaul(a, b, "equal");
  })
})

*/


/**

let foo = 'bar';
let beverages = {tea: ['chai', 'matcha', 'oolong']};
let answer = 43;

describe('Array', function() {
  describe('#indexOf()', function() {
    console.log("test case for the array");
    it('should return -1 when the value is not present', function() {
      assert.equal([1,2,3].indexOf(4), -1);
    });    

  });
});

describe('assertion test', function(){
  it('should be string', function() {
    assert.typeOf(foo, 'string', 'foo is a string');
  });

  it('should be equal', function() {
    assert.equal(foo, 'bar');
  });

  it('foo string size equal', function() {
    assert.lengthOf(foo, 3);
  });

  it('bevarages array size equal', function() {
    assert.lengthOf(beverages.tea, 3);
  });
});

describe('expect test', function(){

  it('expect type - foo to be string', function() {
    expect(foo).to.be.a('string');    
  });

  it('expect equal foo eqaul bar', function() {
    expect(foo).to.equal('bar');    
  });

  it('expect size equal foo string size is 3', function() {
    expect(foo).to.have.lengthOf(3);    
  });

  it('expect size equal beverage array size is 3', function() {
    expect(beverages).to.have.property('tea').with.lengthOf(3);
  });

  it('expect answer is equal to 43', function() {
    this.skip();
    expect(answer).to.equal(42);
  });

  it('expect answer is equal to 43 with custom message', function() {    
    this.skip();
    expect(answer, 'topic[answer]').to.equal(42);
  });

});

 */