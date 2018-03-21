pragma solidity ^0.4.4;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/mocks/BasicTokenMock.sol";

contract TestMathFunctions {
  using SafeMath for uint256;

  uint8 constant TWELVE_MONTHS = 12;
  address constant employeeTestAddress1 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;
  uint256 constant yearlyUSDSalaryCentsTest1 = 120000;
  address[] allowedTokensTest1 = [0x2932b7A2355D6fecc4b5c0B6BD44cC31df247a2e];

  address constant employeeTestAddress2 = 0x6330A553Fc93768F612722BB8c2eC78aC90B3bbc;
  uint256 constant yearlyUSDSalaryCentsTest2 = 120000;
  address[] allowedTokensTest2 = [0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef];

  function testCalculatePayrollBurnrate() public{
    Payroll payroll = new Payroll();
    payroll.addToken(allowedTokensTest1[0],100);
    payroll.addToken(allowedTokensTest2[0],100);

    payroll.addEmployee(employeeTestAddress1,allowedTokensTest1,yearlyUSDSalaryCentsTest1);
    payroll.addEmployee(employeeTestAddress2,allowedTokensTest2,yearlyUSDSalaryCentsTest2);

    uint256 payrollBurnRateTest = payroll.calculatePayrollBurnrate();
    uint256 payrollBurnRate = payroll.getSalariesSummationUSD().div(TWELVE_MONTHS);
    Assert.equal(payrollBurnRateTest,payrollBurnRate,'should return payrollrate');
  }

}
