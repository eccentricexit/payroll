pragma solidity ^0.4.4;

import './interfaces/PayrollInterface.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract Payroll is PayrollInterface, Pausable{
  using SafeMath for uint256;

  address oracle;
  mapping(address=>uint) addressToEmployeeId;
  mapping(uint=>address) employeeIdToAddress;
  mapping(uint=>Employee) employeeIdToEmployee;

  uint256 lastEmployeeId;
  uint256 employeeCount;
  uint256 salariesSummationUSD;



  uint8 constant TWELVE_MONTHS = 12;

  struct Employee{
    address accountAddress;
    address[] allowedTokens;
    uint256 yearlyUSDSalary;
  }

  function Payroll() public {
  }

  function addEmployee(
    address _accountAddress,
    address[] _allowedTokens,
    uint256 _initialYearlyUSDSalary) public
    whenNotPaused
    onlyOwner
    employeeNotExists(_accountAddress)
    {

    Employee memory e = Employee({
      accountAddress:_accountAddress,
      allowedTokens:_allowedTokens,
      yearlyUSDSalary:0
    });

    lastEmployeeId++;
    employeeCount++;
    uint256 employeeId = lastEmployeeId;

    addressToEmployeeId[_accountAddress] = employeeId;
    employeeIdToAddress[employeeId] = _accountAddress;
    employeeIdToEmployee[employeeId] = e;

    setEmployeeSalary(employeeId,_initialYearlyUSDSalary);
  }

  function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary) public
    whenNotPaused
    onlyOwner
    employeeExists(employeeId)
    {
    Employee storage e = employeeIdToEmployee[employeeId];
    salariesSummationUSD = salariesSummationUSD.sub(e.yearlyUSDSalary);
    e.yearlyUSDSalary = yearlyUSDSalary;
    salariesSummationUSD = salariesSummationUSD.add(e.yearlyUSDSalary);
  }

  function removeEmployee(uint256 employeeId) public
    whenNotPaused
    onlyOwner
    employeeExists(employeeId){
    Employee storage e = employeeIdToEmployee[employeeId];
    setEmployeeSalary(employeeId,0);

    employeeCount--;
    addressToEmployeeId[e.accountAddress] = 0;
    employeeIdToAddress[employeeId] = 0;

    address[] memory emptyArr;
    Employee memory emptyStruct = Employee({
      accountAddress:0,
      allowedTokens:emptyArr,
      yearlyUSDSalary:0
    });
    employeeIdToEmployee[employeeId] = emptyStruct;
  }

  function scapeHatch() public onlyOwner whenNotPaused{
    owner.transfer(this.balance);
    //TODO rescue tokens
    pause();
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
    Employee storage e = employeeIdToEmployee[employeeId];
    return (e.accountAddress,e.allowedTokens,e.yearlyUSDSalary);
  }

  function getSalariesSummationUSD() view public returns (uint256){
    return salariesSummationUSD;
  }


  // modifiers
  modifier employeeExists(uint256 employeeId){
    Employee storage e = employeeIdToEmployee[employeeId];
    if(e.accountAddress==0){
       revert();
    }
    _;
  }

  modifier employeeNotExists(address employeeAddress){
    uint256 employeeId = addressToEmployeeId[employeeAddress];
    if(employeeId!=0){
       revert();
    }
    _;
  }

  modifier onlyOracle(){
    require(msg.sender == oracle);
    _;
  }


  /* OWNER ONLY */
  //function addEmployee(address accountAddress, address[] allowedTokens, uint256 initialYearlyUSDSalary) public {}
  //function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary) public {}
  //function removeEmployee(uint256 employeeId) public {}

  function addFunds() payable public {}
  //function scapeHatch() public {}
  //function addTokenFunds()? // Use approveAndCall or ERC223 tokenFallback

  //function getEmployeeCount() constant public returns (uint256){}
  //function getEmployee(uint256 employeeId) constant public returns (address employee){} // Return all important info too

  //function calculatePayrollBurnrate() constant public returns (uint256){} // Monthly usd amount spent in salaries
  function calculatePayrollRunway() view public returns (uint256){} // Days until the contract can run out of funds

  /* EMPLOYEE ONLY */
  function determineAllocation(address[] tokens, uint256[] distribution) public {} // only callable once every 6 months
  function payday() public {} // only callable once a month

  /* ORACLE ONLY */
  function setExchangeRate(address token, uint256 usdExchangeRate) public {} // uses decimals from token

}
