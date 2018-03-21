pragma solidity ^0.4.4;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/mocks/BasicTokenMock.sol";

contract TestTokenManagement {
  using SafeMath for uint256;
  address testTokenAddress = 0x0F4F2Ac550A1b4e2280d04c21cEa7EBD822934b5;
  uint256 testTokenRate = 12;

  function testAddToken() public{
    Payroll payroll = new Payroll();

    Assert.equal(payroll.isTokenHandled(testTokenAddress),false,'token should not yet be registered');
    payroll.addToken(testTokenAddress,testTokenRate);

    var (tokenAddressAfterAdd,tokenUsdRateAfterAdd) = payroll.getToken(testTokenAddress);
    Assert.equal(tokenAddressAfterAdd,testTokenAddress,'there should be a token address');
    Assert.equal(tokenUsdRateAfterAdd,testTokenRate,'there should be a token rate');
    Assert.equal(payroll.isTokenHandled(testTokenAddress),true,'token should be registered');
  }

  function testRemoveToken() public{
    Payroll payroll = new Payroll();
    payroll.addToken(testTokenAddress,testTokenRate);
    var (tokenAddressAfterAdd,tokenUsdRateAfterAdd) = payroll.getToken(testTokenAddress);

    Assert.equal(tokenAddressAfterAdd,testTokenAddress,'there should be a token address');
    Assert.equal(tokenUsdRateAfterAdd,testTokenRate,'there should be a token rate');
    Assert.equal(payroll.isTokenHandled(testTokenAddress),true,'token should be registered');

    payroll.removeToken(testTokenAddress);
    Assert.equal(payroll.isTokenHandled(testTokenAddress),false,'token should have been removed');
  }

}
