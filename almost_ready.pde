import de.bezier.guido.*;
import uibooster.*;
import controlP5.*;
import java.util.Map;
import processing.sound.*;



int _sizeX=800;
int _sizeY=600;
World world;
UiBooster dialog;
long usedMB = 0;
Runtime rt = Runtime.getRuntime();
SoundFile ambient;

PImage floor, no_data, lock;
color blue = color(0, 0, 255);                                                                               //задание цветовых констант
color red = color(255, 0, 0);
color green = color(0, 255, 0);
color white = color(200);
color black = color(60);
color gray = color(185, 176, 176);
color yellow = color(100, 255, 0);
color negr= color(150, 75, 0);
color euro= color(213, 172, 129);
PFont fontConsole, fontMain, fontScale;
void settings() {
  size(_sizeX, _sizeY, JAVA2D);
  noSmooth();
}
void setup() {
  surface.setIcon(loadImage("data/sprites/icon.png"));
  setupDatabase();
  surface.setResizable(true);
  surface.setTitle(data.label.get("title"));
  floor = loadImage("data/sprites/floor.png");
  spr_worker= loadImage("data/sprites/worker/worker.png");
  lock= loadImage("data/sprites/hud/hud_lock.png");
  no_data = loadImage("data/sprites/no_data.png");
  dialog = new UiBooster();
  Interactive.make(this);
  interfaces = new ControlP5(this);
  fontMain = createFont("Arial", 16);
  fontScale = createFont("Arial", 24);
  textFont(fontMain); 
  world = new World(new Date (30, 5, 2019), 350);
  company = new Company ("Robocraft", 0, 10000);
  if (world!=null && company!=null)
    setupInterface();
  newGame();
  //ambient = new SoundFile(this, "data/sound/ambient.wav");
  //ambient.loop();
}
void draw() {
  background(black);
  if (world!=null && company!=null) {
    updateInterface();
    company.update();
    world.update();
  } 
  showScaleText("FPS: "+int(frameRate)+"\n"
    +"x: "+mouseX+"\n"
    +"y: "+mouseY+"\n" 
    +"MU: " + ((rt.totalMemory() - rt.freeMemory()) / 1024) / 1024+ " MB"
    , 712, 20);
}
void keyPressed() {
  int id = data.items.get(int(random(0, data.items.size()-1))).id;
  world.room.addItem(world.getAbsCoordX(), world.getAbsCoordY(), id, 1);
}
void exit() {
  world.pause=true;
  dialog.showConfirmDialog(
    "вы хотите покинуть игру?", 
    "выход", 
    new Runnable() {
    public void run() {
      System.exit(0);
    }
  }
  , 
    new Runnable() {
    public void run() {
      world.pause=false;
    }
  }
  );
}




void save(String nameFile) {
  if (world!=null) {
    JSONObject file_struct = new JSONObject();
    //глобальные данные
    JSONObject global = new JSONObject();
    global.setString("date", world.date.getDate());
    global.setInt("speed", world.speed);
    JSONObject global_pool = new JSONObject();
    for (int res : data.getResources())
      global_pool.setInt(str(res), data.getItem(res).pool);
    global.setJSONObject("pool", global_pool);
    JSONObject global_objects = new JSONObject();
    JSONArray global_objects_containers = new JSONArray ();
    JSONArray global_objects_terminals = new JSONArray ();
    JSONArray global_objects_productions = new JSONArray ();
    JSONArray global_objects_developed = new JSONArray ();
    JSONArray global_objects_items = new JSONArray ();
    for (WorkObject object : world.room.getAllObjects()) {
      if (object instanceof Container) {
        Container container = (Container)object;
        JSONObject object_container = new JSONObject();
        object_container.setInt("x", container.getX());
        object_container.setInt("y", container.getY());
        object_container.setString("name", container.name);
        global_objects_containers.append(object_container);
      } else if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        JSONObject object_terminal = new JSONObject();
        object_terminal.setInt("x", terminal.getX());
        object_terminal.setInt("y", terminal.getY());
        object_terminal.setString("name", terminal.name);
        object_terminal.setFloat("hp", terminal.hp);
        object_terminal.setInt("product", terminal.product);
        object_terminal.setInt("count", terminal.count_operation);
        object_terminal.setInt("progress", terminal.progress);
        if (object instanceof Workbench) {
          object_terminal.setInt("id", terminal.id);
          JSONArray workbench_products = new JSONArray();
          if (terminal.products.size()>0) {
            for (int i : terminal.products) 
              workbench_products.append(i);      
          }
          object_terminal.setJSONArray("products", workbench_products);
          global_objects_productions.append(object_terminal);
        } else if (object instanceof DevelopBench)
          global_objects_developed.append(object_terminal);
        else 
        global_objects_terminals.append(object_terminal);
      } else if (object instanceof ItemMap) {
        ItemMap itemMap = (ItemMap)object;
        JSONObject object_item = new JSONObject();
        object_item.setInt("x", itemMap.getX());
        object_item.setInt("y", itemMap.getY());
        object_item.setInt("item", itemMap.item);
        object_item.setInt("count", itemMap.count);
        global_objects_items.append(object_item);
      }
    }
    global_objects.setJSONArray("containers", global_objects_containers);
    global_objects.setJSONArray("productions", global_objects_productions);
    global_objects.setJSONArray("terminals", global_objects_terminals);
    global_objects.setJSONArray("developed", global_objects_developed);
    global_objects.setJSONArray("items", global_objects_items);
    global.setJSONObject("objects", global_objects);
    JSONArray global_orders = new JSONArray();
    for (Order order : world.orders) 
      global_orders.append(getJSONOrder(order));
    global.setJSONArray("orders", global_orders);
    file_struct.setJSONObject("global", global);
    //данные о компании
    JSONObject global_company = new JSONObject();
    global_company.setString("name", company.name);
    global_company.setFloat("money", company.money);
    global_company.setInt("exp", company.exp);
    JSONArray company_workers = new JSONArray ();
    for (int w=0; w<company.workers.size(); w++) {
      Worker worker = company.workers.get(w);
      JSONObject object_worker = new JSONObject ();
      object_worker.setInt("id", worker.id);
      object_worker.setInt("x", worker.x);
      object_worker.setInt("y", worker.y);
      object_worker.setString("name", worker.name);
      object_worker.setInt("profession", worker.profession.id);
      object_worker.setInt("capacity", worker.capacity);
      JSONObject object_worker_skills = new JSONObject();  
      JSONObject object_worker_skills_values = new JSONObject ();
      for (int i : worker.getAllSkills())
        object_worker_skills_values.setInt(str(i), worker.skills_values.get(i).hashCode());
      JSONObject object_worker_skills_levels = new JSONObject ();
      for (int i : worker.getAllSkills())
        object_worker_skills_levels.setInt(str(i), worker.skills_levels.get(i).hashCode());
      object_worker_skills.setJSONObject("values", object_worker_skills_values);  //массив значений
      object_worker_skills.setJSONObject("levels", object_worker_skills_levels);  //маасив уровней  
      object_worker.setJSONObject("skills", object_worker_skills);
      JSONArray object_worker_items = new JSONArray();
      for (int i : worker.items) 
        object_worker_items.append(i);
      object_worker.setJSONArray("items", object_worker_items);
      company_workers.setJSONObject(w, object_worker);
    }
    global_company.setJSONArray("workers", company_workers);
    JSONArray company_professions = new JSONArray ();
    for (int p=0; p<company.professions.size(); p++) {
      Profession profession = company.professions.get(p);
      JSONObject object_profession = new JSONObject ();
      object_profession.setInt("id", profession.id);
      object_profession.setString("name", profession.name);
      JSONArray profession_jobs = new JSONArray();
      for (int j : profession.jobs)
        profession_jobs.append(j);
      object_profession.setJSONArray("jobs", profession_jobs);
      company_professions.setJSONObject(p, object_profession);
    }
    global_company.setJSONArray("professions", company_professions);
    JSONObject company_orders = new JSONObject();
    JSONArray company_orders_opened = new JSONArray();
    for (Order order : company.opened) 
      company_orders_opened.append(getJSONOrder(order));
    company_orders.setJSONArray("opened", company_orders_opened);
    JSONArray company_orders_closed = new JSONArray();
    for (Order order : company.closed) 
      company_orders_closed.append(getJSONOrder(order));
    company_orders.setJSONArray("closed", company_orders_closed);
    JSONArray company_orders_failed = new JSONArray();
    for (Order order : company.failed) 
      company_orders_failed.append(getJSONOrder(order));
    company_orders.setJSONArray("failed", company_orders_failed);   
    global_company.setJSONObject("orders", company_orders);
    file_struct.setJSONObject("company", global_company);
    //сохранение логов
    JSONArray global_logs = new JSONArray();
    String [] logs = console.getText().split("\n");
    for (String str : logs)
      global_logs.append(str);
    file_struct.setJSONArray("logs", global_logs);
    saveJSONObject(file_struct, "data/"+nameFile+".json");
    printConsole("игровой процесс сохранен в файл: "+"data/"+nameFile+".json");
  }
}

void newGame() {
  company.addWorker("Сергей Иванов", 6);
  company.addWorker("Алексей Михайлов", 6);
  world.room.object[3][3] = new Terminal(WorkObject.TERMINAL, data.objects.getId(WorkObject.TERMINAL).name, 10);
  world.room.object[4][4] = new Workbench(WorkObject.WORKBENCH, data.objects.getId(WorkObject.WORKBENCH).name, 10);
  world.room.object[7][4] = new Workbench(WorkObject.FOUNDDRY, data.objects.getId(WorkObject.FOUNDDRY).name, 10);
  world.room.object[8][4] = new Workbench(WorkObject.WORKSHOP_MECHANICAL, data.objects.getId(WorkObject.WORKSHOP_MECHANICAL).name, 10);
  world.room.object[5][4] = new DevelopBench(WorkObject.DEVELOPBENCH, data.objects.getId(WorkObject.DEVELOPBENCH).name, 10);
  world.room.object[6][4] = new Container(0, data.objects.getId(WorkObject.CONTAINER).name, 400, 1, 20);
  for (int i = 0; i<53; i++) {
    int id = data.getResources().get(int(random(0, data.getResources().size())));
    world.room.addItem(int(random(0, world.room.sizeX-1)), int(random(0, world.room.sizeY-1)), id, int(random(1, 50)));
  }
}

void load() {
  company.dispose();
  company=null;
  world.dispose();
  world=null;
  JSONObject file_struct = loadJSONObject("data/save.json");
  JSONObject global = file_struct.getJSONObject("global");
  JSONObject global_company = file_struct.getJSONObject("company");
  world = new World(getDateFromString(global.getString("date")), global.getInt("speed"));
  company = new Company(global_company.getString("name"), global_company.getInt("exp"), global_company.getFloat("money") );
  for (java.lang.Object s : global.getJSONObject("pool").keys()) //загрузка пула
    data.getItem(int(s.toString())).pool=global.getJSONObject("pool").getInt(s.toString());
  //загрузка профессий
  company.professions.clear(); //удаление должности по умолчанию, т.к. ее могли изменить
  JSONArray company_professions = global_company.getJSONArray("professions");  
  for (int p=0; p<company_professions.size(); p++) {
    JSONObject object_profession = company_professions.getJSONObject(p);
    company.professions.add(new Profession(object_profession.getInt("id"), object_profession.getString("name"), 
      object_profession.getJSONArray("jobs").getIntArray()));
  }
  //загрузка рабочих  
  JSONArray company_workers = global_company.getJSONArray("workers");
  for (int w=0; w<company_workers.size(); w++) {
    JSONObject object_worker = company_workers.getJSONObject(w);
    Worker worker = new Worker(object_worker.getInt("x"), object_worker.getInt("y"), object_worker.getInt("id"), 
      object_worker.getString("name"), object_worker.getInt("capacity"), 
      company.professions.getId(object_worker.getInt("profession")));
    JSONObject object_worker_skills = object_worker.getJSONObject("skills");
    for (java.lang.Object s : object_worker_skills.getJSONObject("values").keys()) //загрузка навыков
      worker.skills_values.put(int(s.toString()), object_worker_skills.getJSONObject("values").getInt(s.toString()));
    for (java.lang.Object s : object_worker_skills.getJSONObject("levels").keys()) //загрузка уровней
      worker.skills_levels.put(int(s.toString()), object_worker_skills.getJSONObject("levels").getInt(s.toString()));
    company.workers.add(worker);
  }

  //загрузка объектов
  JSONArray objects_containers = global.getJSONObject("objects").getJSONArray("containers");
  for (int i = 0; i<objects_containers.size(); i++) {
    JSONObject work_object = objects_containers.getJSONObject(i);
    world.room.object[work_object.getInt("x")][work_object.getInt("y")] = new Container(WorkObject.CONTAINER, work_object.getString("name"), 400, 1, 20);
  }
  JSONArray objects_terminals = global.getJSONObject("objects").getJSONArray("terminals");
  for (int i = 0; i<objects_terminals.size(); i++) {
    JSONObject work_object = objects_terminals.getJSONObject(i);
    Terminal object =  new Terminal(WorkObject.TERMINAL, work_object.getString("name"), work_object.getFloat("hp"));
    object.product=work_object.getInt("product");
    object.count_operation=work_object.getInt("count");
    object.progress=work_object.getInt("progress");
    world.room.object[work_object.getInt("x")][work_object.getInt("y")] = object;
  }
  JSONArray objects_productions = global.getJSONObject("objects").getJSONArray("productions");
  for (int i = 0; i<objects_productions.size(); i++) {
    JSONObject work_object = objects_productions.getJSONObject(i);
    Workbench object = new Workbench(work_object.getInt("id"), work_object.getString("name"), work_object.getFloat("hp"));
    object.product=work_object.getInt("product");
    object.count_operation=work_object.getInt("count");
    object.progress=work_object.getInt("progress");
    world.room.object[work_object.getInt("x")][work_object.getInt("y")] = object;
    for (int product : work_object.getJSONArray("products").getIntArray())
    object.products.append(product);
  }
  JSONArray objects_developed = global.getJSONObject("objects").getJSONArray("developed");
  for (int i = 0; i<objects_developed.size(); i++) {
    JSONObject work_object = objects_developed.getJSONObject(i);
    DevelopBench object = new DevelopBench(WorkObject.DEVELOPBENCH, work_object.getString("name"), work_object.getFloat("hp"));
    object.product=work_object.getInt("product");
    object.count_operation=work_object.getInt("count");
    object.progress=work_object.getInt("progress");
    world.room.object[work_object.getInt("x")][work_object.getInt("y")] = object;
  }
  JSONArray objects_items = global.getJSONObject("objects").getJSONArray("items");
  for (int i = 0; i<objects_items.size(); i++) {
    JSONObject work_object = objects_items.getJSONObject(i);
    world.room.object[work_object.getInt("x")][work_object.getInt("y")] = new ItemMap(work_object.getInt("item"), work_object.getInt("count"));
  }
  //загрузка заказов
  JSONArray global_orders = global.getJSONArray("orders");
  world.orders.clear();
  for (int i = 0; i<global_orders.size(); i++) {
    JSONObject order_object = global_orders.getJSONObject(i);
    Order order = new Order (order_object.getInt("id"), order_object.getInt("product"), order_object.getInt("count"), 
      order_object.getFloat("cost"), order_object.getInt("day"), getDateFromString(order_object.getString("deadLine")), getDateFromString(order_object.getString("allow")), 
      order_object.getFloat("exp"));
    order.refund=order_object.getFloat("refund");
    order.newOrder=getDateFromString(order_object.getString("newOrder"));
    world.orders.add(order);
  }
  JSONArray company_orders_open = global_company.getJSONObject("orders").getJSONArray("opened");
  company.opened.clear();
  for (int i = 0; i<company_orders_open.size(); i++) {
    JSONObject order_object = company_orders_open.getJSONObject(i);
    Order order = new Order (order_object.getInt("id"), order_object.getInt("product"), order_object.getInt("count"), 
      order_object.getFloat("cost"), order_object.getInt("day"), getDateFromString(order_object.getString("deadLine")), getDateFromString(order_object.getString("allow")), 
      order_object.getFloat("exp"));
    order.refund=order_object.getFloat("refund");
    order.newOrder=getDateFromString(order_object.getString("new_order"));
    company.opened.add(order);
  }
  JSONArray company_orders_closed = global_company.getJSONObject("orders").getJSONArray("closed");
  company.closed.clear();
  for (int i = 0; i<company_orders_closed.size(); i++) {
    JSONObject order_object = company_orders_closed.getJSONObject(i);
    Order order = new Order (order_object.getInt("id"), order_object.getInt("product"), order_object.getInt("count"), 
      order_object.getFloat("cost"), order_object.getInt("day"), getDateFromString(order_object.getString("deadLine")), getDateFromString(order_object.getString("allow")), 
      order_object.getFloat("exp"));
    order.refund=order_object.getFloat("refund");
    company.closed.add(order);
  }
  JSONArray company_orders_failed = global_company.getJSONObject("orders").getJSONArray("failed");
  company.failed.clear();
  for (int i = 0; i<company_orders_failed.size(); i++) {
    JSONObject order_object = company_orders_failed.getJSONObject(i);
    Order order = new Order (order_object.getInt("id"), order_object.getInt("product"), order_object.getInt("count"), 
      order_object.getFloat("cost"), order_object.getInt("day"), getDateFromString(order_object.getString("deadLine")), getDateFromString(order_object.getString("allow")), 
      order_object.getFloat("exp"));
    order.refund=order_object.getFloat("refund");
    company.failed.add(order);
  }
  console.clear();
  String [] global_logs = file_struct.getJSONArray("logs").getStringArray();
  for (String str : global_logs) {
    if (str.length()>0) {
      if (console.getText().length()!=0)
        console.append("\n");
      console.append(str).scroll(1);
    }
  }
  printConsole("загружен файл сохранения: data/save.json");
}


JSONObject getJSONOrder(Order order) {
  JSONObject object_order = new JSONObject();
  object_order.setInt("id", order.id);
  object_order.setInt("product", order.product);
  object_order.setInt("count", order.count);
  object_order.setFloat("exp", order.exp);
  object_order.setFloat("day", order.day);
  object_order.setFloat("cost", order.cost);
  object_order.setFloat("refund", order.refund);
  object_order.setString("deadLine", order.deadLine.getDate());
  object_order.setString("allow", order.allowDate.getDate()); 
  if (order.newOrder!=null)
    object_order.setString("new_order", order.newOrder.getDate());
  else 
  object_order.setString("new_order", null);
  return object_order;
}
