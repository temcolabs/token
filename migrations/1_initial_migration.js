var Ownable = artifacts.require("Ownable.sol");
var Lockable = artifacts.require("Lockable.sol");
var CrowdSale = artifacts.require("CrowdSale.sol");
var ERC20 = artifacts.require("ERC20.sol");
var SafeMath = artifacts.require("SafeMath.sol");
var TemcoToken = artifacts.require("TemcoToken.sol");

const temcoAddress = '0x0000000000000000000000000000000000000001';
  const temcoTokenContractAddress = '0x0000000000000000000000000000000000000002';
  const etherAddress = '0x0000000000000000000000000000000000000003';
  const crowdStartInDays = 14;
  const crowdDurationInDays = 7;
  const minEther = 1;
  const fundingGoal = 250;
  const rate = 1.5;  

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.deploy(Lockable);
  deployer.deploy(CrowdSale, temcoAddress, temcoTokenContractAddress, etherAddress, crowdStartInDays, crowdDurationInDays, minEther, fundingGoal, rate);
  //deployer.deploy(ERC20);
  //deployer.deploy(SafeMath);
  //deployer.deploy(TemcoToken);  
};
