
PApplet context = this;

class Database {
  public final  DatabaseObjectList items = new  DatabaseObjectList(), objects = new  DatabaseObjectList();
  StringDict label = new StringDict(); 
  SQLite db;
  static final int ALL=0, PRODUCTS=1, RESHEARCHED=2;
  private HashMap <Integer, String> namesItems, namesObjects;
  private HashMap <Integer, ComponentList> reciepts;

  Database () {
    JSONArray strings= loadJSONArray("data/languages/ru.json");      //чтение из файла
    for (int i = 0; i < strings.size(); i++) {
      JSONObject part = strings.getJSONObject(i);
      for (java.lang.Object s : part.keys()) {
        String keyIndex = s.toString();
        label.set(keyIndex, part.getString(keyIndex));
      }
    }
    db = new SQLite(context, "data/objects.db" );  //открывает файл базы данных
    db.setDebug(false);
    setNames("items");
    setNames("objects");
    setReciepts();
    loadDatabase(items, "items");
    loadDatabase(objects, "objects");
   // maxScope=0;
  }
  DatabaseObjectList getItems() {
    return items;
  }
  DataObject getItem(int id) {
    return items.getId(id);
  }

  private void setNames(String table) {  //создает массив наименований
    if (db.connect()) {
      db.query("SELECT name, id FROM "+table);
      while (db.next()) {
        if (table.equals("items")) {
          if (namesItems==null)
            namesItems = new HashMap <Integer, String>();
          namesItems.put(db.getInt("id"), db.getString("name"));
        } else if (table.equals("objects")) {
          if (namesObjects==null)
            namesObjects = new HashMap <Integer, String>();
          namesObjects.put(db.getInt("id"), db.getString("name"));
        }
      }
    }
  }
  private void setReciepts() {  //создает массив рецептов
    if (db.connect()) {
      db.query("SELECT reciept, id FROM items");
      while (db.next()) {
        if (reciepts==null)
          reciepts = new HashMap <Integer, ComponentList>();
        if (db.getString("reciept")!=null) {
          ComponentList reciept = new ComponentList();
          JSONArray parse = parseJSONArray(db.getString("reciept"));
          for (int i = 0; i < parse.size(); i++) {
            JSONObject part = parse.getJSONObject(i);
            reciept.setComponents(part.getInt("id"), part.getInt("count"));
          }   
          reciepts.put(db.getInt("id"), reciept);
        }
      }
    }
  }
  //непосредственные запросы в БД
  String getName(String table, int id) {  //запрос имени с таблиц объекты и предметы
    if (table.equals("items"))
      return label.get(namesItems.get(id));
    else if (table.equals("objects"))
      return label.get(namesObjects.get(id));
    else 
    return "неизвестно";
  }
  ComponentList getReciept(int id) {  //запрос рецепта
    return reciepts.get(id);
  }


  // String getName(String table, int id) {  //запрос имени с таблиц объекты и предметы
  //  db.query("SELECT name FROM "+table+" WHERE id="+id); 
  //  return label.get(db.getString("name"));
  // }

  ComponentList getComponentsIsComponent(int product) { //возвращает список предметов в рецептах которых содержится данный предмет
    ComponentList projects = new ComponentList();
    for (int id : reciepts.keySet()) {
      if (reciepts.get(id).hasValue(product)) {
        projects.append(id);
      }
    }
    return projects;
  }
  ComponentList getAllItems() {
    db.query("SELECT id FROM items"); 
    ComponentList items = new ComponentList();
    while (db.next()) {
      items.append(db.getInt("id"));
    }
    return items;
  }
  ComponentList getResources() {
    db.query("SELECT reciept, id FROM items"); 
    ComponentList resources = new ComponentList();
    while (db.next()) {
      if (db.getString("reciept")==null)
        resources.append(db.getInt("id"));
    }
    return resources;
  }
  ComponentList getProducts() { //можно объединить с нижним
    db.query("SELECT reciept, id FROM items"); 
    ComponentList products = new ComponentList();
    while (db.next()) {
      if (db.getString("reciept")!=null)
        products.append(db.getInt("id"));
    }
    return products;
  }
  ComponentList getIsDeveloped() { 
    ComponentList list = new ComponentList();
    ComponentList developed = world.room.getItemsIsDeveloped(); 
    developed.addAll(world.room.getListAllowProducts());
    for (int object : getProducts()) {
      if (developed.hasValue(object)) 
        list.append(object);
    }
    return list;
  }
  int getItemRandom(int filter) {  //возвращет случайный предмет из бд
    ComponentList list;
    if (filter==PRODUCTS) 
      list = getProducts();
    else if (filter==RESHEARCHED) 
      list = getIsDeveloped();
    else 
    list = getAllItems();
    return list.get(constrain(int(random(list.size())), 0, list.size()-1));
  }
  int getScopeMax() {  //возвращает максимальное значение сложности обрабатывая все изделия
    IntList scope = new IntList();
    for (int part : getProducts()) {
      if (getReciept(part)!=null) 
        scope.append(getReciept(part).getScopeTotal());
    }
    return scope.max();
  }
    void putPool() {
      String resources="";
      ComponentList res = getResources();
      for (int id : res) {
        DataObject object = getItem(id);
        if (object.pool<object.maxPool) {
          object.pool+=int(object.maxPool/20);
          object.pool=constrain(object.pool, 50, object.maxPool);
          resources+=getName("items", id)+", ";
        }
      }
      if (resources.length()>2) {
        resources=resources.substring(0, resources.length()-2);
        printConsole("изменилась цена на: "+resources);
      }
    }


  class DatabaseObjectList extends ArrayList <DataObject> {

    DataObject getId(int id) {
      for (DataObject part : this) {
        if (part.id==id)
          return part;
      }
      return null;
    }



  }

  class DataObject {
    protected final int id;
    protected final PImage sprite;

    protected ComponentList products;
    int scope_of_operation, weight, pool, maxPool, work_object, type, maxHp;
    protected float cost;
    DataObject(int id, PImage sprite) {
      this.id=id;

      this.sprite=sprite;
      weight=1;
      scope_of_operation=10;
      cost=type=0;
      products=new ComponentList();
      work_object=-1;
      maxHp=100;
    }
    float getCostForPool() {
      return cost*maxPool/pool;
    }
    void draw() {
      image(sprite, 0, 0);
    }
    int getScope() {
      return int(map(getReciept(id).getScopeTotal(), 0, d.getScopeMax(), 100, 10000));
    }
    void addProduct(int id) {
      if (products==null) 
        products = new ComponentList();
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
      return new Container(obj.id, d.getName("objects", obj.id));
    case WorkObject.GARAGE: 
      return new Container(obj.id, d.getName("objects", obj.id));
    case WorkObject.TERMINAL: 
      return new Terminal(obj.id, d.getName("objects", obj.id), obj.maxHp); 
    case WorkObject.WORKBENCH: 
      return new Workbench(obj.id, d.getName("objects", obj.id), obj.maxHp); 
    case WorkObject.DEVELOPBENCH: 
      return new DevelopBench(obj.id, d.getName("objects", obj.id), obj.maxHp);
    case WorkObject.FOUNDDRY: 
      return new Workbench(obj.id, d.getName("objects", obj.id), obj.maxHp);
    case WorkObject.SAW_MACHINE: 
      return new Workbench(obj.id, d.getName("objects", obj.id), obj.maxHp);
    case WorkObject.WORKSHOP_MECHANICAL: 
      return new Workbench(obj.id, d.getName("objects", obj.id), obj.maxHp);
    case WorkObject.EXTRUDER: 
      return new Workbench(obj.id, d.getName("objects", obj.id), obj.maxHp);
    case WorkObject.WORKAREA: 
      return new Workbench(obj.id, d.getName("objects", obj.id), obj.maxHp);
    }
    return null;
  }



  private void loadDatabase(ArrayList list, String table) {
    if (db.connect()) {
      db.query("SELECT * FROM "+table);
      while (db.next()) {
        DataObject object = null;
        if (table.equals("objects")) {
          DataObject obj = new DataObject(db.getInt("id"), 
            loadImage("data/sprites/"+db.getString("sprite")+".png"));
          object=obj;
          object.type=db.getInt("job");
          if (obj.id==14) {
            obj.products.append(0);
            obj.products.append(1);
            obj.products.append(2);
            obj.products.append(7);
            obj.products.append(8);
            obj.products.append(10);
          }
        } else if (table.equals("items")) {
          DataObject obj = new DataObject(db.getInt("id"), 
            loadImage("data/sprites/items/"+db.getString("sprite")+".png"));
          object=obj;
          object.weight=db.getInt("weight"); 
          if (db.getInt("work_object")!=0) 
            object.work_object=db.getInt("work_object");

          if (db.getString("reciept")!=null) {  //заполнение рецепта
          } else {
            object.maxPool=db.getInt("max_pool"); //определяет максимальное количество ресурсов в пуле
            object.pool=object.maxPool;
          }
        }

        if (object!=null) {  //если объект базы данных создался
          object.cost=db.getFloat("cost"); //определяет коэффициент стоимости
          list.add(object);
        }
      }
    }
  }
}
