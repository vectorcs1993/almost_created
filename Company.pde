class Company {
  String name;
  private float money;
  OrderList opened, closed, failed;
  int buildingLimited, ordersLimited, ordersOpenLimited, exp;
  boolean gameOver;
  ArrayList <Worker> workers;

  Company (String name) {
    this.name=name;
    gameOver=false;
    money=200000;
    opened=new OrderList();
    closed=new OrderList();
    failed=new OrderList();
    buildingLimited = 15;
    ordersLimited = 36;
    ordersOpenLimited=5;
    exp = 0;
    workers = new ArrayList <Worker>();
 addWorker();
  }
  public String getInfo() {
    return "наименование: "+name+"\n"+
      "размер компании"+": "+getLevel()+"\n"+
      "опыт компании"+": "+exp+"\n"+
      "бюджет"+": "+money+" $\n"+
      "лимит построек"+": "+buildingLimited+"\n"+
      "лимит новых заказов"+": "+ordersLimited+"\n"+
      "лимит открытых заказов"+": "+ordersOpenLimited+"\n"+
      "работников: "+workers.size() +"\n";
  }
  public void update() {
    money=getDecimalFormat(money);
    if (money<=0) 
      gameOver=true;
    if (gameOver) 
    booster.showWarningDialog("Игра проиграна ", "WARN");
    
    
  }
  public void addWorker() {
      workers.add(new Worker(getLastWorkerId()));
  }
  
 public int getLastWorkerId() {
    if (workers.isEmpty())
      return 1;
    IntList s = new IntList();
    for (Worker part : workers) 
      s.append(part.id);
    return s.max()+1;
  }
  
  ArrayList <Worker> getWorkers(int x, int y) {
    ArrayList <Worker> people  = new ArrayList <Worker>();
    for (Worker worker:workers) {
     if (worker.x==x && worker.y==y)
       people.add(worker);
    }
    return people;
  }

  void setExpenses() {
    float sum_money=0;
    for (Worker worker : workers) 
      sum_money+=worker.payday;
    money-=sum_money;
    update();
  }
  int getLevel() {
    return int(exp/1000)+1;
  }
}

float getDecimalFormat(float valueFloat) {
  String valueString = str(valueFloat);
  int indexPoint = valueString.indexOf(".");
  return constrain(float(valueString.substring(0, constrain(indexPoint+2, 0, valueString.length()))), -99999, valueFloat);
}
