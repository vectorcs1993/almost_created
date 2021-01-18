


class Item {
  private final String name;
  protected final int id;
  protected int scope_of_operation, count_operation;
  protected final int weight;
  protected float cost;
  static final int ALL=0, PRODUCTS=1;
  protected ComponentList reciept;

  Item (int id) {
    this.id=id;
    name =data.getItemName(id);
    weight=data.items.getId(id).weight;
    reciept=data.items.getId(id).reciept;
    cost=data.items.getId(id).cost;
    count_operation=data.items.getId(id).count_operation;
    scope_of_operation=data.items.getId(id).scope_of_operation;
  }
}

class ItemList extends ArrayList <Item> {

  public IntList sortItem() { //сортирует и возвращает множество отсортированное
    IntList itemsList= new IntList(); 
    for (Item part : this) {
      if (!itemsList.hasValue(part.id)) 
        itemsList.append(part.id);
    }
    return itemsList;
  }

  public int getWeight() {
    int itemsWeight = 0; 
    for (Item part : this) 
      itemsWeight+=part.weight;
    return itemsWeight;
  }

  public int calculationItem(int id) {   //пересчет количества одинаковых предметов в списке
    int total=0;
    for (Item part : this) {
      if (part.id==id) 
        total++;
    }
    return total;
  }

  public Item getItem(int id) {      //возвращает экземпляр объекта по id
    for (Item part : this) {
      if (part.id==id) 
        return part;
    }
    return null;
  }

  public String getNames() {
    if (this.isEmpty())
      return "пусто";
    else {
      String names="";
      IntList inv = this.sortItem();
      for (int k=0; k<inv.size(); k++) {
        int i=inv.get(k);
        names+=this.getItem(i).name+" ("+this.calculationItem(i)+")";
        if (k!=inv.size()-1)
          names+=", ";
        else
          names+=";";
      }
      return names;
    }
  }
  public void addItemCount (Item item, int count) {
    if (item!=null) {
      for (int i=0; i<count; i++)
        this.add(item);
    }
  }
  public void removeItemCount (Item item, int count) {
    if (item!=null) {
      for (int i=0; i<count; i++)
        if (this.contains(item))
          this.remove(item);
    }
  }
  public void removeItemCount (int id, int count) {
    for (int i=0; i<count; i++) {
      Item item = this.getItem(id);
      if (item!=null)
        this.remove(item);
    }
  }
  ComponentList getNeedItems(ComponentList items, int count) {
    ComponentList needs = new ComponentList(data.items);
    for (int part : items.sortItem()) {  //сортировка по id
      int countNeed = items.calculationItem(part)*count;
      int countCurrent = this.calculationItem(part);
      if (countCurrent<countNeed)  //проверка на соответствие количества
        needs.setComponent(part, countNeed-countCurrent);
    }  
    return needs;
  }
  ComponentList getComponentList() {
    ComponentList items = new ComponentList(data.items);
    for (Item part : this)  
      items.append(part.id);
     
    return items;
  }
  boolean isItems(ComponentList items, int count) {
    for (int part : items.sortItem()) {  //сортировка по id
      if (this.calculationItem(part)<items.calculationItem(part)*count)  //проверка на соответствие количества
        return false;  //количество не соответствует
    }  
    return true;
  }
  boolean isItems(ComponentList items) {
    for (int part : items.sortItem()) { 
      if (this.calculationItem(part)<items.calculationItem(part)) {
        return false;
      }
    }  
    return true;
  }
  void removeItems(ComponentList items) {
    if (!isItems(items))
      return;
    else { 
      for (int part : items) {
        if (this.getItem(part)!=null)
          this.remove(this.getItem(part));
      }
    }
  }
}

class ComponentList extends IntList {
  Database.DatabaseObjectList data;

  ComponentList(Database.DatabaseObjectList data) {
    super();
    this.data=data;
  }

  void setComponent(int id, int count) {
    for (int i=0; i<count; i++)
      this.append(id);
  }
  public ComponentList copy(ComponentList items) {
    this.clear();
    for (int part : items)
      this.append(part);
    return this;
  }
  public String getNames(int count) {  //сортирует по наименованию и возвращает список имен
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
  public IntList sortItem() { //сортирует и возвращает множество отсортированное
    IntList itemsList= new IntList(); 
    for (int part : this) {
      if (!itemsList.hasValue(part)) 
        itemsList.append(part);
    }
    return itemsList;
  }
  public int calculationItem(int id) {   //пересчет количества одинаковых предметов в списке
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
        needs.setComponent(part, countNeed-countCurrent);
    }  
    return needs;
  }

  ComponentList getMult(int count) { //возвращает увеличенную копию
    ComponentList needs = new ComponentList(data);
    for (int part : this) {
      needs.setComponent(part, count);
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
    if (!isComponents(items))
      return;
    else { 
      for (int part : items) {
        if (this.hasValue(part))
          this.removeValue(part);
      }
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
}
