class Order {

  int id, count, day;
  String label;
  Item product;
  float cost;
  Date date;

  Order (int id, Item product, int count, float cost, int day) {
    this.product=product;
    this.count=count;
    this.cost=cost;
    this.id = id;
    this.day=day;
    this.date = new Date (world.date.day+day, world.date.month, world.date.year);
    label="заказ №"+id+": "+product.name+" ("+count+")";
  }
  String getDescript() {
    return "награда: "+cost+" $\n"+
      "количество: "+world.room.getItems(Item.ALL).calculationItem(product.id)+"/"+count+"\n"+
      "срок: "+date.getDateNotTime()+"\n";
  }
  public boolean isComplete() {
    return  world.room.getItems(Item.ALL).calculationItem(product.id)>=count;
  }
  public boolean isFail(Date date) {
    if ((this.date.month==date.month && this.date.day>date.day) || this.date.month>date.month || this.date.year>date.year)
      return false;
    else 
    return true;
  }
  public void update() {
    if (isFail(date)) {
      date=null;
      date=new Date (world.date.day+day, world.date.month, world.date.year);
    }
  }
}

class OrderList extends ArrayList <Order> {


  public Order getOrder(int id) {      //возвращает экземпляр объекта по id
    for (Order part : this) {
      if (part.id==id) 
        return part;
    }
    return null;
  }
  public OrderList getFailOrders(Date date) {
    OrderList failed = new OrderList();
    for (Order order : this) {
      if (order.isFail(date))
        failed.add(order);
    }
    return failed;
  }

  public int getLastId() {
    if (this.isEmpty())
      return 1;
    IntList s = new IntList();
    for (Order part : this) 
      s.append(part.id);
    return s.max()+1;
  }
}
