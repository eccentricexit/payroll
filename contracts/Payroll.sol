pragma solidity ^0.4.4;

import './interfaces/PayrollInterface.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract Payroll is PayrollInterface, Ownable{

  enum State { Unlocked, Locked }

  State state;
  address public owner;
  uint256 public lastEmployeeId;
  uint256 public employeeCount;
  uint256 public salariesSummation;

  mapping(address=>uint) public addressToEmployeeId;
  mapping(uint=>address) public employeeIdToAddress;
  mapping(uint=>Employee) public employeeIdToEmployee;

  struct Employee{
    address accountAddress;
    address[] allowedTokens;
    uint256 yearlyUSDSalary;
  }

  function Payroll() public {
      owner = msg.sender;
      state = State.Unlocked;
  }

  function addEmployee(
    address _accountAddress,
    address[] _allowedTokens,
    uint256 _initialYearlyUSDSalary) public onlyOwner() employeeNotExists(_accountAddress){

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

  function getEmployeeCount() constant public returns (uint256){
    return employeeCount;
  }

  function getEmployee(uint256 employeeId) constant public returns (address,address[],uint256) {
    Employee storage e = employeeIdToEmployee[employeeId];
    return (e.accountAddress,e.allowedTokens,e.yearlyUSDSalary);
  }

  function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary) public onlyOwner() employeeExists(employeeId){
    Employee storage e = employeeIdToEmployee[employeeId];
    salariesSummation = SafeMath.sub(salariesSummation,e.yearlyUSDSalary);
    e.yearlyUSDSalary = yearlyUSDSalary;
    salariesSummation = SafeMath.add(salariesSummation,e.yearlyUSDSalary);
  }

  function removeEmployee(uint256 employeeId) public onlyOwner() employeeExists(employeeId){
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


  /* OWNER ONLY */
  //function addEmployee(address accountAddress, address[] allowedTokens, uint256 initialYearlyUSDSalary) public {}
  //function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary) public {}
  //function removeEmployee(uint256 employeeId) public {}

  function addFunds() payable public {}
  function scapeHatch() public {}
  //function addTokenFunds()? // Use approveAndCall or ERC223 tokenFallback

  //function getEmployeeCount() constant public returns (uint256){}
  //function getEmployee(uint256 employeeId) constant public returns (address employee){} // Return all important info too

  function calculatePayrollBurnrate() constant public returns (uint256){} // Monthly usd amount spent in salaries
  function calculatePayrollRunway() constant public returns (uint256){} // Days until the contract can run out of funds

  /* EMPLOYEE ONLY */
  function determineAllocation(address[] tokens, uint256[] distribution) public {} // only callable once every 6 months
  function payday() public {} // only callable once a month

  /* ORACLE ONLY */
  function setExchangeRate(address token, uint256 usdExchangeRate) public {} // uses decimals from token

}
