pragma solidity ^0.4.15;

contract BettingContract {
	/* Standard state variables */
	address owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint[] outcomes;

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {
		require (msg.sender == owner);
		_;
	}
	modifier OracleOnly() {
		require (msg.sender == oracle);
		_;
	}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) {
		for (uint i = 0; i < outcomes.length; i++) {outcomes[i] = _outcomes[i];}
		owner = tx.origin;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		oracle = _oracle;
		return oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
		if (msg.sender == owner || msg.sender == oracle) {
			return false;
		}
		
		if (gamblerA == 0) {
			gamblerA = msg.sender;
			bets[gamblerA] = Bet(_outcome, msg.value, false);
			BetMade(msg.sender);
		} else if (gamblerA != msg.sender && gamblerB == 0) {
			gamblerB = msg.sender;
			bets[gamblerB] = Bet(_outcome, msg.value, false);
			BetMade(msg.sender);
		} else {
			revert();
		}
		return true;
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() {
		require (gamblerA != 0 && gamblerB != 0);
		uint256 sum = bets[gamblerA].amount + bets[gamblerB].amount;
		if (sum < bets[gamblerA].amount || sum < bets[gamblerB].amount) {
			revert();
		}
		BetClosed();
		if (bets[gamblerA].outcome == _outcome) {
			winnings[gamblerA] = sum;
			winnings[gamblerB] = 0;
		} else if (bets[gamblerB].outcome == _outcome) {
			winnings[gamblerB] = sum;
			winnings[gamblerA] = 0;
		}
		contractReset();
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
		require (withdrawAmount <= winnings[msg.sender]);
		winnings[msg.sender] -= withdrawAmount;
		(msg.sender).transfer(withdrawAmount);
		remainingBal = winnings[msg.sender];		
	}
	
	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() constant returns (uint[]) {
		uint[] temp;
		for (uint i = 0; i < outcomes.length; i++) { temp[i] = outcomes[i];}
		return temp;
	}
	
	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
			return (winnings[msg.sender]);
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
		gamblerA = 0;
		gamblerB = 0;
		
	}

	/* Fallback function */
	function() {
		revert();
	}
}
