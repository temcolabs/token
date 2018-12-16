pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol";

/**
 * @title TEMCO token crowdsale
 * @dev To run crowdsale. This contract communicates with Temco token contract.
 * @author Geunil(Brian) Lee
 */
contract CrowdSale is Ownable{
    
    using SafeMath for uint256;
    
    event TransferCoinToInvestor(address investor, uint256 value);
    event Received(address investor, uint256 value);    
    event Refund(address claimAddress, uint256 refundAmount);    
        
    address public temcoEtherAddress;
    
    /**
     * @dev Amount raised on crowdsale
     */
    uint public amountRaised;
    function getAmountRaised() public view returns (uint) {
        return amountRaised;
    }
    
    /**
     * @dev Crowd sale start time
     */
    uint public crowdStartTime;
    
    /**
     * @dev Crowd sale phase deadline. Sale will have total 3 phases.
     */
    uint public crowdEndTime;
    
    /**
     * @dev Minimum ether acceptance for invest
     */
    uint public minimumEther;
    
    /**
     * @dev Phase ether goal
     */
    uint public goal;        
        
    /**
     * @dev Hold who and how much invest on phase
     */
    mapping (address => uint256) public balances;
    function getBalance(address index) public view returns (uint256) {
        return balances[index];
    }
    /**
     * @dev No iteration for the mapping. Hold investor address to use iterate over map
     */
    address[] public balanceList;
    function getBalanceList() public view returns (address[]) {
        return balanceList;
    }
    
    /**
    * Constructor function
    *     
    * @param etherAddress wallet to transfer amount raised
    * @param crowdStartInDays crowd sale start time. unit is days
    * @param crowdDurationInDays crowd sale duration. unit is days
    * @param minEther minimum ether to receive. unit is 0.1 ether
    * @param fundingGoal funding goal for crowd sale  
    */
    constructor (      
        address etherAddress,
        uint crowdStartInDays,
        uint crowdDurationInDays,
        uint minEther,
        uint fundingGoal        
    ) public {        
        temcoEtherAddress = etherAddress;
        
        crowdStartTime = now + crowdStartInDays * 1 days;
        crowdEndTime = crowdStartTime + crowdDurationInDays * 1 days;
        
        minimumEther = minEther * 0.1 ether;
        goal = fundingGoal * 1 ether;         
    }
    
    /**
    * @dev Reverts if not in crowdsale time range. 
    */
    modifier onlyWhileOpen {
        require((now >= crowdStartTime && now < crowdEndTime) && (amountRaised < goal));
        _;
    }
   
    /**
    * @dev Reverts if in crowdsale time range. 
    */
    modifier crowdSaleClosed{
        require(now > crowdEndTime || amountRaised >= goal);
        _;
    }

    /**
    * @dev support purpose
    */
    function isCrowdSaleClosed() public view returns (bool){
        return (now > crowdEndTime || amountRaised >= goal);        
    }
   
    /**
    * @dev Reverts if not match minimum ether amount
    */
    modifier minimumEtherRequired{
        require( msg.value >= minimumEther);
        _;
    }    
    
    /**
    * Fallback function
    *
    * The function without name is the default function that is called whenever anyone sends funds to a contract
    */
    function () payable public onlyWhileOpen minimumEtherRequired {
        require(msg.sender != address(0));
        require(msg.sender != address(this));
        uint amount = msg.value;
        
        amountRaised = amountRaised.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        balanceList.push(msg.sender);        
        
        emit Received(msg.sender, amount); 		
    }            

    /**
     * @dev Refund amount raised ether
     */
    function refund(address _claimAddress, uint refundAmount) external onlyOwner{
        require(_claimAddress != address(0));            
        require(balances[_claimAddress] >= 0);
        _claimAddress.transfer(refundAmount);
        emit Refund(_claimAddress, refundAmount);
    }    

    /**
     * @dev withdrawal amount raised 
     */
    function withdrawal() external onlyOwner {
        emit TransferCoinToInvestor(temcoEtherAddress, amountRaised);
        temcoEtherAddress.transfer(amountRaised);                
    }

    /**
     * @dev Stop crowd sale
     */
    function stopCrowdSale() external onlyOwner{        
        crowdEndTime = now;
    }
    
}
