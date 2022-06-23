pragma solidity ^0.8.0;
import "./Mytoken.sol";
import "./rewardtoken1.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract vault is ERC20{
    //stake and unstake tokens in vault
    address public owner;
    MyToken public myToken;
    rewardtoken public RewardToken;
    address[] public allstakers;
    mapping(address => uint) public user_stake_balance;
    mapping(address => bool) public addr_staked;
    mapping(address=>uint) public rewards_store;
    uint public rewardrate = 5;
    uint public stake_lasttimestamp;
    uint public unstake_lasttimestamp;

    constructor(MyToken _myToken, rewardtoken _rewardtoken) ERC20("Vault Token", "VKT"){
        owner = msg.sender;
        myToken = _myToken;
        RewardToken = _rewardtoken;

    }
    receive() external payable {
           
    }
    modifier OnlyOwner {
        owner == msg.sender;
        _;
    }
    modifier stake_timestamps{
        stake_lasttimestamp = block.timestamp;
        //store time when any function runs

        _;
    }
    modifier unstake_timestamps{
        unstake_lasttimestamp= block.timestamp;

        _;
    }
    uint private unlocked = 1;
    modifier lock {
        require(unlocked == 1, "Currently in transaction state");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function stake(uint amount) public lock stake_timestamps {
        require(amount > 0, "Negative amount cannot be staked");
        myToken.transferFrom(msg.sender, address(this), amount);
        user_stake_balance[msg.sender] += amount;
        allstakers.push(msg.sender);
        addr_staked[msg.sender]= true;
        }

    //unstake tokens
    function unstake(uint amount) public lock unstake_timestamps{
        require(amount > 0, "Enter a positive amount");
        uint balance_of_unstaker = user_stake_balance[msg.sender];
        require(balance_of_unstaker >0, "You do not have enough balance");
        require(balance_of_unstaker >= amount, "You are entering more than you have staked");
        myToken.transfer(msg.sender, balance_of_unstaker);
        balance_of_unstaker =  user_stake_balance[msg.sender] - amount;
        if(user_stake_balance[msg.sender] == 0) {
            uint reward_storage = (unstake_lasttimestamp - stake_lasttimestamp) * rewardrate;
            rewards_store[msg.sender] = reward_storage;
            RewardToken.transfer(address(this), reward_storage);
            rewards_store[msg.sender] = 0;

        addr_staked[msg.sender] = false;
        }

    }

    //Make a function in the vault which will mint the token equal to the amount of ether received

        function mint() public payable OnlyOwner lock{
            //uint token_in_contract = address(this).balance;
            _mint(address(this), msg.value*10**18);
            
        }

    // Update the Vault contract so that you can stake a Token and earn another token in reward. 
    //The reward earned will be 5 Tokens per block. 

    function checkblocknumber() public view returns(uint) {
        return block.number;
    }   
    //function reward() public {
        //require(addr_staked[msg.sender] == true, "You have not staked yet");
        //uint reward_token= 5*block.number;
        //user_stake_balance[msg.sender] 
        //uint mybalance = user_stake_balance[msg.sender];
        //if(mybalance>0) {
        //RewardToken.transfer(address(this), reward_token);
       // }

    //}
    //Whenever user stakes record the information along with the block number at which he is staking.
    //The reward will be 5 Tokens per block… and Number of blocks will be the current block minus the time at which the user has staked.

    function reward_token() public {
        uint reward_storage = (unstake_lasttimestamp - stake_lasttimestamp) * rewardrate;
        rewards_store[msg.sender] = reward_storage;
    } 

}
