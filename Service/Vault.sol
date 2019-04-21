pragma solidity ^0.5.5;

interface EscrowInterface{
      function approve(address spender, uint tokens) external returns (bool success);
      function balanceOf(address tokenOwner) external view returns (uint balance);
      function transferVault(address from,address to,uint amount)external returns(bool);


}

contract Vault{
    EscrowInterface e;
    address public  owner;
    constructor (address add) public
    {
        owner = msg.sender;
        e = EscrowInterface(add);
    }
    function displayBlanace()public view returns(uint){

        return e.balanceOf(address(this));
    }
   
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