pragma solidity ^0.4.4;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/mocks/BasicTokenMock.sol";

contract TestEmployee {
  using SafeMath for uint256;

  address constant employeeTestAddress1 = 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef;
  uint256 constant yearlyUSDSalaryCentsTest1 = 120000;
  address[] allowedTokensTest1 = [0x2932b7A2355D6fecc4b5c0B6BD44cC31df247a2e];

  function testAddEmployee() public{
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
