import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/mocks/BasicTokenMock.sol";

contract TestMathFunctions {
  using SafeMath for uint256;

  uint8 constant TWELVE_MONTHS = 12;
  address constant employeeTestAddress1 = 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef;
  uint256 constant yearlyUSDSalaryCentsTest1 = 120000;
  address[] allowedTokensTest1 = [0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e];

  address constant employeeTestAddress2 = 0x6330a553fc93768f612722bb8c2ec78ac90b3bbc;
  uint256 constant yearlyUSDSalaryCentsTest2 = 120000;
  address[] allowedTokensTest2 = [0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef];

  function testCalculatePayrollBurnrate(){
    Payroll payroll = new Payroll();
    payroll.addEmployee(employeeTestAddress1,allowedTokensTest1,yearlyUSDSalaryCentsTest1);
    payroll.addEmployee(employeeTestAddress2,allowedTokensTest2,yearlyUSDSalaryCentsTest2);

    uint256 payrollBurnRateTest = payroll.calculatePayrollBurnrate();
    uint256 payrollBurnRate = payroll.getSalariesSummationUSD().div(TWELVE_MONTHS);
    Assert.equal(payrollBurnRateTest,payrollBurnRate,'should return payrollrate');
  }

}
