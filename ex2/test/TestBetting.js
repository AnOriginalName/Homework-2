var BettingContract = artifacts.require("home/linuxuser/workspace/hw2/Homework-2/ex2/contracts/BettingContract.sol");

contract("BettingContract", function(accounts) {
	const args = {valueA: 50, valueB: 600, outcomes: [1,2,3,4],oracle: 0x1234}
	it("setting up oracle", function() { return BettingContract.deployed()
			.then(function(instance){
						instance.bettingContract([1,2,3,4]);
							return instance.chooseOracle.call(0x1234);
				
					}).then(function(result) {
        assert.equal(args.oracle, result, "oracle should match constructor argument");
      })
				
      
     
		});
	it("setting up oracle", function() { return BettingContract.deployed()
			.then(function(instance){
						instance.bettingContract([1,2,3,4]);
							return instance.chooseOracle.call(0x1234);
				
					}).then(function(result) {
        assert.equal(args.oracle, result, "oracle should match constructor argument");
      })
				
      
     
		});
});
