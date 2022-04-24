// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20  {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool succes);

    function transferFrom(address from,address to,uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 amount);

}

contract Cryptos is IERC20 {

    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint public decimals = 0; //9 18
    uint public override totalSupply;

    address public founder;

    mapping(address => uint256) public balances;

    mapping(address => mapping(address => uint256)) allowed;
    // 0x11.... (owner) allows 0x2222... (the spender) ----- 100 tokens
    // allowed[0x111][0x222] = 100;

    constructor(){
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint256){
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 amount) public override returns (bool){
        require(balances[msg.sender] >= amount,"not enough money");
        balances[to] += amount;
        balances[msg.sender] -= amount;

        emit Transfer(msg.sender,to,amount);

        return true;
    }

    function allowance(address tokenOwner, address spender) view public  override returns(uint256){
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint256 tokens) public override returns (bool){
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public override returns (bool){
        require(allowed[from][to] >= amount);
        require(balances[from] >= 0);

        balances[from] -= amount;
        balances[to] += amount;
        allowed[from][to] -= amount;
        return true;
    }
}
