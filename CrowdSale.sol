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
    event Received(Phase phase, address invester, uint256 value);
    
    /**
     * Enum for current Phase
     */
    enum Phase { PHASE1, PHASE2, PHASE3, CROWDSALE_ENDED }
    Phase public currentPhase;
    
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
    uint public phase1Deadline;
    uint public phase2Deadline;
    uint public phase3Deadline;
    
    /**
     * Mininum ether acceptance for invest
     */
    uint public minimumEther = 0.1 * 1 ether;
    
    /**
     * Phase ether goal
     */
    uint public phase1Goal = 1 * 1 ether;
    uint public phase2Goal = 2 * 1 ether;
    uint public phase3Goal = 3 * 1 ether;
    
    /**
     * Phase ether to temco token conversion rate
     */
    uint public phase1ConversionRate = 217392;
    uint public phase2ConversionRate = 171429;
    uint public phase3ConversionRate = 152542;
    
    /**
     * Hold who and how much invest on phase
     */
    mapping (address => uint256) public balanceOfPhase1;
    function getBalanceOfPhase1(address index) public constant returns (uint256) {
        return balanceOfPhase1[index];
    }
    /**
     * No iteration for the mapping. Hold invester address to use iterate over maping
     */
    address[] public balanceOfPhase1List;
    function getBalanceOfPhase1List() public constant returns (address[]) {
        return balanceOfPhase1List;
    }
    
    mapping (address => uint256) public balanceOfPhase2;
    function getBalanceOfPhase2(address index) public constant returns (uint256) {
        return balanceOfPhase2[index];
    }
    address[] public balanceOfPhase2List;
    function getBalanceOfPhase2List() public constant returns (address[]) {
        return balanceOfPhase2List;
    }
    
    mapping (address => uint256) public balanceOfPhase3;
    function getBalanceOfPhase3(address index) public constant returns (uint256) {
        return balanceOfPhase3[index];
    }
    address[] public balanceOfPhase3List;
    function getBalanceOfPhase3List() public constant returns (address[]) {
        return balanceOfPhase3List;
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
    * @param croudStartInMinutes crowd sale start time
    * @param phase1durationInMinutes phase 1 duration
    * @param phase2durationInMinutes phase 2 duration
    * @param phase3durationInMinutes phase 3 duration
    *
    */
    function CrowdSale(
        address temcoAddress,
        address temcoTokenContractAddress,
        address etherAddress,
        uint croudStartInMinutes,
        uint phase1durationInMinutes,
        uint phase2durationInMinutes,
        uint phase3durationInMinutes
    ) public {
        temcoTokenAddress = temcoAddress;
        temcoTokenContract = TemcoToken(temcoTokenContractAddress);
        temcoEtherAddress = etherAddress;
        //TODO: change to date
        crowdStartTime = now + croudStartInMinutes * 1 minutes;
        phase1Deadline = crowdStartTime + phase1durationInMinutes * 1 minutes;
        phase2Deadline = phase1Deadline + phase2durationInMinutes * 1 minutes;
        phase3Deadline = phase2Deadline + phase3durationInMinutes * 1 minutes;
    }
    
    /**
   * @dev Reverts if not in crowdsale time range. 
   */
   modifier onlyWhileOpen {
    require(now >= crowdStartTime && (currentPhase != Phase.CROWDSALE_ENDED));
    _;
   }
   
   /**
   * @dev Reverts if in crowdsale time range. 
   */
   modifier crowdSaleClosed{
    require(now > phase3Deadline || (currentPhase == Phase.CROWDSALE_ENDED));
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
        currentPhase = getCurrentPhase();
        
        emit Received(currentPhase, msg.sender, amount); 
		if(currentPhase == Phase.PHASE1) {
		    balanceOfPhase1[msg.sender] = balanceOfPhase1[msg.sender].add(amount);
            balanceOfPhase1List.push(msg.sender);
            amountRaised += amount;
            currentPhase = getCurrentPhase(); // update phase status after amount raised
		}else if(currentPhase == Phase.PHASE2) {
		    balanceOfPhase2[msg.sender] = balanceOfPhase2[msg.sender].add(amount);
            balanceOfPhase2List.push(msg.sender);
            amountRaised += amount;
            currentPhase = getCurrentPhase(); // update phase status after amount raised
		}else if(currentPhase == Phase.PHASE3) {
		    balanceOfPhase3[msg.sender] = balanceOfPhase3[msg.sender].add(amount);
            balanceOfPhase3List.push(msg.sender);
            amountRaised += amount;
            currentPhase = getCurrentPhase(); // update phase status after amount raised
		}
    }
    
    /**
     * Get and update current phase depending on duration and goal on each phase
     */
    function getCurrentPhase() public returns(Phase){

		if (amountRaised < phase1Goal) {
			currentPhase = Phase.PHASE1;
			if (phase1Deadline < now && now <= phase2Deadline) {
				currentPhase = Phase.PHASE2;
			} else if (phase2Deadline < now && now <= phase3Deadline) {
				currentPhase = Phase.PHASE3;
			}else if (now > phase3Deadline){
			    currentPhase = Phase.CROWDSALE_ENDED;
			}
		} else if (phase1Goal <= amountRaised && amountRaised < (phase1Goal + phase2Goal)) {
			currentPhase = Phase.PHASE2;
			if (phase2Deadline < now && now <= phase3Deadline) {
				currentPhase = Phase.PHASE2;
			}else if (now > phase3Deadline){
			    currentPhase = Phase.CROWDSALE_ENDED;
			}
		} else if ((phase1Goal + phase2Goal) <= amountRaised && amountRaised < (phase1Goal + phase2Goal + phase3Goal)) {
			currentPhase = Phase.PHASE3;
			if (now > phase3Deadline){
			    currentPhase = Phase.CROWDSALE_ENDED;
			}
		} else {
			currentPhase = Phase.CROWDSALE_ENDED;
		}

		return currentPhase;
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
    function distributePhase1Coin() public crowdSaleClosed onlyOwner{
        for (uint index = 0; index < balanceOfPhase1List.length ; index++){
            if(kycBlockedMap[balanceOfPhase1List[index]] != true){
                require(balanceOfPhase1[balanceOfPhase1List[index]] > 0);
                temcoTokenContract.transferFromWithoutApproval(temcoTokenAddress, balanceOfPhase1List[index], balanceOfPhase1[balanceOfPhase1List[index]].mul(phase1ConversionRate));
                emit TransferCoinToInvester(temcoTokenAddress, balanceOfPhase1[balanceOfPhase1List[index]].mul(phase1ConversionRate));
                balanceOfPhase1[balanceOfPhase1List[index]] = balanceOfPhase1[balanceOfPhase1List[index]].sub(balanceOfPhase1[balanceOfPhase1List[index]]);
            }
        }
    }
    
    /**
     * Send token to investers
     */
    function distributePhase2Coin() public crowdSaleClosed onlyOwner{
        for (uint index = 0; index < balanceOfPhase2List.length ; index++){
            if(kycBlockedMap[balanceOfPhase2List[index]] != true){
                require(balanceOfPhase2[balanceOfPhase2List[index]] > 0);
                temcoTokenContract.transferFromWithoutApproval(temcoTokenAddress, balanceOfPhase2List[index], balanceOfPhase2[balanceOfPhase2List[index]].mul(phase2ConversionRate));
                emit TransferCoinToInvester(temcoTokenAddress, balanceOfPhase2[balanceOfPhase2List[index]].mul(phase2ConversionRate));
                balanceOfPhase2[balanceOfPhase2List[index]] = balanceOfPhase2[balanceOfPhase2List[index]].sub(balanceOfPhase2[balanceOfPhase2List[index]]);
            }
        }
    }
    
    /**
     * Send token to investers
     */
    function distributePhase3Coin() public crowdSaleClosed onlyOwner{
        for (uint index = 0; index < balanceOfPhase3List.length ; index++){
            if(kycBlockedMap[balanceOfPhase3List[index]] != true){
                require(balanceOfPhase3[balanceOfPhase3List[index]] > 0);
                temcoTokenContract.transferFromWithoutApproval(temcoTokenAddress, balanceOfPhase3List[index], balanceOfPhase3[balanceOfPhase3List[index]].mul(phase3ConversionRate));
                emit TransferCoinToInvester(temcoTokenAddress, balanceOfPhase3[balanceOfPhase3List[index]].mul(phase3ConversionRate));
                balanceOfPhase3[balanceOfPhase3List[index]] = balanceOfPhase3[balanceOfPhase3List[index]].sub(balanceOfPhase3[balanceOfPhase2List[index]]);
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
    function updatePhase1Goal(uint amount) public onlyOwner{
        phase1Goal = amount * 1 ether;
    }
    
    function updatePhase2Goal(uint amount) public onlyOwner{
        phase2Goal = amount * 1 ether;
    }
    
    function updatePhase3Goal(uint amount) public onlyOwner{
        phase3Goal = amount * 1 ether;
    }
    
    /**
     * In case of conversion is changed after contract deployed.
     */
    function updateConversionRate1(uint rate) public onlyOwner{
        phase1ConversionRate = rate;
    }
    
    function updateConversionRate2(uint rate) public onlyOwner{
        phase2ConversionRate = rate;
    }
    
    function updateConversionRate3(uint rate) public onlyOwner{
        phase3ConversionRate = rate;
    }
    
    
}
