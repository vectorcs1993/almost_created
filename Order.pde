class Order {
  int id, day, count, product;
  float exp, refund;
  float cost;
  Date deadLine, allowDate, newOrder;

  Order (int id, int product, int count, float cost, int day, Date deadLine, Date dayAllow, float exp) {
    this.product=product;
    this.count=count;
    this.cost=cost;
    this.id = id;
    this.exp=exp;
    this.day=day;
    this.deadLine = deadLine;
    this.allowDate = dayAllow;
    refund = 0;
    newOrder=null;
  }
  String getDescriptNew() {
    return "награда: "+cost+" $\n"+
      "опыт: "+exp+"\n"+
      "=================="+"\n"+
      "количество: "+world.room.getItemsIsContainers(Database.ALL).calculationItem(product)+"/"+count+"\n"+
      "доступен до: "+allowDate.getDateNotTime()+"\n"+
      "дней на выполнение: "+day+"\n"+
      "сложность: "+str((data.getItem(product).scope_of_operation+data.getItem(product).reciept.getScopeTotal()))+"\n"+
      "трудоемкость: "+str(count*(data.getItem(product).scope_of_operation+data.getItem(product).reciept.getScopeTotal()))+"\n";
  }
  String getDescriptOpen() {
    return "награда: "+cost+" $\n"+
      "опыт: "+exp+"\n"+
      "количество: "+world.room.getItemsIsContainers(Database.ALL).calculationItem(product)+"/"+count+"\n"+
      "срок до: "+deadLine.getDateNotTime()+"\n";
  }
  String getDescriptClose() {
    return "награда: "+cost+" $\n"+
      "опыт: "+exp;
  }
  String getDescriptFail() {
    return "штраф: "+refund+" $";
  }
  public boolean isComplete() {
    return  world.room.getItemsIsContainers(Database.ALL).calculationItem(product)>=count;
  }
  boolean isFail(Date date) {
    if ((deadLine.month==date.month && deadLine.day>date.day) || deadLine.month>date.month || deadLine.year>date.year)
      return false;
    else 
    return true;
  }
  boolean isNotAllow(Date date) {
    if ((allowDate.month==date.month && allowDate.day>date.day) || allowDate.month>date.month || allowDate.year>date.year)
      return false;
    else 
    return true;
  }
  void update() {
    cost=getDecimalFormat(cost);
    int scope = 1+ data.getItem(product).scope_of_operation+data.getItem(product).reciept.getScopeTotal();
    if (company.getLevel()<=scope/data.getItem(product).scope_of_operation)
      exp = scope*count;
    else 
    exp = (scope/company.getLevel())*count;
  }
}

class OrderList extends ArrayList <Order> {


  Order getOrder(int id) {      //возвращает экземпляр объекта по id
    for (Order part : this) {
      if (part.id==id) 
        return part;
    }
    return null;
  }
  OrderList getFailOrders(Date date) {
    OrderList failed = new OrderList();
    for (Order order : this) {
      if (order.isFail(date))
        failed.add(order);
    }
    return failed;
  }
  String getLabels() {  // возвращает список заказов
    if (this.size()==0)
      return "пусто";
    else {
      String names="";
      int i=0;
      for (Order order : this) {
        names+="заказ №"+order.id+": "+data.getItem(order.product).name+" ("+order.count+")";
        if (i!=this.size()-1)
          names+="\n";
        else
          names+=";";
        i++;
      }
      return names;
    }
  }
  int getLastId() {
    if (this.isEmpty())
      return 1;
    IntList s = new IntList();
    for (Order part : this) 
      s.append(part.id);
    return s.max()+1;
  }
  int getCountTimersEnd() {  //возвращает количество заказов из списка, у которых закончился тайминг
    int count =0;
    for (Order order : this) {
      if (order.newOrder!=null) {
        if (order.newOrder.isPassed(world.date))      
          count++;
        else {
          order.newOrder=null;
          printConsole("доступен новый заказ");
        }
      }
    }
    return count;
  }
}
