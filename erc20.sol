//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;
// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------
 
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
 
 
contract Cryptos is ERC20Interface{
    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint public decimals = 18; //18 is very common
    uint public override totalSupply;
    
    address public founder;
    mapping(address => uint) public balances;
    // balances[0x1111...] = 100;
    
    mapping(address => mapping(address => uint)) allowed;
    // allowed[0x111][0x222] = 100;
    
    
    constructor(){
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }
    
    
    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }
    
    
    function transfer(address to, uint tokens) public override returns(bool success){
        require(balances[msg.sender] >= tokens);
        
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        
        return true;
    }
    
    
    function allowance(address tokenOwner, address spender) view public override returns(uint){
        return allowed[tokenOwner][spender];
    }
    
    
    function approve(address spender, uint tokens) public override returns (bool success){
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        
        allowed[msg.sender][spender] = tokens;
        
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    
    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
         require(allowed[from][to] >= tokens);
         require(balances[from] >= tokens);
         
         balances[from] -= tokens;
         balances[to] += tokens;
         allowed[from][to] -= tokens;
         
         emit Transfer(from, to, tokens);
         
         return true;
     }
}
contract CryptoICO is Cryptos{
    address public admin;
    address  payable public deposit;
    uint256 tokenPrice = 0.001 ether;  // ! 1 ETH = 1000 CRPT, 1 CRPT = 0.001 ETH
    uint256 public hardCap = 300 ether; 

    uint public raisedAmount;
    uint256 public saleStart = block.timestamp + 3600; // ! if you want to ICO start in one hour just add the number of second in a hour  ICO will start
    uint256 public saleEnd = block.timestamp + 604800; // ! ICO ends  in one week
    uint256 public tokenTradeStart = saleEnd + 604800; // ! transferable in a week after sale  *LOCK the tokens*
    uint256 public maxInvest = 5 ether; // ! min buy
    uint256 public minInvest = 0.1 ether; // ! max buy

    enum State{beforeStart, running, afterEnd, halted}

    State public icoState;

    constructor(address payable _deposit){
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    function halt() public OnlyAdmin{
        icoState = State.halted;
    }

    function resume() public OnlyAdmin{
        icoState = State.running;
    }

    function changeDepositAddress(address payable newDeposit) public OnlyAdmin{
        deposit = newDeposit;
    }
    function getCurrentState() public view returns(State){
        if (icoState == State.halted){
            return State.halted;
        }

        else if(block.timestamp < saleStart){
            return State.beforeStart;
        }

        else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        }
        else{
            return State.afterEnd;
        }
    }

    event Invest(address investor, uint256 value,uint256 tokens);

    function invest() payable public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.running);
        
        require(msg.value >= maxInvest && msg.value <= maxInvest);
        raisedAmount += msg.value;

        require(raisedAmount <= hardCap);

        uint256 tokens = msg.value / tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender,msg.value,tokens);
        return true;
    }
    
    modifier OnlyAdmin(){
        require(msg.sender == admin);
        _;
    }

} 