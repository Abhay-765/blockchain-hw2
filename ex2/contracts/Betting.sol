pragma solidity ^0.4.15;

contract Betting {
	/* Standard state variables */
	address public owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint8 public numPlayers;
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
	/* Keep track of all outcomes (maps index to numerical outcome) */
	mapping (uint => uint) public outcomes;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {
		if(msg.sender == owner){
			_;
		}
	}
	modifier OracleOnly() {
		if(msg.sender = oracle){
			_;
		}
	}
	modifier GamblerOnly(){
		if(msg.sender == gamblerA || msg.sender == gamblerB){
				_;
		}
	}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) {
		owner = msg.sender;
		outcomes = _outcomes;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		oracle = _oracle;
		return oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
		if(numPlayers < 2){
				Bet memory myBet = Bet(_outcome, msg.value, true);
				bets[msg.sender] = myBet;
				numPlayers +=1;
				if numPlayers < 1 {
					gamblerA = msg.sender;
				}
				else {
					gamblerB = msg.sender;
				}
				BetMade(msg.sender);
				return true;
		} else {
				return false;
		}

	}


	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() OutcomeExists(_outcome) {
		Bet memory betA = bets[gamblerA];
		Bet memory betB = bets[gamblerB];
		if(betA.outcome == betB.outcome) {
			winnings[gamblerA] = betA.amount;
			winnings[gamblerB] = betB.amount;
		} else {
			uint _winnings = betA.amount + betB.amount;
			if(betA.outcome == _outcome) {
				winnings[gamblerA] = _winnings;
			} else if (betB.outcome == _outcome){
				winnings[gamblerB] = _winnings;
			} else {
				winnings[oracle] = _winnings;
			}
		}
		BetClosed();
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
		if (withdrawAmount > winnings[msg.sender]){
			winnings[msg.sender] = 0;
			msg.sender.transfer(winnings[msg.sender]);
		} else {
			winnings[msg.sender] -= withdrawAmount
			msg.sender.transfer(withdrawAmount);
		}
		return winnings[msg.sender];
	}

	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() public constant returns (uint[]) {
		return outcomes;
	}

	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
		return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
		delete gamblerA;
		delete gamblerB;
		delete numPlayers;
		delete oracle;
		delete (bets[gamblerA]);
		delete (bets[gamblerB]);
		delete (winnings[gamblerA]);
		delete (winnings[gamblerB]);
	}

	/* Fallback function */
	function() payable {
		revert();
	}
}
