pragma solidity ^0.4.4;

// For the sake of simplicity lets assume USD is a ERC20 token
// Also lets assume we can 100% trust the exchange rate oracle
contract PayrollInterface {
  /* OWNER ONLY */
  function addEmployee(address accountAddress, address[] allowedTokens, uint256 initialYearlyUSDSalary) public;
  function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary) public;
  function removeEmployee(uint256 employeeId) public;

  function addFunds() payable public;
  function scapeHatch() public;
  // function addTokenFunds()? // Use approveAndCall or ERC223 tokenFallback

  function getEmployeeCount() constant public returns (uint256);
  function getEmployee(uint256 employeeId) constant public returns (address, address[],uint256); // Return all important info too. Could be changed to return struct directly, but web3 doesn't support it yet. https://github.com/ethereum/web3.js/issues/1241

  function calculatePayrollBurnrate() constant public returns (uint256); // Monthly usd amount spent in salaries
  function calculatePayrollRunway() constant public returns (uint256); // Days until the contract can run out of funds

  /* EMPLOYEE ONLY */
  function determineAllocation(address[] tokens, uint256[] distribution) public; // only callable once every 6 months
  function payday() public; // only callable once a month

  /* ORACLE ONLY */
  function setExchangeRate(address token, uint256 usdExchangeRate) public; // uses decimals from token
}
