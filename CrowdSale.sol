pragma solidity 0.4.21;

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

    uint private constant GAS_LIMIT = 600000;
    
    TemcoToken private temcoTokenContract;
    address public temcoTokenAddress;
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
     * @dev Phase ether to temco token conversion rate
     */
    uint public conversionRate;
    
    /**
     * @dev Lock up duration for current sale
     */
    uint private lockUpDuration;


    /**
     * @dev keep track how far payee has been gone. can be resume in case of transaction fail
     */
    uint private nextPayeeIndex;
    
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
     * @dev KYC block list
     */
    mapping (address => bool) public kycBlockedMap;
    address[] public kycBlockedMapList;
    function getKycBlockedMapList() public view returns (address[]) {
        return kycBlockedMapList;
    }
    
    /**
    * Constructor function
    * 
    * @param temcoAddress temco token address
    * @param temcoTokenContractAddress temco token contract address
    * @param etherAddress wallet to transfer amount raised
    * @param crowdStartInDays crowd sale start time. unit is days
    * @param crowdDurationInDays crowd sale duration. unit is days
    * @param minEther minimum ether to receive. unit is 0.1 ether
    * @param fundingGoal funding goal for crowd sale
    * @param rate conversion rate from ether to temco coin
    * @param lockUp lock up duration for current sale. unit is days
    */
    function CrowdSale(
        address temcoAddress,
        address temcoTokenContractAddress,
        address etherAddress,
        uint crowdStartInDays,
        uint crowdDurationInDays,
        uint minEther,
        uint fundingGoal,
        uint rate,
        uint lockUp
    ) public {
        temcoTokenAddress = temcoAddress;
        temcoTokenContract = TemcoToken(temcoTokenContractAddress);
        temcoEtherAddress = etherAddress;
        
        crowdStartTime = now + crowdStartInDays * 1 days;
        crowdEndTime = crowdStartTime + crowdDurationInDays * 1 days;
        
        minimumEther = minEther * 0.1 ether;
        goal = fundingGoal;
        conversionRate = rate;
        
        lockUpDuration = now + lockUp * 1 days;
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
    function () payable public onlyWhileOpen minimumEtherRequired {
        require(msg.sender != address(0x0));
        require(msg.sender != address(this));
        uint amount = msg.value;
        
        amountRaised = amountRaised.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        balanceList.push(msg.sender);
        
        emit Received(msg.sender, amount); 
		
    }
    
    /**
     * @dev Add kyc block address
     * @param blockAddress address to be added to block list
     */
    function addBockList(address blockAddress) external onlyOwner {
        require(blockAddress != address(0x0));
        require(blockAddress != address(this));
        kycBlockedMap[blockAddress] = true;
        kycBlockedMapList.push(blockAddress);
    }
    
    /**
     * @dev Remove kyc block address
     * @param blockAddress address to be removed from block list
     */
    function removeBockList(address blockAddress) external onlyOwner {
        require(blockAddress != address(0x0));
        delete kycBlockedMap[blockAddress];
        for (uint index = 0; index < kycBlockedMapList.length ; index++){
            if(kycBlockedMapList[index] == blockAddress){
                kycBlockedMapList[index] = address(0x0);
            }        
        }
    }
    
    /**
     * @dev Send token to investors. can be resumed in case of transactio fail. 
     *      nextPayeeIndex keeps track of how far gone.
     */
    function distributeCoin() external crowdSaleClosed onlyOwner{
        uint index = nextPayeeIndex;
        for (index = 0; index < balanceList.length ; index++){
            if(kycBlockedMap[balanceList[index]] != true){
                require(balances[balanceList[index]] > 0);
                require(gasleft() > GAS_LIMIT);                
                temcoTokenContract.transferFromWithLockup(temcoTokenAddress, balanceList[index], balances[balanceList[index]].mul(conversionRate), lockUpDuration);
                balances[balanceList[index]] = balances[balanceList[index]].sub(balances[balanceList[index]]);
                
                emit TransferCoinToInvestor(temcoTokenAddress, balances[balanceList[index]].mul(conversionRate));
            }
            nextPayeeIndex = index;
        }
    }
    
    /**
     * @dev Send amount raised ether to wallet
     */
    function withdrawal() external crowdSaleClosed onlyOwner{
        require(amountRaised > 0);
        temcoEtherAddress.transfer(amountRaised);
    }
    
    /**
     * @dev In case of goal is changed after contract deployed.
     * @param amount sale goal. unit is 0.1 ether
     */
    function updateGoal(uint amount) external onlyOwner{
        require(amount > 0);
        goal = amount * 0.1 ether;
    }
    
    /**
     * @dev In case of conversion is changed after contract deployed.
     * @param rate conversion rate
     */
    function updateConversionRate(uint rate) external onlyOwner{
        require(rate > 0);
        conversionRate = rate;
    }

    /**
     * @dev Stop crowd sale in case of emergency
     */
    function stopCrowdSale() external onlyOwner{        
        crowdEndTime = now;
    }
    
}
