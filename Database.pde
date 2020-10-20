import de.bezier.data.sql.*;
import java.util.Iterator;
Database data;
PApplet context = this;

class Database {
  public final  DatabaseObjectList items = new  DatabaseObjectList();
  public final DatabaseObjectList objects = new  DatabaseObjectList();
  StringDict label = new StringDict();
  SQLite db;

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
    loadDatabase(items, "items");
    loadDatabase(objects, "objects");
  }
  public DatabaseObjectList getItems() {
    return items;
  }

  class DatabaseObjectList extends ArrayList <DataObject> {
    public DataObject getId(int id) {
      for (DataObject part : this) {
        if (part.id==id)
          return part;
      }
      return null;
    }
    public DataObject getRandom(int filter) {
      int random = constrain(int(random(this.size())), 0, this.size()-1);
      return this.get(random);
    }
  }

  class DataObject {
    protected final int id;
    protected final PImage sprite;
    protected final String name;
    protected String description;
    protected ComponentList reciept, products;
    protected int scope_of_operation, count_operation, weight, complexity;
    protected float cost, cost_develop;
    DataObject(int id, String name, PImage sprite) {
      this.id=id;
      this.name=name;
      this.sprite=sprite;
      description="";
      count_operation=weight=scope_of_operation=1;
      cost=cost_develop=0;
      reciept=null;
      products=new ComponentList(items);
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
  }




  public WorkObject getNewObject(Database.DataObject obj) {
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
    }
    return null;
  }
  public String getItemName(int id) {
    return items.getId(id).name;
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
          if (db.getString("parameters")!=null) { //расшифровка параметров
            JSONArray parse = parseJSONArray(db.getString("parameters"));
            for (int i = 0; i < parse.size(); i++) {
              JSONObject part = parse.getJSONObject(i);
              if (part.hasKey("products")) {  //загрузка прочих индивидуальных параметров
                JSONArray parserProducts = part.getJSONArray("products"); //загрузка изделий
                for (int ip = 0; ip < parserProducts.size(); ip++) 
                  object.addProduct(parserProducts.getInt(ip));
              }
            }
          }
        } else if (table.equals("items")) {
          DataObject obj = new DataObject(db.getInt("id"), label.get(db.getString("name")), 
            loadImage("data/sprites/items/"+db.getString("sprite")+".png"));
          object=obj;
          if (db.getString("reciept")!=null) {  //заполнение рецепта
            object.scope_of_operation=db.getInt("scope_of_operation"); //определяет трудоемкость изготовления 1 операции
            object.complexity=db.getInt("complexity"); //определяет сложность разработки
            object.cost_develop=db.getFloat("cost_develop"); //определяет стоимость разработки
            object.weight=db.getInt("weight"); //определяет вес предмета
            object.count_operation=db.getInt("count_operation"); //определяет количество предмета изготовленного за 1 операцию
            object.reciept = new ComponentList(items);
            JSONArray parse = parseJSONArray(db.getString("reciept"));
            for (int i = 0; i < parse.size(); i++) {
              JSONObject part = parse.getJSONObject(i);
              object.reciept.setComponent(part.getInt("id"), part.getInt("count"));
            }
          }
        }

        if (object!=null) {  //если объект базы данных создался
          object.description=label.get(db.getString("description")); //загружает краткое описание объекта
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
