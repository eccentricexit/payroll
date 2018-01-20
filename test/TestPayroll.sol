import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";

contract TestPayroll {

  address employeeTestAddress1 = 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef;
  address[] allowedTokensTest = [0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e];
  uint256 yearlyUSDSalaryTest = 100000;

  function testAddEmployees() {
    Payroll payroll = new Payroll();

    uint256 employeeCountBefore = payroll.getEmployeeCount();
    uint256 salariesSummationBefore = payroll.getSalariesSummation();

    payroll.addEmployee(employeeTestAddress1,allowedTokensTest,yearlyUSDSalaryTest);

    uint256 employeeCountAfter = payroll.getEmployeeCount();
    Assert.equal(employeeCountAfter,employeeCountBefore+1,'employee count should be 1');

    uint256 salariesSummationAfter = payroll.getSalariesSummation();
    Assert.equal(salariesSummationAfter,salariesSummationBefore+yearlyUSDSalaryTest,'salaries summation should be non zero');

    uint256 employeeId = payroll.addressToEmployeeId(employeeTestAddress1);
    var (accountAddress,allowedTokens,yearlyUSDSalary) = payroll.getEmployee(employeeId);

    Assert.equal(accountAddress,employeeTestAddress1,'addresses should be equal');
    Assert.equal(yearlyUSDSalary,yearlyUSDSalaryTest,'salary should be equal');
  }

  function testRemoveEmployee(){
    Payroll payroll = new Payroll();
    payroll.addEmployee(employeeTestAddress1,allowedTokensTest,yearlyUSDSalaryTest);

    uint256 employeeCountBefore = payroll.getEmployeeCount();
    uint256 salariesSummationBefore = payroll.getSalariesSummation();

    uint256 employeeId = payroll.addressToEmployeeId(employeeTestAddress1);
    var (accountAddress,allowedTokens,yearlyUSDSalary) = payroll.getEmployee(employeeId);

    payroll.removeEmployee(employeeId);
    uint256 employeeCountAfter = payroll.getEmployeeCount();
    uint256 salariesSummationAfter = payroll.getSalariesSummation();

    Assert.equal(employeeCountAfter,employeeCountBefore-1,'addresses should be equal.');
    Assert.equal(salariesSummationAfter,salariesSummationBefore-yearlyUSDSalary,'salary should be equal.');
  }

  function testLock(){
    Payroll payroll = new Payroll();
    Payroll.State state = payroll.state();
    if(state!=Payroll.State.Unlocked){Assert.fail("should be unlocked");}

    payroll.scapeHatch();
    state = payroll.state();
    if(state!=Payroll.State.Locked){Assert.fail("should be locked");}
  }

}
