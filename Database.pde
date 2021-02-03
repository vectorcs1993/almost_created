import de.bezier.data.sql.*;
import java.util.Iterator;
Database data;
PApplet context = this;

class Database {
  public final  DatabaseObjectList items = new  DatabaseObjectList(), objects = new  DatabaseObjectList();
  StringDict label = new StringDict(), helpMessages = new StringDict(); 
  SQLite db;
  static final int ALL=0, PRODUCTS=1, RESHEARCHED=2;
  Database () {
    JSONArray strings= loadJSONArray("data/languages/ru.json");      //чтение из файла
    for (int i = 0; i < strings.size(); i++) {
      JSONObject part = strings.getJSONObject(i);
      for (java.lang.Object s : part.keys()) {
        String keyIndex = s.toString();
        label.set(keyIndex, part.getString(keyIndex));
      }
    }
    strings= loadJSONArray("data/languages/help_ru.json");      
    for (int i = 0; i < strings.size(); i++) {
      JSONObject part = strings.getJSONObject(i);
      for (java.lang.Object s : part.keys()) {
        String keyIndex = s.toString();
        helpMessages.set(keyIndex, part.getString(keyIndex));
      }
    }
    db = new SQLite(context, "data/objects.db" );  //открывает файл базы данных
    db.setDebug(false);
    loadDatabase(items, "items");
    loadDatabase(objects, "objects");
  }
  DatabaseObjectList getItems() {
    return items;
  }
  DataObject getItem(int id) {
    return items.getId(id);
  }
  ComponentList getListisComponent(int product) { //возвращает список предметов в рецептах которых содержится данный предмет
    ComponentList projects = new ComponentList(items);
    for (Database.DataObject object : items) {
      if (object.reciept!=null) {
        if (object.reciept.hasValue(product)) {
          projects.append(object.id);
        }
      }
    }
    return projects;
  }
  ComponentList getResources() {
    ComponentList list = new ComponentList(items);
    for (DataObject object : items) {
      if (object.reciept==null) 
        list.append(object.id);
    }
    return list;
  }
  class DatabaseObjectList extends ArrayList <DataObject> {
    public DataObject getId(int id) {
      for (DataObject part : this) {
        if (part.id==id)
          return part;
      }
      return null;
    }
    DatabaseObjectList getProducts() { //можно объединить с нижним
      DatabaseObjectList list = new DatabaseObjectList();
      for (DataObject object : this) {
        if (object.reciept!=null) 
          list.add(object);
      }
      return list;
    }
    DatabaseObjectList getIsDeveloped() { 
      DatabaseObjectList list = new DatabaseObjectList();
      ComponentList developed = world.room.getItemsIsDeveloped(); 
      developed.addAll(world.room.getListAllowProducts());
      for (DataObject object : getProducts()) {
        if (developed.hasValue(object.id)) 
          list.add(object);
      }
      return list;
    }
    DataObject getRandom(int filter) {
      DatabaseObjectList list = new DatabaseObjectList();
      if (filter==PRODUCTS) 
        list = this.getProducts();
      else if (filter == RESHEARCHED) 
        list = getIsDeveloped();
      else 
      list = this;
      int random = constrain(int(random(list.size())), 0, list.size()-1);
      return list.get(random);
    }
    void putPool() {
      String resources="";
      ComponentList res = getResources();
      for (int id : res) {
        DataObject object = getItem(id);
        if (object.pool<object.maxPool) {
          object.pool+=int(object.maxPool/20);
          object.pool=constrain(object.pool, 50, object.maxPool);
          resources+=getItem(id).name+", ";
        }
      }
      if (resources.length()>2) {
        resources=resources.substring(0, resources.length()-2);
        printConsole("изменилась цена на: "+resources);
      }
    }
  }

  class DataObject {
    protected final int id;
    protected final PImage sprite;
    protected final String name;
    protected ComponentList reciept, products;
    int scope_of_operation, count_operation, weight, pool, maxPool, work_object, type;
    protected float cost;
    DataObject(int id, String name, PImage sprite) {
      this.id=id;
      this.name=name;
      this.sprite=sprite;
      count_operation=weight=1;
      scope_of_operation=10;
      cost=type=0;
      reciept=null;
      products=new ComponentList(items);
      work_object=-1;
    }
    float getCostForPool() {
      return cost*maxPool/pool;
    }

    public void draw() {
      image(sprite, world.getAbsCoordX()*world.size_grid, world.getAbsCoordY()*world.size_grid);
    }
    void addProduct(int id) {
      if (products==null) 
        products = new ComponentList(items);
      if (!products.hasValue(id))
        products.append(id);
    }

    int getStack() {
      return 100/weight;
    }
  }
  WorkObject getNewObject(Database.DataObject obj) {
    switch(obj.id) {
    case WorkObject.CONTAINER: 
      return new Container(obj.id);
    case WorkObject.TERMINAL: 
      return new Terminal(obj.id); 
    case WorkObject.WORKBENCH: 
      return new Workbench(obj.id); 
    case WorkObject.DEVELOPBENCH: 
      return new DevelopBench(obj.id);
    case WorkObject.FOUNDDRY: 
      return new Workbench(obj.id);
    case WorkObject.SAW_MACHINE: 
      return new Workbench(obj.id);
    case WorkObject.WORKSHOP_MECHANICAL: 
      return new Workbench(obj.id);
    case WorkObject.EXTRUDER: 
      return new Workbench(obj.id);
    case WorkObject.WORKAREA: 
      return new Workbench(obj.id);
    }
    return null;
  }
  private void loadDatabase(ArrayList list, String table) {
    if (db.connect()) {
      db.query("SELECT * FROM "+table);
      while (db.next()) {
        DataObject object = null;
        if (table.equals("objects")) {
          DataObject obj = new DataObject(db.getInt("id"), label.get(db.getString("name")), 
            loadImage("data/sprites/"+db.getString("sprite")+".png"));
          object=obj;
          object.type=db.getInt("job");
          if (obj.id==14) {
            obj.products.append(0);
            obj.products.append(1);
            obj.products.append(2);
            obj.products.append(7);
            obj.products.append(10);
          }
        } else if (table.equals("items")) {
          DataObject obj = new DataObject(db.getInt("id"), label.get(db.getString("name")), 
            loadImage("data/sprites/items/"+db.getString("sprite")+".png"));
          object=obj;
          object.weight=db.getInt("weight"); 
          if (db.getInt("work_object")!=0) 
            object.work_object=db.getInt("work_object");

          if (db.getString("reciept")!=null) {  //заполнение рецепта
            object.count_operation=db.getInt("count_operation"); //определяет количество предмета изготовленного за 1 операцию
            object.reciept = new ComponentList(items);
            JSONArray parse = parseJSONArray(db.getString("reciept"));
            for (int i = 0; i < parse.size(); i++) {
              JSONObject part = parse.getJSONObject(i);
              object.reciept.setComponents(part.getInt("id"), part.getInt("count"));
            }
          } else {
            object.maxPool=db.getInt("max_pool"); //определяет максимальное количество ресурсов в пуле
            object.pool=object.maxPool;
          }
        }

        if (object!=null) {  //если объект базы данных создался
          object.cost=db.getFloat("cost"); //определяет стоимость
          list.add(object);
        }
      }
    }
  }
}


void setupDatabase() {
  data = new Database();
}
