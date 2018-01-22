import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/mocks/BasicTokenMock.sol";

contract TestTokenManagement {
  using SafeMath for uint256;

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

}
