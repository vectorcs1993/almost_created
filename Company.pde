class Company {
  String name;
  float money;
  OrderList opened, closed, failed;
  int buildingLimited, ordersLimited;
  
  Company (String name) {
    this.name=name;
    money=10000.0;
    opened=new OrderList();
    closed=new OrderList();
    failed=new OrderList();
    buildingLimited = 6;
    ordersLimited = 3;
  }
  public String getInfo() {
   return "наименование: "+name+"\n"+
   "бюджет"+": "+money+" $\n"+
   "лимит построек"+": "+buildingLimited+"\n"+
   "лимит заказов"+": "+ordersLimited+"\n"; 
  }
}
