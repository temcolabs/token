pragma solidity ^0.4.16;

import "./Ownable.sol";
import "./TemcoToken.sol";
import "./SafeMath.sol";

/**
 * @title Temco token crowdsale
 * @dev To run crowdsale. This contract communicates with Temco token contract.
 * @author Geunil(Brian) Lee
 */
contract CrowdSale is Ownable{
    
    using SafeMath for uint256;
    
    event TransferCoinToInvester(address invester, uint256 value);
    event Received(address invester, uint256 value);
    
    TemcoToken temcoTokenContract;
    address public temcoTokenAddress;
    address public temcoEtherAddress;
    
    /**
     * Amount raised on crowdsale
     */
    uint public amountRaised;
    function getAmountRaised() public constant returns (uint) {
        return amountRaised;
    }
    
    /**
     * Crowd sale start time
     */
    uint public crowdStartTime;
    
    /**
     * Crowd sale phase dealine. Sale will have total 3 phases.
     */
    uint public crowdEndTime;
    
    /**
     * Mininum ether acceptance for invest
     */
    uint public minimumEther;
    
    /**
     * Phase ether goal
     */
    uint public goal;
    
    /**
     * Phase ether to temco token conversion rate
     */
    uint public conversionRate;
    
    
    /**
     * Hold who and how much invest on phase
     */
    mapping (address => uint256) public balances;
    function getBalance(address index) public constant returns (uint256) {
        return balances[index];
    }
    /**
     * No iteration for the mapping. Hold invester address to use iterate over maping
     */
    address[] public balanceList;
    function getBalanceList() public constant returns (address[]) {
        return balanceList;
    }

    /**
     * KYC block list
     */
    mapping (address => bool) public kycBlockedMap;
    address[] public kycBlockedMapList;
    function getKycBlockedMapList() public constant returns (address[]) {
        return kycBlockedMapList;
    }
    
    /**
    * Constructor function
    * 
    * @param temcoAddress temco token address
    * @param temcoTokenContractAddress temco token contract address
    * @param etherAddress wallet to transfer amount raised
    * @param crowdStartInMinutes crowd sale start time
    * @param crowdDurationInMinutes crowd sale duration
    * @param minEther minimum ether to receive
    * @param fundingGoal funding goal for crowd sale
    * @param rate conversion rate from ether to temco coi
    */
    function CrowdSale(
        address temcoAddress,
        address temcoTokenContractAddress,
        address etherAddress,
        uint crowdStartInMinutes,
        uint crowdDurationInMinutes,
        uint minEther,
        uint fundingGoal,
        uint rate
    ) public {
        temcoTokenAddress = temcoAddress;
        temcoTokenContract = TemcoToken(temcoTokenContractAddress);
        temcoEtherAddress = etherAddress;
        //TODO: change to date
        crowdStartTime = now + crowdStartInMinutes * 1 minutes;
        crowdEndTime = crowdStartTime + crowdDurationInMinutes * 1 minutes;
        minimumEther = minEther * 0.1 ether;
        goal = fundingGoal;
        conversionRate = rate;
    }
    
    /**
   * @dev Reverts if not in crowdsale time range. 
   */
   modifier onlyWhileOpen {
    require((now >= crowdStartTime && now < crowdEndTime) || (amountRaised < goal));
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
    function () payable public onlyWhileOpen minimumEtherRequired{
        uint amount = msg.value;
        
        amountRaised = amountRaised.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        balanceList.push(msg.sender);
        
        emit Received(msg.sender, amount); 
		
    }
    
    /**
     * Add kyc block address
     */
    function addBockList(address blockAddress) public onlyOwner {
        require(blockAddress != address(0));
        kycBlockedMap[blockAddress] = true;
        kycBlockedMapList.push(blockAddress);
    }
    
    /**
     * Remove kyc block address
     */
    function removeBockList(address blockAddress) public onlyOwner {
        require(blockAddress != address(0));
        delete kycBlockedMap[blockAddress];
        for (uint index = 0; index < kycBlockedMapList.length ; index++){
          if(kycBlockedMapList[index] == blockAddress){
              kycBlockedMapList[index] = address(0);
          }        
      }
    }
    
    /**
     * Send token to investers
     */
    function distributeCoin() public crowdSaleClosed onlyOwner{
        for (uint index = 0; index < balanceList.length ; index++){
            if(kycBlockedMap[balanceList[index]] != true){
                require(balances[balanceList[index]] > 0);
                temcoTokenContract.transferFromWithoutApproval(temcoTokenAddress, balanceList[index], balances[balanceList[index]].mul(conversionRate));
                balances[balanceList[index]] = balances[balanceList[index]].sub(balances[balanceList[index]]);
                
                emit TransferCoinToInvester(temcoTokenAddress, balances[balanceList[index]].mul(conversionRate));
            }
        }
    }
    
    /**
     * Send amount raised ether to wallet
     */
    function withdrawal() public crowdSaleClosed onlyOwner{
        require(amountRaised > 0);
        temcoEtherAddress.transfer(amountRaised);
    }
    
    /**
     * In case of goal is changed after contract deployed.
     */
    function updateGoal(uint amount) public onlyOwner{
        goal = amount * 0.1 ether;
    }
    
    /**
     * In case of conversion is changed after contract deployed.
     */
    function updateConversionRate(uint rate) public onlyOwner{
        conversionRate = rate;
    }
    
}
