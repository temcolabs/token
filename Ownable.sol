pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  
  /**
   * Ownership canb be owned by multiple ower. Useful when have multiple contract to comunicate each other
   **/
  mapping (address => bool) public owner;
  
  event OwnershipAdded(address newOwner);
  event OwnershipRemoved(address noOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner[msg.sender] == true);
    _;
  }

  /**
   * @dev Add ownership
   */
  function addOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner[newOwner] = true;
    emit OwnershipAdded(newOwner);
  }
  
  /**
   * @dev Remove ownership
   */
  function removeOwner(address noOwner) public onlyOwner{
    owner[noOwner] = false;
    emit OwnershipAdded(noOwner);
  }

}