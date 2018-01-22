import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/mocks/BasicTokenMock.sol";

contract TestPayroll {
  using SafeMath for uint256;

  address constant employeeTestAddress1 = 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef;
  uint256 constant yearlyUSDSalaryCentsTest1 = 120000;
  address[] allowedTokensTest1 = [0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e];

  address constant employeeTestAddress2 = 0x6330a553fc93768f612722bb8c2ec78ac90b3bbc;
  uint256 constant yearlyUSDSalaryCentsTest2 = 120000;
  address[] allowedTokensTest2 = [0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef];
  uint8 constant TWELVE_MONTHS = 12;

  function testAddEmployees() {
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

  function testCalculatePayrollBurnrate(){
    Payroll payroll = new Payroll();
    payroll.addEmployee(employeeTestAddress1,allowedTokensTest1,yearlyUSDSalaryCentsTest1);
    payroll.addEmployee(employeeTestAddress2,allowedTokensTest2,yearlyUSDSalaryCentsTest2);

    uint256 payrollBurnRateTest = payroll.calculatePayrollBurnrate();
    uint256 payrollBurnRate = payroll.getSalariesSummationUSD().div(TWELVE_MONTHS);
    Assert.equal(payrollBurnRateTest,payrollBurnRate,'should return payrollrate');
  }

  function testEscapeHatchPausesContract(){
    Payroll payroll = new Payroll();
    Assert.equal(payroll.paused(),false,'contract should not be paused');

    payroll.escapeHatch();

    Assert.equal(payroll.paused(),true,'contract should be paused');
  }

  function testAddToken(){
    address testTokenAddress = 0x0f4f2ac550a1b4e2280d04c21cea7ebd822934b5;
    uint256 testTokenRate = 12;
    Payroll payroll = new Payroll();

    Assert.equal(payroll.isTokenHandled(testTokenAddress),false,'token should not yet be registered');
    payroll.addToken(testTokenAddress,testTokenRate);

    var (tokenAddressAfterAdd,tokenUsdRateAfterAdd) = payroll.getToken(testTokenAddress);
    Assert.equal(tokenAddressAfterAdd,testTokenAddress,'there should be a token address');
    Assert.equal(tokenUsdRateAfterAdd,testTokenRate,'there should be a token rate');
    Assert.equal(payroll.isTokenHandled(testTokenAddress),true,'token should be registered');
  }

  function testRemoveToken(){
    address testTokenAddress = 0x0f4f2ac550a1b4e2280d04c21cea7ebd822934b5;
    uint256 testTokenRate = 12;
    Payroll payroll = new Payroll();
    payroll.addToken(testTokenAddress,testTokenRate);

    var (tokenAddressAfterAdd,tokenUsdRateAfterAdd) = payroll.getToken(testTokenAddress);
    Assert.equal(tokenAddressAfterAdd,testTokenAddress,'there should be a token address');
    Assert.equal(tokenUsdRateAfterAdd,testTokenRate,'there should be a token rate');
    Assert.equal(payroll.isTokenHandled(testTokenAddress),true,'token should be registered');

    payroll.removeToken(testTokenAddress);

    var (tokenAddressAfterRemove,tokenUsdRateAfterRemove) = payroll.getToken(testTokenAddress);
    Assert.equal(tokenAddressAfterRemove,0,'there should be no token address');
    Assert.equal(tokenUsdRateAfterRemove,0,'there should no token rate');
    Assert.equal(payroll.isTokenHandled(testTokenAddress),false,'token should have been removed');
  }

  function testRescueTokensOnEscape(){
    uint256 initialSupply = 2000000;
    Payroll payroll = new Payroll();
    BasicTokenMock testToken = new BasicTokenMock(this,initialSupply);

    Assert.equal(testToken.balanceOf(this),testToken.totalSupply(),'owner should own all tokens');

    uint256 testAmount = 20000;
    if(testToken.balanceOf(this)>0){
      testToken.transfer(payroll,testAmount);
    }
    Assert.equal(testToken.balanceOf(payroll),testAmount,'payroll should own test tokens');

    payroll.addToken(testToken,10);
    Assert.equal(payroll.isTokenHandled(testToken),true,'token should be handled');

    payroll.escapeHatch();
    Assert.equal(testToken.balanceOf(payroll),0,'payroll should not own test tokens');
  }



}
