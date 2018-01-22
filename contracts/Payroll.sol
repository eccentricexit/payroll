pragma solidity ^0.4.4;

import './interfaces/PayrollInterface.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/token/SafeERC20.sol';


contract Payroll is PayrollInterface, Pausable{
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  address oracle;
  mapping(address=>uint) addressToEmployeeId;
  mapping(uint=>address) employeeIdToAddress;
  mapping(uint=>Employee) employeeIdToEmployee;

  uint256 lastEmployeeId;
  uint256 employeeCount;
  uint256 salariesSummationUSD;

  Token[] tokensHandled;
  mapping(address=>uint) addressToTokenId;
  mapping(uint=>address) tokenIdToAddress;

  uint8 constant TWELVE_MONTHS = 12;

  struct Employee{
    address accountAddress;
    address[] allowedTokens;
    uint256 yearlyUSDSalary;
  }

  struct Token{
    address tokenAddress;
    uint256 usdRate;
  }

  function addFunds() payable public whenNotPaused{}

  function addEmployee(
    address _accountAddress,
    address[] _allowedTokens,
    uint256 _initialYearlyUSDSalary) public
    whenNotPaused
    onlyOwner
    employeeNotExists(_accountAddress)
    {

    Employee memory employee = Employee({
      accountAddress:_accountAddress,
      allowedTokens:_allowedTokens,
      yearlyUSDSalary:0
    });

    lastEmployeeId++;
    employeeCount++;
    uint256 employeeId = lastEmployeeId;

    addressToEmployeeId[_accountAddress] = employeeId;
    employeeIdToAddress[employeeId] = _accountAddress;
    employeeIdToEmployee[employeeId] = employee;

    setEmployeeSalary(employeeId,_initialYearlyUSDSalary);
  }

  function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary) public
    whenNotPaused
    onlyOwner
    employeeExists(employeeId)
    {
    Employee storage employee = employeeIdToEmployee[employeeId];
    salariesSummationUSD = salariesSummationUSD.sub(employee.yearlyUSDSalary);
    employee.yearlyUSDSalary = yearlyUSDSalary;
    salariesSummationUSD = salariesSummationUSD.add(employee.yearlyUSDSalary);
  }

  function removeEmployee(uint256 employeeId) public
    whenNotPaused
    onlyOwner
    employeeExists(employeeId){
    Employee memory employee = employeeIdToEmployee[employeeId];
    setEmployeeSalary(employeeId,0);

    employeeCount--;
    addressToEmployeeId[employee.accountAddress] = 0;
    employeeIdToAddress[employeeId] = 0;

    address[] memory emptyArr;
    Employee memory emptyStruct = Employee(0,emptyArr,0);
    employeeIdToEmployee[employeeId] = emptyStruct;
  }

  function addToken(address tokenAddress,uint256 usdRate) onlyOwner whenNotPaused tokenNotHandled(tokenAddress){
    Token memory token = Token(tokenAddress,usdRate);
    tokensHandled.push(token);

    uint256 tokenId = tokensHandled.length.sub(1);
    addressToTokenId[tokenAddress] = tokenId;
    tokenIdToAddress[tokenId] = tokenAddress;
  }

  function removeToken(address tokenAddress) onlyOwner whenNotPaused tokenHandled(tokenAddress){
    uint256 tokenId = addressToTokenId[tokenAddress];
    if(tokensHandled.length==1){
      delete tokensHandled[tokenId];
      tokenIdToAddress[tokenId] = 0;
    }else{
      //overwrite with last element so we don't leave a gap.
      uint256 lastItemId = tokensHandled.length-1;
      address lastItemAddress = tokenIdToAddress[lastItemId];

      tokensHandled[tokenId].tokenAddress = lastItemAddress;
      tokensHandled[tokenId].usdRate = tokensHandled[lastItemId].usdRate;

      addressToTokenId[lastItemAddress] = tokenId;
      tokenIdToAddress[lastItemId] = 0;

      delete tokensHandled[lastItemId];
    }
    addressToTokenId[tokenAddress] = 0;
  }

  function setOracle(address oracleAddress) onlyOwner whenNotPaused{
    oracle = oracleAddress;
  }

  function setExchangeRate(address token,uint256 usdExchangeRate) public whenNotPaused onlyOracle tokenHandled(token){
    uint256 tokenId = addressToTokenId[token];
    tokensHandled[tokenId].usdRate = usdExchangeRate;
  }

  function escapeHatch() public onlyOwner whenNotPaused{
    pause();
    if(this.balance>0){
      msg.sender.transfer(this.balance);
    }

    for(uint256 i=0;i<tokensHandled.length;i++){
      ERC20Basic token = ERC20Basic(tokensHandled[i].tokenAddress);
      if(token.balanceOf(this)>0){
        token.safeTransfer(msg.sender,token.balanceOf(this));
      }
    }
  }

  function calculatePayrollBurnrate() view public returns (uint256){
    return salariesSummationUSD.div(TWELVE_MONTHS);
  }

  // public getters
  function getEmployeeId(address employeeAddress) view public returns (uint256){
    return addressToEmployeeId[employeeAddress];
  }

  function getEmployeeCount() view public returns (uint256){
    return employeeCount;
  }

  function getEmployee(uint256 employeeId) view public returns (address,address[],uint256) {
    Employee memory employee = employeeIdToEmployee[employeeId];
    return (employee.accountAddress,employee.allowedTokens,employee.yearlyUSDSalary);
  }

  function getSalariesSummationUSD() view public returns (uint256){
    return salariesSummationUSD;
  }

  function getToken(address tokenAddress) view public /*tokenHandled(tokenAddress)*/ returns (address,uint256) {
    uint256 tokenId = addressToTokenId[tokenAddress];
    Token memory token = tokensHandled[tokenId];
    return (token.tokenAddress,token.usdRate);
  }

  function isTokenHandled(address tokenAddress) view public returns(bool){
    uint256 tokenId = addressToTokenId[tokenAddress];
    if(tokensHandled.length==0){
      return false;
    }

    Token memory token = tokensHandled[tokenId];
    if(token.tokenAddress==tokenAddress){
      return true;
    }else{
      return false;
    }

  }

  // modifiers
  modifier employeeExists(uint256 employeeId){
    Employee storage employee = employeeIdToEmployee[employeeId];
    if(employee.accountAddress==0){
       revert();
    }
    _;
  }

  modifier employeeNotExists(address employeeAddress){
    uint256 employeeId = addressToEmployeeId[employeeAddress];
    if(employeeId!=0){ //employee id will always be >= 1
       revert();
    }
    _;
  }

  modifier onlyOracle(){
    require(msg.sender == oracle);
    _;
  }

  modifier tokenNotHandled(address tokenAddress){
    if(tokensHandled.length!=0){
      uint256 tokenId = addressToTokenId[tokenAddress];
      Token memory token = tokensHandled[tokenId];
      require(token.tokenAddress!=tokenAddress);
    }
    _;
  }

  modifier tokenHandled(address tokenAddress){
    require(tokensHandled.length>0);
    require(isTokenHandled(tokenAddress));
    _;
  }


  /* OWNER ONLY */
  //function addEmployee(address accountAddress, address[] allowedTokens, uint256 initialYearlyUSDSalary) public {}
  //function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary) public {}
  //function removeEmployee(uint256 employeeId) public {}

  //function addFunds() payable public{}
  //function escapeHatch() public {}
  //function addTokenFunds()? // Use approveAndCall or ERC223 tokenFallback

  //function getEmployeeCount() constant public returns (uint256){}
  //function getEmployee(uint256 employeeId) constant public returns (address employee){} // Return all important info too

  //function calculatePayrollBurnrate() constant public returns (uint256){} // Monthly usd amount spent in salaries
  function calculatePayrollRunway() view public returns (uint256){} // Days until the contract can run out of funds

  /* EMPLOYEE ONLY */
  function determineAllocation(address[] tokens, uint256[] distribution) public {} // only callable once every 6 months
  function payday() public {} // only callable once a month

  /* ORACLE ONLY */
  // function setExchangeRate(address token, uint256 usdExchangeRate) public {} // uses decimals from token

}
