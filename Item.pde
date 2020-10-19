


class Item {
  private final String name;
  protected final int id;
  protected int scope_of_operation, count_operation, complexity;
  protected final int weight;
  protected float cost;
  static final int STEEL=0, COPPER=1, OIL=2, STONE=3, WOOD=4, PLATE_STEEL=5, PLATE_COPPER=6, RUBBER=7, BLOCK_STONE=8, BLOCK_STEEL=9, 
    BLOCK_PLASTIC=10, KIT_REPAIR=11, ALL=0;
  protected ComponentList reciept;

  Item (int id) {
    this.id=id;
    name =data.getItemName(id);
    weight=data.items.getId(id).weight;
    reciept=data.items.getId(id).reciept;
    cost=data.items.getId(id).cost;
    complexity=data.items.getId(id).complexity;
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

  ComponentList getNeedItems(ComponentList items, int count) {
    ComponentList needs = new ComponentList(data.items);
    for (int part : items.sortItem()) {  //сортировка по id
      int countNeed = items.calculationItem(part)*count;
      int countCurrent = this.calculationItem(part);
      if (countCurrent<countNeed)  //проверка на соответствие количества
        needs.setComponent(part,countNeed-countCurrent);
      
    }  
    return needs;
  }
  boolean isItems(ComponentList items,int count) {
    for (int part : items.sortItem()) {  //сортировка по id
      if (this.calculationItem(part)<items.calculationItem(part)*count)  //проверка на соответствие количества
        return false;  //количество не соответствует
    }  
    return true;
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
  boolean isItems(ComponentList items) {
    for (int part : items.sortItem()) {  //сортировка по id
      if (this.calculationItem(part)<items.calculationItem(part)) { //проверка на соответствие количества
        return false;  //количество не соответствует
      }
    }  
    return true;
  }

  void removeItems(ComponentList items) {
    if (!isItems(items))
      return;
    else { 
      for (int part : items) {
        if (this.hasValue(part))
          this.removeValue(part);
      }
    }
  }
}
