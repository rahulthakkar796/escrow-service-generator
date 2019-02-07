pragma solidity ^0.4.24;

// contract receiveInterface{
//    function displayBalance()public constant returns(uint balance);
//    function _Transfer(address own,uint amount) public returns(bool success);
// }
contract ERC20TokenInterface{
      function transferFrom(address from, address to, uint tokens) external returns (bool success);
      function approve(address spender, uint tokens) public returns (bool success);
      function balanceOf(address tokenOwner) public constant returns (uint balance);
      function transferVault(address from,address to,uint amount)external returns(bool);


}

contract Vault{
    ERC20TokenInterface e;
    address public  owner;
    constructor (address add) public
    {
        owner = msg.sender;
        e = ERC20TokenInterface(add);
    }
    function displayBlanace()public view returns(uint){

        return e.balanceOf(address(this));
    }
    // function approval(address spender,uint tokens)public returns(bool success){
    //     return e.approve(spender,tokens);
       
    // }
    // function receiveFrom(address from,address to,uint amount) public returns (bool success){
      
    //     //approval(to,amount);
    //     e.transferFrom(from,to,amount);
    //     return true;
        
    // }
    function receiveFrom(address from,address to,uint amount)public returns(bool){
        return e.transferVault(from,to,amount);

    }
    function transferTo(address from,address to,uint amount)public returns(bool){
        return e.transferVault(from,to,amount);
    }
    function getOwner()public view returns(address){
        return owner;
    }

    
}