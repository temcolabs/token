pragma solidity ^0.4.16;

import "./Ownable.sol";
import "./TemcoToken.sol";
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
    
    TemcoToken temcoTokenContract;
    address public temcoTokenAddress;
    address public temcoEtherAddress;
    
    /**
     * @dev Amount raised on crowdsale
     */
    uint public amountRaised;
    function getAmountRaised() public constant returns (uint) {
        return amountRaised;
    }
    
    /**
     * @dev Crowd sale start time
     */
    uint public crowdStartTime;
    
    /**
     * @dev Crowd sale phase dealine. Sale will have total 3 phases.
     */
    uint public crowdEndTime;
    
    /**
     * @dev Mininum ether acceptance for invest
     */
    uint public minimumEther;
    
    /**
     * @dev Phase ether goal
     */
    uint public goal;
    
    /**
     * @dev Phase ether to temco token conversion rate
     */
    uint public conversionRate;
    
    /**
     * @dev Lock up duration for current sale
     */
    uint public lockUpDuration;
    
    /**
     * @dev Hold who and how much invest on phase
     */
    mapping (address => uint256) public balances;
    function getBalance(address index) public constant returns (uint256) {
        return balances[index];
    }
    /**
     * @dev No iteration for the mapping. Hold investor address to use iterate over maping
     */
    address[] public balanceList;
    function getBalanceList() public constant returns (address[]) {
        return balanceList;
    }

    /**
     * @dev KYC block list
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
    * @param crowdStartInMinutes crowd sale start time. unit is days
    * @param crowdDurationInMinutes crowd sale duration. unit is days
    * @param minEther minimum ether to receive. unit is 0.1 ether
    * @param fundingGoal funding goal for crowd sale
    * @param rate conversion rate from ether to temco coin
    * @param lockUp lock up duration for current sale. unit is days
    */
    function CrowdSale(
        address temcoAddress,
        address temcoTokenContractAddress,
        address etherAddress,
        uint crowdStartInMinutes,
        uint crowdDurationInMinutes,
        uint minEther,
        uint fundingGoal,
        uint rate,
        uint lockUp
    ) public {
        temcoTokenAddress = temcoAddress;
        temcoTokenContract = TemcoToken(temcoTokenContractAddress);
        temcoEtherAddress = etherAddress;
        //TODO: change to date
        //crowdStartTime = now + crowdStartInMinutes * 1 days;
        //crowdEndTime = crowdStartTime + crowdDurationInMinutes * 1 days;
        crowdStartTime = now + crowdStartInMinutes * 1 minutes;
        crowdEndTime = crowdStartTime + crowdDurationInMinutes * 1 minutes;
        
        minimumEther = minEther * 0.1 ether;
        goal = fundingGoal;
        conversionRate = rate;
        //TODO: change to date
        //lockUpDuration = now + lockUp * 1 days;
        lockUpDuration = now + lockUp * 1 minutes;
    }
    
    /**
   * @dev Reverts if not in crowdsale time range. 
   */
   modifier onlyWhileOpen {
       require(isClowdsaleOpen() == true);
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
        require(msg.sender != address(0));
        uint amount = msg.value;
        
        amountRaised = amountRaised.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        balanceList.push(msg.sender);
        
        emit Received(msg.sender, amount); 
		
    }
    
    function isClowdsaleOpen() private returns(bool){
        bool open = false;
        if(amountRaised < goal){
           if(now >= crowdStartTime && now < crowdEndTime){
               open =  true;
           }
        }
        return open;
    }
    
    /**
     * @dev Add kyc block address
     * @param blockAddress address to be added to block list
     */
    function addBockList(address blockAddress) public onlyOwner {
        require(blockAddress != address(0));
        kycBlockedMap[blockAddress] = true;
        kycBlockedMapList.push(blockAddress);
    }
    
    /**
     * @dev Remove kyc block address
     * @param blockAddress address to be removed from block list
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
     * @dev Send token to investors
     */
    function distributeCoin() public crowdSaleClosed onlyOwner{
        for (uint index = 0; index < balanceList.length ; index++){
            if(kycBlockedMap[balanceList[index]] != true){
                require(balances[balanceList[index]] > 0);
                temcoTokenContract.transferFromWithoutApproval(temcoTokenAddress, balanceList[index], balances[balanceList[index]].mul(conversionRate), lockUpDuration);
                balances[balanceList[index]] = balances[balanceList[index]].sub(balances[balanceList[index]]);
                
                emit TransferCoinToInvestor(temcoTokenAddress, balances[balanceList[index]].mul(conversionRate));
            }
        }
    }
    
    /**
     * @dev Send amount raised ether to wallet
     */
    function withdrawal() public crowdSaleClosed onlyOwner{
        require(amountRaised > 0);
        temcoEtherAddress.transfer(amountRaised);
    }
    
    /**
     * @dev In case of goal is changed after contract deployed.
     * @param amount sale goal. unit is 0.1 ether
     */
    function updateGoal(uint amount) public onlyOwner{
        require(amount > 0);
        goal = amount * 0.1 ether;
    }
    
    /**
     * @dev In case of conversion is changed after contract deployed.
     * @param rate conversion rate
     */
    function updateConversionRate(uint rate) public onlyOwner{
        require(rate > 0);
        conversionRate = rate;
    }
    
}
