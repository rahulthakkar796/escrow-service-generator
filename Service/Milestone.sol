pragma solidity ^0.4.24;
//Escrow interface
contract ERC20TokenInterface{
     function balanceOf(address tokenOwner) public view returns (uint balance);
}

//vault interface to interact with vualt contract
contract vaultInterface{
    function receiveFrom(address from,address to,uint amount)public returns(bool);
    function transferTo(address from,address to,uint amount)public returns(bool);

}

//milestone contract
contract Milestone{
     enum MilestoneStatus{
        created,
        activated,
        completedBySeller,
        completedByBoth,
        canceledBySeller,
        canceledByBuyer,
        requestedBySeller,
        requestedByBuyer
    }
    //struct to maintain all the details of milestone
    struct  milestoneList{
        string title;
        uint price;
        uint duration;
        uint id;
        MilestoneStatus status;

        
    }
    //all the addresses of the users
    address public seller;
    address public buyer;
    address public admin;
    uint public totalTime;
    uint count=0;
    
    //array of strcut datatype
    milestoneList[] public listArr;

    //mapping(address=>list[])public  milestoneMap;
    vaultInterface v;
    ERC20TokenInterface e;
    //mapping(uint=>milestoneList) listMilestone;

    //bool conditions for validations
   
    address public vault;

    //enum for stages validations
   
    //constructor to define default args
    constructor (address escrow,address _vault,address _Seller,address _buyer)public{
        seller = _Seller;
        buyer = _buyer;
        admin = msg.sender;
        vault=_vault;
        v = vaultInterface(_vault);
        e = ERC20TokenInterface(escrow);
        
    }
    //modifier for validations
    modifier onlyBuyer{
        require(msg.sender == buyer);
        _;
    }
    
    modifier onlySeller{
        require(msg.sender == seller);
        _;
        
    }
    // modifier completedSeller(uint id){
    //     require(l.status==MilestoneStatus.completedBySeller,"plz wait for seller to confirm the milestone!");
    //     _;
    // }
     
    modifier onlyAdmin{
        require(msg.sender==admin);
        _;
        
    }

    function createMilestone(string _title,uint _price,uint _duration)onlyBuyer public returns(bool){
       
        
       listArr.push(milestoneList(
           _title,
           _price,
           _duration * 60,
           listArr.length,
            MilestoneStatus.created
       ))-1;
     



    }
    
   
    //function to activate specific milestone
    function activateMilestone(uint id) public onlyBuyer returns(bool) {
        
        //  require(l.status==MilestoneStatus.created,"error in activating milestone");
        //  totalTime=now  + l.duration;
        //  storeInVault(buyer,vault,l.price);
        //  l.status=MilestoneStatus.activated;
        //  return true;
         milestoneList l=listArr[id];
        require(l.status==MilestoneStatus.created,"error in activate function!");
        
         totalTime=now+l.duration;
         storeInVault(buyer,vault,l.price);
         l.status=MilestoneStatus.activated;
         return true;
    }
            
    //function to cancel specific milestone  by only buyer
    function cancelBuyer(uint id) public onlyBuyer returns(bool){
        
         milestoneList l=listArr[id];
         require(l.status!=MilestoneStatus.canceledBySeller && l.status==MilestoneStatus.activated && l.status!=MilestoneStatus.completedBySeller && l.status!=MilestoneStatus.completedByBoth && l.status!=MilestoneStatus.canceledByBuyer && now<=totalTime,"error in cancelMilestone function or already canceled by seller");
         l.status = MilestoneStatus.canceledByBuyer; 
         v.transferTo(vault,buyer,l.price);
         
         return true; 
        
    }
    //function to complete milestone by only buyer
    function completeMilestoneBuyer(uint id)public  onlyBuyer returns(bool){
          milestoneList l=listArr[id];
          require(l.status==MilestoneStatus.completedBySeller,"error in completeMilestoneBuyer function");        
          v.transferTo(vault,seller,l.price);
          l.status=MilestoneStatus.completedByBoth;
          return true;
        
    }
    

    //request function in case seller don't complete the milstone and now is > totalTime
    function requestByBuyer(uint id) public onlyBuyer returns(bool){
              milestoneList l=listArr[id];
             require(l.status!=MilestoneStatus.canceledBySeller && l.status!=MilestoneStatus.completedByBoth && l.status==MilestoneStatus.activated && now>totalTime && l.status!=MilestoneStatus.completedBySeller && l.status!=MilestoneStatus.canceledByBuyer && l.status!=MilestoneStatus.requestedBySeller && l.status!=MilestoneStatus.requestedByBuyer,"error requesting by buyer");
           
             l.status=MilestoneStatus.requestedByBuyer;
             v.transferTo(vault,buyer,l.price);
             //delete(listMilestone[id]);
             return true;

    }

    function requestBySeller(uint id) public onlySeller returns(bool){
            milestoneList l=listArr[id];
             require(l.status==MilestoneStatus.completedBySeller && now> totalTime,"error in request by seller");          
              l.status=MilestoneStatus.requestedBySeller;
              v.transferTo(vault,seller,l.price);

              //delete(listMilestone[id]);
              return true;

    }

    //function to cancel specific milestone by seller
    function cancelSeller(uint id) public onlySeller returns(bool){
        
         
         milestoneList l=listArr[id];
         require(l.status!=MilestoneStatus.canceledBySeller && l.status==MilestoneStatus.activated && l.status!=MilestoneStatus.completedBySeller && l.status!=MilestoneStatus.completedByBoth && l.status!=MilestoneStatus.canceledByBuyer && now<=totalTime,"error in cancelMilestone function or already canceled by seller");
        
         l.status = MilestoneStatus.canceledBySeller; 
         
         v.transferTo(vault,buyer,l.price);
        
         return true;
        
    }

    //function to complete milestone by seller
    function completeMilestoneSeller(uint id) public onlySeller returns(bool){
        milestoneList l=listArr[id];
        require(l.status!=MilestoneStatus.canceledBySeller && l.status!=MilestoneStatus.canceledByBuyer  && l.status!=MilestoneStatus.completedByBoth && l.status==MilestoneStatus.activated && l.status!=MilestoneStatus.completedBySeller && now<=totalTime,"error in completeMilestoneSeller");
        l.status=MilestoneStatus.completedBySeller;
       
        return true;


    }

    //function to release funds from vault contract
    // function releaseFromVault(uint id) public returns(bool) {
        
    //      if(completedByBuyer==true && completedBySeller==true && now<=totalTime){
    //      return v.transferTo(admin,seller,l.price);
    //         }
    //      else if(completedBySeller==true && now>totalTime){
    //             return v.transferTo(admin,seller,l.price);
                
    //         }
    //      else if(completedBySeller!=true && now>totalTime){
    //           return v.transferTo(admin,buyer,l.price);
            
    //         }
            
    // }
   
        
    //function to store coins in vault contract
    function storeInVault(address from,address to,uint amount)public returns(bool){
        return v.receiveFrom(from,to,amount);     
    }
    function showBalance(address owner)public view returns(uint){
        return e.balanceOf(owner);
    }

    function noOfMilestones()view public returns(uint){
        return listArr.length;
    }
    function getTitle(uint id)view public returns(string){
         milestoneList l=listArr[id];
        
        return l.title;
    }
    function getPrice(uint id)view public returns(uint){
         milestoneList l=listArr[id];
        return l.price;

    }
    function getDuration(uint id)view public returns(uint){
         milestoneList l=listArr[id];
        return (l.duration)/60;

    }
    function getStatus(uint id)view public returns(uint){
         milestoneList l=listArr[id];
        return uint(l.status);

    }
    
}
