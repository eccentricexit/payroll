import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/mocks/BasicTokenMock.sol";

contract TestEmployee {
  using SafeMath for uint256;

  address constant employeeTestAddress1 = 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef;
  uint256 constant yearlyUSDSalaryCentsTest1 = 120000;
  address[] allowedTokensTest1 = [0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e];

  function testAddEmployee() {
    Payroll payroll = new Payroll();

    uint256 employeeCountBefore = payroll.getEmployeeCount();
    uint256 salariesSummationBefore = payroll.getSalariesSummationUSD();

    payroll.addEmployee(employeeTestAddress1,allowedTokensTest1,yearlyUSDSalaryCentsTest1);

    uint256 employeeCountAfter = payroll.getEmployeeCount();
    Assert.equal(employeeCountAfter,employeeCountBefore+1,'employee count should be 1');

    uint256 salariesSummationAfter = payroll.getSalariesSummationUSD();
    Assert.equal(salariesSummationAfter,salariesSummationBefore+yearlyUSDSalaryCentsTest1,'salaries summation should be non zero');

    uint256 employeeId = payroll.getEmployeeId(employeeTestAddress1);
    var (accountAddress,allowedTokens,yearlyUSDSalaryCents) = payroll.getEmployee(employeeId);

    Assert.equal(accountAddress,employeeTestAddress1,'addresses should be equal');
    Assert.equal(yearlyUSDSalaryCents,yearlyUSDSalaryCentsTest1,'salary should be equal');
  }

  function testRemoveEmployee(){
    Payroll payroll = new Payroll();
    payroll.addEmployee(employeeTestAddress1,allowedTokensTest1,yearlyUSDSalaryCentsTest1);

    uint256 employeeCountBefore = payroll.getEmployeeCount();
    uint256 salariesSummationBefore = payroll.getSalariesSummationUSD();

    uint256 employeeId = payroll.getEmployeeId(employeeTestAddress1);
    var (accountAddress,allowedTokens,yearlyUSDSalaryCents) = payroll.getEmployee(employeeId);

    payroll.removeEmployee(employeeId);
    uint256 employeeCountAfter = payroll.getEmployeeCount();
    uint256 salariesSummationAfter = payroll.getSalariesSummationUSD();

    Assert.equal(employeeCountAfter,employeeCountBefore-1,'addresses should be equal.');
    Assert.equal(salariesSummationAfter,salariesSummationBefore-yearlyUSDSalaryCents,'salary should be equal.');
  }



}
