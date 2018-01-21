// Specifically request an abstraction for MetaCoin
var Payroll = artifacts.require("Payroll");

contract('Payroll', function(accounts) {
  it("should rescue ether and pause on escape",async function() {
    let contractInstance = await Payroll.deployed();
    let contractBalance = await web3.eth.getBalance(contractInstance.address).toNumber();
    let isPaused = await contractInstance.paused();
    assert.equal(contractBalance,0,'initial contract balance should be 0');
    assert.equal(isPaused,false,'contract should be unpaused');

    // Funding contract
    let amountInWei = web3.toWei(5,"ether");
    let ownerAddress = accounts[0];
    let contractAddress = contractInstance.address;

    await web3.eth.sendTransaction({from:ownerAddress,to: contractAddress,value: amountInWei});
    contractBalance = await web3.eth.getBalance(contractInstance.address).toNumber();
    assert.equal(contractBalance,amountInWei,'contract balance should be '+amountInWei);

    // Escaping
    await contractInstance.escapeHatch();

    contractBalance = await web3.eth.getBalance(contractInstance.address).toNumber();
    isPaused = await contractInstance.paused();
    assert.equal(isPaused,true,'contract should be paused');
    assert.equal(contractBalance,0,'contract balance should be 0');
  });
});
