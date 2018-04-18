pragma solidity ^0.4.18;


import "./Ownable.sol";


/**
 * @title Lockable
 * @dev lock up token transfer during duration. This helps lock up private and pre-sale investor cannot sell token certain period.
 * @author Geunil(Brian) Lee
 */
contract Lockable is Ownable {
  
    /**
    * @dev hold lock up address and duration
    */
    mapping(address => uint256) public lockedUp;
  
  
    /**
    * @dev lock up by pass when duration is passed or not exist on lockedUp mapping.
    */
    modifier whenNotLockedUp() {
        require(lockedUp[msg.sender] < now || lockedUp[msg.sender] == 0 );
        _;
    }
  
    /**
    * @dev add lock up investor to mapping
    * @param investor lock up address
    * @param duration lock up period. unit is days
    */
    function addLockUp(address investor, uint duration ) onlyOwner public {
    // TODO : change to date
    //lockedUp[investor] = now + duration * 1 days;
        require(investor != address(0) && duration > 0);
        lockedUp[investor] = now + duration * 1 minutes; 
    }
    
    /**
    * @dev remove lock up address from mapping
    * @param investor lock up address to be removed from mapping
    */
    function removeLockUp(address investor ) onlyOwner public {
        require(investor != address(0));
        delete lockedUp[investor]; 
    }
  
  
}