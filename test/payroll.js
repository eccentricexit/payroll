var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  var contractInstance;

  it("should allow add, read and remove employees", function() {
    var accountAddress = accounts[1];
    var tokenAddresses = [accounts[8],accounts[9]];
    var initialYearlyUSDSalary = 100000;

    return Payroll.deployed().then(function(instance) {
      contractInstance = instance;
      return contractInstance.addEmployee(accountAddress,tokenAddresses,initialYearlyUSDSalary);
    }).then(function() {
      return contractInstance.employeeIdToAddress.call(1);
    }).then(function(employeeAddress){
      assert.equal(employeeAddress,accountAddress,'Employee address should be '+accountAddress);
      return contractInstance.addressToEmployeeId.call(accountAddress);
    }).then(function(employeeId){
      assert.equal(employeeId,1,'Employee Id shoulde be 1');
      return contractInstance.getEmployeeCount.call();
    }).then(function(employeeCount){
      assert.equal(employeeCount,1,"There should be at least an employee.");
      return contractInstance.getEmployee.call(1);
    }).then(function(val){
      assert.equal(val[0],accountAddress,"Should return employee address.");
      assert.deepEqual(val[1],tokenAddresses,"Should return allowed tokens.");
      assert.equal(val[2].toNumber(),initialYearlyUSDSalary,"Should employee salary.");
    });
  });


});
