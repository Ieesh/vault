pragma solidity ^0.8.0;
import "./Mytoken.sol";

contract vault {
    //stake and unstake tokens in vault
    address public owner;
    MyToken public myToken;
    address[] public allstakers;
    mapping(address => uint) public user_stake_balance;
    mapping(address => bool) public addr_staked;

    constructor(MyToken _myToken) {
        owner = msg.sender;
        myToken = _myToken;

    }

    function stake(uint amount) public {
        require(amount > 0, "Negative amount cannot be staked");
        myToken.transferFrom(msg.sender, address(this), amount);
        user_stake_balance[msg.sender] += amount;
        allstakers.push(msg.sender);
        addr_staked[msg.sender]= true;
        }

    //unstake tokens
    function unstake(uint amount) public {
        require(amount > 0, "Enter a positive amount");
        uint balance_of_unstaker = user_stake_balance[msg.sender];
        require(balance_of_unstaker >0, "You do not have enough balance");
        require(balance_of_unstaker >= amount, "You are entering more than you have staked");
        myToken.transfer(msg.sender, balance_of_unstaker);
        balance_of_unstaker =  user_stake_balance[msg.sender] - amount;
        if(user_stake_balance[msg.sender] == 0) {
        addr_staked[msg.sender] = false;

        }
                   

    }
  

}
