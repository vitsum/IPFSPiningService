pragma solidity ^0.4.15;

contract IPFSpinning {
    
    struct Order {
        uint lastBalance;
        uint lastPaid;
    }
    
    enum OrderStatus {
        Active,
        Inactive
    }
    
    address owner;
    mapping(bytes32 => Order) public orders;
    uint pricePerDay = 1 finney;
   
   
    function IPFSpinning() {
        owner = msg.sender;
    }
    
    function Pin(bytes32 link) payable {
        Order order = orders[link];
        
        if(order.lastPaid > 0){
            uint spentDays = GetDiffDays(link);
            uint spentBalance = spentDays * pricePerDay;
            if(order.lastBalance > spentBalance) {
                order.lastBalance -= spentBalance;
            } else {
                order.lastBalance = 0;
            }
        }
        
        order.lastBalance += msg.value;
        order.lastPaid = now;
    }
    
    function GetDiffDays(bytes32 link) constant returns (uint){
        return (now - orders[link].lastPaid) / (60*60*24);
    }
    
    function GetOrderStatus(bytes32 link) constant returns (OrderStatus){
        Order memory order = orders[link];
        
        if(order.lastPaid == 0) return OrderStatus.Inactive;
        
        uint spentDays = GetDiffDays(link);
        uint spentBalance = spentDays * pricePerDay;
        if(order.lastBalance > spentBalance) return OrderStatus.Active;
        return OrderStatus.Inactive;
    }
}
