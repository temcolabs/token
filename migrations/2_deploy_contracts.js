var Ownable = artifacts.require("Ownable.sol");
var Lockable = artifacts.require("Lockable.sol");
var CrowdSale = artifacts.require("CrowdSale.sol");
var ERC20 = artifacts.require("ERC20.sol");
var SafeMath = artifacts.require("SafeMath.sol");
var TemcoToken = artifacts.require("TemcoToken.sol");

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.deploy(Lockable);
  //deployer.deploy(CrowdSale);
  //deployer.deploy(ERC20);
  //deployer.deploy(SafeMath);
  //deployer.deploy(TemcoToken);  
};
