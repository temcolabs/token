pragma solidity ^0.4.21;

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
    event Refund(address claimAddress, uint256 refundAmount);    
    
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
     * @dev KYC whitelist
     */
    mapping (address => bool) public whitelistMap;
    address[] public whitelist;
    function getWhitelist() public view returns (address[]) {
        return whitelist;
    }

    /**
     * @dev List who recieved token.    
     */
    address[] public constributedList;
    function getConstributedList() public view returns (address[]) {
        return constributedList;
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
    */
    function CrowdSale(
        address temcoAddress,
        address temcoTokenContractAddress,
        address etherAddress,
        uint crowdStartInDays,
        uint crowdDurationInDays,
        uint minEther,
        uint fundingGoal,
        uint rate        
    ) public {
        temcoTokenAddress = temcoAddress;
        temcoTokenContract = TemcoToken(temcoTokenContractAddress);
        temcoEtherAddress = etherAddress;
        
        crowdStartTime = now + crowdStartInDays * 1 days;
        crowdEndTime = crowdStartTime + crowdDurationInDays * 1 days;
        
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
    * @dev Reverts if not in whiltelist
    */
    modifier onlyInWhiltelist{
        require(whitelistMap[ msg.sender] == true);    
        _;
    }
    
    /**
    * Fallback function
    *
    * The function without name is the default function that is called whenever anyone sends funds to a contract
    */
    function () payable public onlyWhileOpen onlyInWhiltelist minimumEtherRequired {
        require(msg.sender != address(0));
        require(msg.sender != address(this));
        uint amount = msg.value;
        
        amountRaised = amountRaised.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        balanceList.push(msg.sender);
        if(amountRaised >= goal){
            crowdEndTime = now - 1 minutes;
        }

        // Transfer raised ether right a way to wallet. This will avoid any loss of funds in cased of faliure.
        temcoEtherAddress.transfer(amount);
        
        emit Received(msg.sender, amount); 
		
    }
    
    /**
     * @dev Add kyc whitelist address
     * @param whitelistAddress address to be added to whiltelist
     */
    function addWhiltelist(address _whitelistAddress) public onlyOwner {
        require(_whitelistAddress != address(0));
        require(_whitelistAddress != address(this));
        whitelistMap[_whitelistAddress] = true;
        whitelist.push(_whitelistAddress);
    }

    /**
     * @dev Add many kyc whitelist address
     * @param whitelistAddressList address list to be added to whitelist
     */
    function addManyWhitelist(address[] _whitelistAddressList) external onlyOwner {
        for (uint256 i = 0; i < _whitelistAddressList.length; i++) {
            addWhiltelist(_whitelistAddressList[i]);
        }
    }
    
    /**
     * @dev Remove kyc whiltelist address
     * @param whitelistAddress address to be removed from whitelist
     */
    function removeEachWhiteList(address _whitelistAddress) public onlyOwner {
        require(_whitelistAddress != address(0));
        delete whitelistMap[_whitelistAddress];
        for (uint index = 0; index < whitelist.length ; index++){
            if(whitelist[index] == _whitelistAddress){
                whitelist[index] = address(0);
            }        
        }
    }

    /**
     * @dev remove many kyc whiltelist address
     * @param whitelistAddressList address list to be removed from whiltelist
     */
    function removeManyWhiltelist(address[] _whitelistAddressList) external onlyOwner {
        for (uint256 i = 0; i < _whitelistAddressList.length; i++) {
            removeEachWhiteList(_whitelistAddressList[i]);
        }
    }
    
    /**
     * @dev Send token to investors. can be resumed in case of transactio fail. 
     *      nextPayeeIndex keeps track of how far gone.
     */
    function distributeCoins(uint startIndex, uint endIndex) external crowdSaleClosed onlyOwner{        
        for (uint index = startIndex; index < endIndex ; index++){
            if(whitelistMap[balanceList[index]] != true && balances[balanceList[index]] > 0){                                
                distribute(balanceList[index]);                
            }            
        }
    }

    function distributeCoin(address _claimAddress) external crowdSaleClosed onlyOwner{            
        distribute(_claimAddress);        
    }

    function distribute(address _claimAddress) internal crowdSaleClosed onlyOwner{    
        require(_claimAddress != address(0));    
        require(whitelistMap[_claimAddress] == true);    
        require(balances[_claimAddress] >= minimumEther);            
        temcoTokenContract.mint(_claimAddress, balances[_claimAddress].mul(conversionRate));
        balances[_claimAddress] = balances[_claimAddress].sub(balances[_claimAddress]);
        constributedList.push(_claimAddress);        
        emit TransferCoinToInvestor(temcoTokenAddress, balances[_claimAddress].mul(conversionRate));                
    }
    

    /**
     * @dev Refund amount raised ether
     */
    function refund(address _claimAddress, uint refundAmount) external onlyOwner{
        require(_claimAddress != address(0));    
        require(whitelistMap[_claimAddress] == true);    
        require(balances[_claimAddress] >= 0);
        _claimAddress.transfer(refundAmount);
        emit Refund(_claimAddress, refundAmount);
    }    

    /**
     * @dev Stop crowd sale in case of emergency
     */
    function stopCrowdSale() external onlyOwner{        
        crowdEndTime = now;
    }
    
}
