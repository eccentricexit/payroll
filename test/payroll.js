var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  var contractInstance;

  it("should allow add, read and remove employees", function() {
    var accountAddress = accounts[1];
    var tokenAddresses = [accounts[8],accounts[9]];
    var initialYearlyUSDSalary = 100000;

    return Payroll.deployed().then(function(instance) {
      contractInstance = instance;
      return contractInstance.getEmployeeCount();
    }).then(function(employeeCount) {
      assert.equal(employeeCount,0,"Employee count should be 0.");
      return contractInstance.salariesSummation.call();
    }).then(function(salariesSummation) {
      assert.equal(salariesSummation,0,"Salaries summation should be 0");
      return contractInstance.addEmployee(accountAddress,tokenAddresses,initialYearlyUSDSalary);
    }).then(function() {
      return contractInstance.salariesSummation.call();
    }).then(function(salariesSummation) {
      assert.equal(salariesSummation,initialYearlyUSDSalary,"Salaries summation should be "+initialYearlyUSDSalary);
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
    }).then(function(employee){
      assert.equal(employee[0],accountAddress,"Should return employee address.");
      assert.deepEqual(employee[1],tokenAddresses,"Should return allowed tokens.");
      assert.equal(employee[2].toNumber(),initialYearlyUSDSalary,"Should employee salary.");
      return contractInstance.getEmployeeCount();
    }).then(function(employeeCount){
      assert.equal(employeeCount,1,"Employee count should be one.")
    });
  });

  it("should allow owner to set salary", function() {
    var accountAddress = accounts[1];
    var tokenAddresses = [accounts[8],accounts[9]];
    var initialYearlyUSDSalary = 100000;
    var newYearlyUSDSalary = 150000;

    return Payroll.deployed().then(function(instance) {
      contractInstance = instance;
      return contractInstance.getEmployee.call(1);
    }).then(function(employee){
      assert.equal(employee[2].toNumber(),initialYearlyUSDSalary,"Should return initial employee salary.");
      return contractInstance.salariesSummation.call();
    }).then(function(salariesSummation) {
      assert.equal(salariesSummation,initialYearlyUSDSalary,"Salaries summation should be "+initialYearlyUSDSalary);
      return contractInstance.setEmployeeSalary(1,newYearlyUSDSalary);
    }).then(function(){
      return contractInstance.salariesSummation.call();
    }).then(function(salariesSummation) {
      assert.equal(salariesSummation,newYearlyUSDSalary,"Salaries summation should be "+newYearlyUSDSalary);
      return contractInstance.getEmployee.call(1);
    }).then(function(employee){
      assert.equal(employee[2].toNumber(),newYearlyUSDSalary,"Should be new salary.");
    });
  });

  it("should allow owner to remove employees",function(){
    var accountAddress = accounts[1];
    var tokenAddresses = [accounts[8],accounts[9]];
    var salariesSummationBefore;
    var salariesSummationAfter;

    return Payroll.deployed().then(function(instance) {
      contractInstance = instance;
      return contractInstance.salariesSummation.call();
    }).then(function(salariesSummation){
      salariesSummationBefore = salariesSummation;
      return contractInstance.getEmployee.call(1);
    }).then(function(employee){
      assert.equal(accountAddress,employee[0],"Should return employee address.");
      return contractInstance.removeEmployee(1);
    }).then(function(){
      return contractInstance.getEmployeeCount.call();
    }).then(function(employeeCount){
      employeeCount = employeeCount.toNumber();
      assert.equal(employeeCount,0,"Should be zero.")
      return contractInstance.salariesSummation.call();
    }).then(function(salariesSummation){
      salariesSummationAfter = salariesSummation;
      assert.isBelow(salariesSummationAfter,salariesSummationBefore,"Should be less than before removal.");
      return contractInstance.getEmployee.call(1);
    }).then(function(employee){
      assert.equal(employee[0],0,"Should not return employee address.");
      assert.deepEqual(employee[1],[],"Should return allowed tokens.");
      assert.equal(employee[2].toNumber(),0,"Should employee salary.");
    });
  });


});
