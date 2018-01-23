// Specifically request an abstraction for MetaCoin
var Payroll = artifacts.require("Payroll");
var BigNumber = require('bignumber.js');

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
    const obj = await contractInstance.totalBalanceInUSDCents();
    const decimalPlaces = new BigNumber(10).pow(obj[1]);

    const totalBalanceInUSDCents = obj[0].div(decimalPlaces).toNumber();
    assert.equal(totalBalanceInUSDCents,200,'balance should be 200 cents');

    //TODO Add tokens

  });

  it("calculates payroll runway correctly", async function(){
    // TODO

  });

});
