class Order {
  int id, count, day, product;
  float exp;
  String label;
  float cost;
  Date date;

  Order (int id, int product, int count, float cost, int day, float exp) {
    this.product=product;
    this.count=count;
    this.cost=cost;
    this.id = id;
    this.day=day;
    this.exp=exp;
    this.date = getDateForDays(day);
    label="заказ №"+id+": "+data.getItem(product).name+" ("+count+")";
  }
  String getDescript() {
    return "награда: "+cost+" $\n"+
      "опыт: "+exp+"\n"+
      "количество: "+world.room.getItemsIsContainers(Database.ALL).calculationItem(product)+"/"+count+"\n"+
      "срок: "+date.getDateNotTime()+" ("+day+" дня/дней)"+"\n"+
      "сложность: "+str((data.getItem(product).scope_of_operation+data.getItem(product).reciept.getScopeTotal()))+"\n"+
      "трудоемкость: "+str(count*(data.getItem(product).scope_of_operation+data.getItem(product).reciept.getScopeTotal()))+"\n";
  }
  public boolean isComplete() {
    return  world.room.getItemsIsContainers(Database.ALL).calculationItem(product)>=count;
  }
  public boolean isFail(Date date) {
    if ((this.date.month==date.month && this.date.day>date.day) || this.date.month>date.month || this.date.year>date.year)
      return false;
    else 
    return true;
  }
  public Date getDateForDays(int days) {
    int month =world.date.month;
    int year=world.date.year;
    int day =world.date.day;
    int tMonth=ceil(days/30);
    if (tMonth>0) {
      int lastDay=days-(tMonth*30);
      day+=lastDay;
      if (month+tMonth>12) {
        year+=1;
        month=month+tMonth-12;
      } else 
      month+=tMonth;
    } else 
    day+=days;
    return new Date (day, month, year);
  }
  public void update() {
    cost=getDecimalFormat(cost);
    int scope = 1+ data.getItem(product).scope_of_operation+data.getItem(product).reciept.getScopeTotal();
    if (world.company.getLevel()<=scope/data.getItem(product).scope_of_operation)
      exp = scope*count;
    else 
    exp = (scope/world.company.getLevel())*count;
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
  public String getLabels() {  // возвращает список заказов
    if (this.size()==0)
      return "пусто";
    else {
      String names="";
      int i=0;
      for (Order order : this) {
        names+=order.label;
        if (i!=this.size()-1)
          names+=", ";
        else
          names+=";";
        i++;
      }
      return names;
    }
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
