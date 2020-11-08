class Company {
  String name;
  private float money;
  OrderList opened, closed, failed;
  int buildingLimited, ordersLimited, ordersOpenLimited, exp;

  Company (String name) {
    this.name=name;
    money=100000;
    opened=new OrderList();
    closed=new OrderList();
    failed=new OrderList();
    buildingLimited = 15;
    ordersLimited = 36;
    ordersOpenLimited=5;
    exp = 0;
  }
  public String getInfo() {
    return "наименование: "+name+"\n"+
    "размер компании"+": "+getLevel()+"\n"+
     "опыт компании"+": "+exp+"\n"+
      "бюджет"+": "+money+" $\n"+
      "лимит построек"+": "+buildingLimited+"\n"+
      "лимит новых заказов"+": "+ordersLimited+"\n"+
      "лимит открытых заказов"+": "+ordersOpenLimited+"\n";
  }
  public void update() {
    money=getDecimalFormat(money);
 
  }

  int getLevel() {
    return int(exp/1000)+1;
  }
}

float getDecimalFormat(float valueFloat) {
  String valueString = str(valueFloat);
  int indexPoint = valueString.indexOf(".");
  return constrain(float(valueString.substring(0, constrain(indexPoint+2, 0, valueString.length()))), 0, valueFloat);
}
