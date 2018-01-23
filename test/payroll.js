var BigNumber = require('bignumber.js');
var Payroll = artifacts.require("Payroll");
var BasicTokenMock = artifacts.require('./mock/BasicTokenMock.sol');

contract('Payroll', function(accounts) {
  let contractInstance;

  beforeEach(async function(){
    contractInstance = await Payroll.new();
  });

  it("rescues ether on escape",async function() {
    let contractBalance = await web3.eth.getBalance(contractInstance.address).toNumber();
    assert.equal(contractBalance,0,'initial contract balance should be 0');

    // Funding contract
    const amountInWei = web3.toWei(5,"ether");
    const ownerAddress = accounts[0];
    const contractAddress = contractInstance.address;
    await contractInstance.addFunds({from:ownerAddress,to: contractAddress,value: amountInWei});
    contractBalance = await web3.eth.getBalance(contractInstance.address).toNumber();
    assert.equal(contractBalance,amountInWei,'contract balance should be '+amountInWei);

    // Escaping
    await contractInstance.escapeHatch();

    contractBalance = await web3.eth.getBalance(contractInstance.address).toNumber();
    assert.equal(contractBalance,0,'contract balance should be 0');
  });

  it("sets eth exchange rate correctly",async function(){
    const amountInWei = web3.toWei(1,"ether");
    const ownerAddress = accounts[0];
    const oracleAddress = accounts[1];
    const exchangeRate = 100; // In cents. 1 usd == 1 eth
    const contractAddress = contractInstance.address;

    await contractInstance.addFunds({from:ownerAddress,to: contractAddress,value: amountInWei});
    await contractInstance.setOracle(oracleAddress);
    await contractInstance.setEthExchangeRate(exchangeRate,{from:oracleAddress}); //1 eth == 1 usd
    const ethExchangeRate = await contractInstance.getEthExchangeRateCents();

    assert.equal(ethExchangeRate,exchangeRate,'exchange rate should be '+exchangeRate);

  });

  it("calculates total usd balance correctly",async function(){
    const amountInWei = web3.toWei(2,"ether");
    const ownerAddress = accounts[0];
    const oracleAddress = accounts[1];
    const exchangeRate = 100; // In cents. 1 usd == 1 eth
    const contractAddress = contractInstance.address;

    await contractInstance.addFunds({from:ownerAddress,to: contractAddress,value: amountInWei});
    await contractInstance.setOracle(oracleAddress);
    await contractInstance.setEthExchangeRate(exchangeRate,{from:oracleAddress}); //1 eth == 1 usd
    let obj = await contractInstance.totalBalanceInUSDCents();
    let decimalPlaces = new BigNumber(10).pow(obj[1]);

    let totalBalanceInUSDCents = obj[0].div(decimalPlaces).toNumber();
    assert.equal(totalBalanceInUSDCents,200,'balance should be 200 cents');

    //TODO Add tokens
    let tokenContractInstance = await BasicTokenMock.new(ownerAddress,5000);

    await contractInstance.addToken(tokenContractInstance.address,100);
    assert.equal(await contractInstance.isTokenHandled(tokenContractInstance.address),true,'token should be handled');

    const tokensToPayroll = 1;
    await tokenContractInstance.transfer(contractInstance.address,tokensToPayroll);
    const contractTokenBalance = await tokenContractInstance.balanceOf(contractInstance.address);
    assert.equal(contractTokenBalance,tokensToPayroll,'contract should own some tokens');

    obj = await contractInstance.totalBalanceInUSDCents();
    decimalPlaces = new BigNumber(10).pow(obj[1]);

    totalBalanceInUSDCents = obj[0].div(decimalPlaces).toNumber();
    assert.equal(totalBalanceInUSDCents,300,'balance should be 300 cents');
  });

  it("calculates payroll runway correctly", async function(){
    // TODO

  });

});
