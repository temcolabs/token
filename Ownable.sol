pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * based on https://https://github.com/OpenZeppelin/zeppelin-solidity. modified to have multiple ownership.
 * @author Geunil(Brian) Lee
 */
contract Ownable {
  
  /**
   * Ownership can be owned by multiple owner. Useful when have multiple contract to communicate  each other
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
   * @param newOwner add address to the ownership
   */
  function addOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner[newOwner] = true;
    emit OwnershipAdded(newOwner);
  }
  
  /**
   * @dev Remove ownership
   * @param ownership remove ownership
   */
  function removeOwner(address ownership) public onlyOwner{
    require(ownership != address(0));
    delete owner[ownership];
    emit OwnershipAdded(ownership);
  }

}