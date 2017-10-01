pragma solidity ^0.4.15;

contract Betting {
    /* Standard state variables */
    address public owner;
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
        if (msg.sender == owner) {
            _;
        }
    }

    modifier OracleOnly() {
        if (msg.sender == oracle) {
            _;
        }
    }

    /* Constructor function, where owner and outcomes are set */
    function Betting(uint[] _outcomes) {
        owner = msg.sender;
        outcomes = _outcomes;
    }

    /* Owner chooses their trusted Oracle */
    function chooseOracle(address _oracle) OwnerOnly() returns (address) {
        if (_oracle != gamblerA && _oracle != gamblerB) {
            oracle = _oracle;
        }
        return oracle;
    }

    /* Gamblers place their bets, preferably after calling checkOutcomes */
    function makeBet(uint _outcome) payable returns (bool) {
        if (msg.sender != oracle && msg.sender != owner) {
            if (!bets[gamblerA].initialized) {
                gamblerA = msg.sender;
                bets[gamblerA] = Bet(_outcome, msg.value, true);
                BetMade(gamblerA);
                return true;
            } else if (!bets[gamblerB].initialized) {
                gamblerB = msg.sender;
                bets[gamblerA] = Bet(_outcome, msg.value, true);
                BetMade(gamblerA);
                BetClosed();
                return true;
            }
        }
        return false;
    }

    /* The oracle chooses which outcome wins */
    function makeDecision(uint _outcome) OracleOnly() {
        require(bets[gamblerA].initialized && bets[gamblerB].initialized);

        // assign winnings to gamblers
        uint amountA = bets[gamblerA].amount;
        uint amountB = bets[gamblerB].amount;
        uint sumWinnings = amountA + amountB;

        if (bets[gamblerA].outcome == _outcome) {
            if (bets[gamblerB].outcome == _outcome) {
                winnings[gamblerA] = amountA;
                winnings[gamblerB] = amountB;
            } else {
                winnings[gamblerA] = sumWinnings;
            }
        } else if (bets[gamblerB].outcome == _outcome) {
            winnings[gamblerB] = sumWinnings;
        } else {
            winnings[oracle] = sumWinnings;
        }
        contractReset();
        return;
    }

    /* Allow anyone to withdraw their winnings safely (if they have enough) */
    function withdraw(uint withdrawAmount) returns (uint remainingBal) {
        require(withdrawAmount >= 0);
        require(msg.sender != owner);
        winnings[msg.sender] -= withdrawAmount;
        if (!msg.sender.send(withdrawAmount)) {
            winnings[msg.sender] += withdrawAmount;
        }
        remainingBal = winnings[msg.sender];
    }
    
    /* Allow anyone to check the outcomes they can bet on */
    function checkOutcomes() constant returns (uint[]) {
        return outcomes;
    }
    
    /* Allow anyone to check if they won any bets */
    function checkWinnings() constant returns(uint) {
        return winnings[msg.sender];
    }

    /* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
    function contractReset() private {
        delete(gamblerA);
        delete(gamblerB);
        delete(oracle);
        delete(bets[gamblerA]);
        delete(bets[gamblerB]);
    }

    /* Fallback function */
    function() payable {
        revert();
    }
}
