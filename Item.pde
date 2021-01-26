class ComponentList extends IntList {
  Database.DatabaseObjectList data;

  ComponentList(Database.DatabaseObjectList data) {
    super();
    this.data=data;
  }
  void setComponents(int id, int count) {
    for (int i=0; i<count; i++)
      this.append(id);
  }
  int getComponent(int value) {
    if (this.hasValue(value))
      return value;
    else
      return -1;
  }
  ComponentList copy(ComponentList items) {
    this.clear();
    for (int part : items)
      this.append(part);
    return this;
  }
  String getNames(int count) {  //сортирует по наименованию и возвращает список имен
    if (this.size()==0)
      return "пусто";
    else {
      String names="";
      IntList inv = this.sortItem();
      for (int k=0; k<inv.size(); k++) {
        int i=inv.get(k);
        names+=data.getId(i).name+" ("+this.calculationItem(i)*count+")";
        if (k!=inv.size()-1)
          names+=", ";
        else
          names+=";";
      }
      return names;
    }
  }
  public String getNames() {  //сортирует по наименованию и возвращает список имен
    if (this.size()==0)
      return "пусто";
    else {
      String names="";
      IntList inv = this.sortItem();
      for (int k=0; k<inv.size(); k++) {
        int i=inv.get(k);
        names+=data.getId(i).name+" ("+this.calculationItem(i)+")";
        if (k!=inv.size()-1)
          names+=", ";
        else
          names+=";";
      }
      return names;
    }
  }
  IntList sortItem() { //сортирует и возвращает множество отсортированное
    IntList itemsList= new IntList(); 
    for (int part : this) {
      if (!itemsList.hasValue(part)) 
        itemsList.append(part);
    }
    return itemsList;
  }
  int calculationItem(int id) {   //пересчет количества одинаковых предметов в списке
    int total=0;
    for (int part : this) {
      if (part==id) 
        total++;
    }
    return total;
  }
  ComponentList getNeedItems(ComponentList items, int count) {
    ComponentList needs = new ComponentList(data);
    for (int part : items.sortItem()) {  //сортировка по id
      int countNeed = items.calculationItem(part)*count;
      int countCurrent = this.calculationItem(part);
      if (countCurrent<countNeed) //проверка на соответствие количества
        needs.setComponents(part, countNeed-countCurrent);
    }  
    return needs;
  }
  ComponentList getMult(int count) { //возвращает увеличенную копию
    ComponentList needs = new ComponentList(data);
    for (int part : this) {
      needs.setComponents(part, count);
    }  
    return needs;
  }
  float getCostTotal() {   //возвращает себестоимость изготовления
    float cost = 0;
    for (int part : getResources()) {
      Database.DataObject component =  data.getId(part);
      cost+=component.cost;
    }
    return cost;
  }
  ComponentList getResources() { //возвращает список ресурсов для изготовления изделия
    ComponentList resources = new ComponentList(data);
    ArrayList <IntList> reciepts = new ArrayList <IntList>();
    reciepts.add(this);
    while (true) {
      if (reciepts.isEmpty())
        break;
      for (int part : reciepts.get(0)) {
        Database.DataObject component =  data.getId(part);
        if (component.reciept!=null) 
          reciepts.add(component.reciept);
        else
          resources.append(part);
      }
      reciepts.remove(0);
    }
    return (ComponentList)resources;
  }
  int getScopeTotal() { //возвращает полную трудоемкость изготовения
    int scope = 0;
    ArrayList <IntList> reciepts = new ArrayList <IntList>();
    reciepts.add(this);
    while (true) {
      if (reciepts.isEmpty())
        break;
      for (int part : reciepts.get(0)) {
        Database.DataObject component =  data.getId(part);
        if (component.reciept!=null) {
          reciepts.add(component.reciept);
          scope+=10;//component.scope_of_operation;
        }
      }
      reciepts.remove(0);
    }
    return scope;
  }
  boolean isComponents(ComponentList items) {
    for (int part : items.sortItem()) {  //сортировка по id
      if (this.calculationItem(part)<items.calculationItem(part)) { //проверка на соответствие количества
        return false;  //количество не соответствует
      }
    }  
    return true;
  }
  void removeItems(ComponentList items) {
    for (int part : items) 
      this.removeValue(part);
  }
  void removeItems(int value, int count) {
    for (int i = 0; i<count; i++) {
      if (this.hasValue(value))
        this.removeValue(value);
    }
  }
  void addNewProducts(ComponentList items) {
    for (int part : items) {
      Database.DataObject component =  data.getId(part);
      if (component.reciept!=null && !this.hasValue(part))
        this.append(part);
    }
  }
  void addAll(ComponentList items) {
    for (int part : items) 
      this.append(part);
  }
  ComponentList getListNotWork() { //возвращает список (чертежей) не находящихся в работе
    ComponentList projects = new ComponentList(data);
    projects.copy(this);
    for (WorkObject object : world.room.getAllObjects().getDevelopBenches()) {
      DevelopBench develop = (DevelopBench)object;
      if (develop.product!=-1) {
        if (this.hasValue(develop.product))
          projects.removeValue(develop.product);
      }
    }
    return projects;
  }

}
