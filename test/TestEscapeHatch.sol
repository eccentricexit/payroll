pragma solidity ^0.4.4;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Payroll.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/mocks/BasicTokenMock.sol";

contract TestEscapeHatch {
  using SafeMath for uint256;

  function testEscapeHatchPausesContract() public{
    Payroll payroll = new Payroll();
    Assert.equal(payroll.paused(),false,'contract should not be paused');

    payroll.escapeHatch();

    Assert.equal(payroll.paused(),true,'contract should be paused');
  }

  function testRescueTokensOnEscape() public{
    uint256 initialSupply = 2000000;
    Payroll payroll = new Payroll();
    BasicTokenMock testToken = new BasicTokenMock(this,initialSupply);

    Assert.equal(testToken.balanceOf(this),testToken.totalSupply(),'owner should own all tokens');

    uint256 testAmount = 20000;
    uint256 testTokenRate = 12;
    if(testToken.balanceOf(this)>0){
      testToken.transfer(payroll,testAmount);
    }
    Assert.equal(testToken.balanceOf(payroll),testAmount,'payroll should own test tokens');

    payroll.addToken(testToken,testTokenRate);
    Assert.equal(payroll.isTokenHandled(testToken),true,'token should be handled');

    payroll.escapeHatch();
    Assert.equal(testToken.balanceOf(payroll),0,'payroll should not own test tokens');
  }

}
