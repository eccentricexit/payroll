pragma solidity ^0.4.4;
import 'zeppelin-solidity/contracts/token/BasicToken.sol';

// mock class using BasicToken
contract BasicTokenMock is BasicToken {

  function BasicTokenMock(address initialAccount, uint256 initialBalance) public {
    balances[initialAccount] = initialBalance;
    totalSupply = initialBalance;
  }

}
