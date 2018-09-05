var assert = require('chai').assert;
var expect = require('chai').expect;

var should = require('chai').should;

const ganache = require('ganache-cli');
const Web3 = require('web3');
const { assertRevert } = require('./utils/assertRevert');

const TemcoToken = artifacts.require('TemcoToken');

contract('TemcoToken',  accounts => {

  const INITIAL_SUPPLY = 6000000000;
  const BIGGER_AMOUNT = 7000000000;
  const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

  let temcoTokenContract;
      
  beforeEach(async function() {
    return TemcoToken.deployed().then(function(instance) {            
      temcoTokenContract = instance;                 
    });
  });
  
  it("check supply amount", async function() {            
    let totalSupply = web3.fromWei(await temcoTokenContract.totalSupply(), "ether");    
    assert.equal(totalSupply, INITIAL_SUPPLY);      
  });

  it("check owner balance", async function() {                    
    assert.equal(web3.fromWei(await temcoTokenContract.balances.call(accounts[0]), "ether"), INITIAL_SUPPLY);          
  });
      
  describe('transfer', function(){
    it('cannot send amount bigger than owned', async function () {
      await assertRevert(temcoTokenContract.transfer(accounts[1], web3.toWei(BIGGER_AMOUNT, 'ether')));
    });
  
    it('cannot send amount to zero address', async function () {    
      await assertRevert(temcoTokenContract.transfer(ZERO_ADDRESS, web3.toWei(345, 'ether')));
    });

    it('send amount', async function () {    
      const SEND_AMT = 500;
      await (temcoTokenContract.transfer(accounts[1], web3.toWei(SEND_AMT, 'ether')));
      let accountBalance = web3.fromWei(await temcoTokenContract.balances.call(accounts[1]), "ether");      
      let ownerBalance = web3.fromWei(await temcoTokenContract.balances.call(accounts[0]), "ether");      
      let sum = INITIAL_SUPPLY - SEND_AMT;
      assert.equal(accountBalance, SEND_AMT);      
      assert.equal(ownerBalance, sum);                  
    });

  });

  describe('mint', async function(){        
    it('increase total supply', async function () {    
      const MINT_AMT = 1400;
      let beforeTotalSupply= web3.fromWei(await temcoTokenContract.totalSupply.call(), "ether");       
      let beforeBalance = web3.fromWei(await temcoTokenContract.balances.call(accounts[0]), "ether");       
      await (temcoTokenContract.mint(accounts[0], web3.toWei(MINT_AMT, 'ether')));
      let totalSupply = web3.fromWei(await temcoTokenContract.totalSupply.call(), "ether");      
      let ownerBalance = web3.fromWei(await temcoTokenContract.balances.call(accounts[0]), "ether");       
      let totalSum = parseInt(beforeTotalSupply) + MINT_AMT;
      let balanceSum = parseInt(beforeBalance) + MINT_AMT;      
      assert.equal(totalSum, totalSupply);      
      assert.equal(balanceSum , ownerBalance);                 
    });

    it('finish mint', async function () {    
      let mintStatus = await temcoTokenContract.mintingFinished.call();      
      assert.equal(mintStatus, false);
      await temcoTokenContract.finishMinting();
      mintStatus = await temcoTokenContract.mintingFinished.call();      
      assert.equal(mintStatus, true);
    });

    it('mint disabled', async function () {    
      const MINT_AMT = 1400;            
      await assertRevert(temcoTokenContract.mint(accounts[0], web3.toWei(MINT_AMT, 'ether')));
    });

  });

  describe('burn', async function(){        
    it('decrease total supply', async function () {    
      const BURN_AMT = 1400;
      let beforeTotalSupply= web3.fromWei(await temcoTokenContract.totalSupply.call(), "ether");       
      let beforeBalance = web3.fromWei(await temcoTokenContract.balances.call(accounts[0]), "ether");       
      await (temcoTokenContract.burn(web3.toWei(BURN_AMT, 'ether')));
      let totalSupply = web3.fromWei(await temcoTokenContract.totalSupply.call(), "ether");      
      let ownerBalance = web3.fromWei(await temcoTokenContract.balances.call(accounts[0]), "ether");       
      let totalSum = parseInt(beforeTotalSupply) - BURN_AMT;
      let balanceSum = parseInt(beforeBalance) - BURN_AMT;            
      assert.equal(totalSum, totalSupply);      
      assert.equal(balanceSum , ownerBalance);                 
    });
  });
        
});
