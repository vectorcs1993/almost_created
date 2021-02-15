abstract class WorkObject {
  int id, progress;
  PImage sprite;
  String name;
  int direction;
  static final int CONTAINER = 0, TERMINAL = 14, WORKBENCH=16, DEVELOPBENCH =17, FOUNDDRY =18, SAW_MACHINE=19, WORKSHOP_MECHANICAL =21, 
    EXTRUDER=22, WORKAREA =23,  GARAGE =24;
  Job job;
  WorkObject(int id, String name) {
    this.id=id; 
    this.name=name;
    if (id!=-1)
      sprite=data.objects.getId(id).sprite;
    job=null;
    direction=0;
  }
  String getIsJobLock() {
    if (job!=null)
      return "\nблокировка: "+job.worker.name;
    else
      return "";
  }
  float getDirectionRad() {
    switch (direction) {
    case 1: 
      return radians(90);
    case 2:  
      return radians(180);
    case 3:  
      return radians(270);
    default:  
      return radians(0);
    }
  }
  void draw() {
    pushMatrix();
    rotate(getDirectionRad());
    image(sprite, -world.size_grid/2, -world.size_grid/2);
    popMatrix();
    if (job!=null) 
      drawBottomSprite(lock);
  }
  void drawSelected() {
    pushStyle();
    fill(black);
    float tx = getAdjXforPosition(getX()*world.size_grid, name);
    float ty = getAdjYforPosition(getY()*world.size_grid);
    rect(tx-5, ty - 18, textWidth(name)+10, 20);
    fill(white);
    text(name, tx, ty);
    noFill();
    stroke(green);
    text(name, tx, ty);
    strokeWeight(3);
    rect(0, 0, world.size_grid, world.size_grid);
    popStyle();
  }
  float getAdjXforPosition(float x, String name) {
    if (x+16-textWidth(name)/2<0)
      return 0;
    else if (x+16+textWidth(name)/2>world.room.sizeX*world.size_grid) 
      return -textWidth(name)+32-5;
    else
      return 16-textWidth(name)/2;
  }
  float getAdjYforPosition(float y) {
    if (y-32-textDescent()<=0)
      return 96;
    else
      return -48;
  }
  void drawBottomSprite(PImage sprite) {
    pushStyle();
    tint(white, 190);
    image(sprite, -world.size_grid/2, -world.size_grid/2);
    popStyle();
  }
  void drawCount(int count) {
    pushMatrix();
    translate(-world.size_grid/2, -world.size_grid/2);
    pushStyle();
    strokeWeight(1);
    rectMode(CORNERS);
    fill(black);
    noStroke();
    rect(world.size_grid-textWidth(str(count))-3, world.size_grid-world.size_grid/2+3, world.size_grid-1, world.size_grid-1);
    textSize(10);
    textAlign(RIGHT, BOTTOM);
    fill(white);
    text(count, world.size_grid-3, world.size_grid);
    popStyle();
    popMatrix();
  }
  void drawPlace(color _color) {
    pushStyle();
    noFill();
    stroke(_color);
    strokeWeight(1);
    int [] place = world.getPlace(getX(), getY(), direction);
    rect((place[0]-getX())*world.size_grid, (place[1]-getY())*world.size_grid, world.size_grid, world.size_grid);
    popStyle();
  }
  void drawStatus(int ty, float a, float b, color one, color two) {
    if (a<b) {
      pushMatrix();
      translate(-world.size_grid/2, -world.size_grid/2);
      pushStyle();
      strokeWeight(3);
      stroke(one);
      float xMax = map(a, 0, b, 2, world.size_grid-2);
      line(2, ty, xMax, ty);
      stroke(two);
      line(xMax, ty, world.size_grid-2, ty);
      popStyle();
      popMatrix();
    }
  }
  int [] getXY() {
    return world.room.getAbsCoordObject(this);
  }
  int getX() {
    return getXY()[0];
  }
  int getY() {
    return getXY()[1];
  }
  abstract String getDescript();
  void setNextDirection() {
    if (direction<3) 
      direction++;
    else 
    direction=0;
  }
}

class ItemMap extends WorkObject {
  int item, count;
  ItemMap (int item, int count) {
    super(-1, null);
    this.item=item;
    this.count=count;
    sprite=data.getItem(item).sprite;
    name=data.getItem(item).name;
  }
  String getDescript() {
    return "предмет";
  }
  void draw() {
    super.draw();
    if (count>1)
      drawCount(count);
  }
}
class Terminal extends WorkObject {
  float hp, wear, speed;
  int product;
  WorkLabel label;
  ComponentList products;
  int count_operation;
  private float refund;
  private int max_count_operation;
  Timer timer;
  Terminal (int id, String name, float hp) {
    super(id, name);
    label=null;
    progress=0;
    product=-1;
    products = new ComponentList(data.items);
    products = data.objects.getId(id).products;
    this.hp=hp;
    wear=0.1;
    speed=60;
    count_operation=0;
    refund=0;
    max_count_operation=1000;
    timer = new Timer();
  }
  protected void tick() {
    if (!timer.check()) {
      update();
      timer.set(getTick());
    }
  }
  color getColor() {
    return blue;
  }
  String getDescriptTask() {
    Database.DataObject item = data.getItem(mainList.select.id);
    if (item.pool>0) {
      return "количество: "+count_operation+"\n"
        +"цена: "+getDecimalFormat(count_operation*item.getCostForPool())+" $\n"
        +"пул: "+item.pool;
    } else 
    return "недоступно";
  }
  String getProductDescript() {
    if (label==null)
      return "доставка товара: "+data.getItem(product).name+"\nпроцесс: "+progress+"/"+getMaxProgress()+"";
    else 
    return data.getItem(product).name+" доставлен";
  }
  protected float getTick() {
    return speed;
  }
  int getMaxProgress() {
    return int(map(count_operation, 0, max_count_operation, 300, 100));
  }
  void work() {  //функция выполняется из job, по этому проверка на job=isNull не нужна
    if (product!=-1) {
      if (hp>0) {
        if (label==null) {
          if (this instanceof Workbench && ((Workbench)this).components.size()>0)
            ((Workbench)this).components.removeItems(data.getItem(product).reciept.getMult(count_operation));  //списание компонентов для изготовления
          int job_modificator = job.worker.getWorkModificator(data.objects.getId(id).type);
          progress+=job_modificator;
          hp-=wear;
          if (progress>=getMaxProgress()) {
            if (this instanceof DevelopBench) {
              printConsole("чертеж "+data.getItem(product).name+" разработан");
              printConsole("объект "+data.objects.getId(data.getItem(product).work_object).name+": список доступных изделий обновлен");
              data.objects.getId(data.getItem(product).work_object).products.append(product);
              removeLabel();
            } else {
              if (this instanceof Workbench) 
                printConsole("предмет "+data.getItem(product).name+" ("+count_operation+") изготовлен");
              else
                printConsole("ресурс "+data.getItem(product).name+" ("+count_operation+") доставлен");
              int [] place = world.room.getAbsCoordObject(this);
              int count=world.room.addItem(place[0], place[1], product, count_operation);
              if (count<=0)
                removeLabel();
              else {
                float x=world.room.getCoordObject(this)[0];
                float y=world.room.getCoordObject(this)[1];
                float size=world.room.getCoordObject(this)[2];
                label=new WorkLabel(x-10, y-10, size, size, product, count, getColor());
                if (!menuMain.select.event.equals("showObjects")) 
                  label.setActive(false);
              }
            }
          }
        }
      } else 
        job.exit=true;
    }
  }
  void update() {
    speed=constrain(speed, 0, 1000);
    hp=constrain(hp, 0, data.objects.getId(id).maxHp);
    wear=constrain(wear, 0.01, 0.5);
  }
  void removeLabel() {
    if (label!=null) {
      label.setActive(false);
      label=null;
    } 
    product=-1;
    progress=0;
    count_operation=0;
  }
  public void draw() {
    super.draw();
    if (product!=-1) {
      drawBottomSprite(data.getItem(product).sprite);
      if (progress>0)
        drawStatus(5, progress, getMaxProgress(), green, red);
    }
    int maxHp=data.objects.getId(id).maxHp;
    if (hp<maxHp)
      drawStatus(9, hp, maxHp, blue, red);
  }
  public String getDescript() {
    return name+"\n"+
      "состояние"+": "+getDecimalFormat(hp)+"/"+data.objects.getId(id).maxHp+"\n"+
      "требуемый навык"+": "+getSkillName(data.objects.getId(id).type)+
      getIsJobLock();
  }
  protected String getCharacters() {
    return "скорость"+": "+map(speed, 1000, 0, 0, 100)+"\n"+
      "износостойкость"+": "+map(wear, 0.01, 0.5, 100, 0);
  }
}
class Workbench extends Terminal {
  private ComponentList components;

  Workbench (int id, String name, float hp) {
    super(id, name, hp);
    components = new ComponentList(data.items);
  }
  color getColor() {
    return black;
  }
  int getMaxProgress() {
    return data.getItem(product).scope_of_operation*count_operation;
  }
  String getDescriptTask() {
    Database.DataObject product = data.getItem(mainList.select.id);
    return "количество: "+count_operation+"\n"
      +"трудоёмкость: "+count_operation*(product.scope_of_operation+product.reciept.getScopeTotal())+"\n";
  }
  String getProductDescript() {
    if (label==null)
      return "изделие: "+data.getItem(product).name;
    else 
    return data.getItem(product).name+" изготовлено";
  }        
  String getDescriptProgress() {    
    return "процесс: "+progress+"/"+getMaxProgress();
  }
  void removeLabel() {
    super.removeLabel();
    finish();
  }
  IntList getNeedItems() {
    IntList needItems = new IntList();
    if (product!=-1 && label==null) {
      for (int part : data.getItem(product).reciept.sortItem()) {
        if (components.calculationItem(part)<data.getItem(product).reciept.calculationItem(part)*count_operation) 
          needItems.append(part);
      }
    }
    return needItems;
  }
  boolean isAllowCreate() {
    if (product!=-1) {
      if (progress>0)
        return true;
      for (int part : data.getItem(product).reciept.sortItem()) {
        if (components.calculationItem(part)<data.getItem(product).reciept.calculationItem(part)*count_operation) 
          return false;
      }
    }
    return true;
  }
  void finish() {  
    for (int part : components.sortItem()) 
      world.room.addItem(this.getX(), this.getY(), part, components.calculationItem(part));
    components.clear();
  }
  int getNeedItemCount(int id) {
    if (product!=-1 && label==null) {
      return data.getItem(product).reciept.calculationItem(id)*count_operation-components.calculationItem(id);
    } else
      return -1;
  }
}

class DevelopBench extends Terminal {
  DevelopBench (int id, String name, float hp) {
    super(id, name, hp);
  }
  color getColor() {
    return gray;
  }
  int getMaxProgress() {
    return constrain(data.getItem(product).reciept.getScopeTotal(), 5, 10000);
  }
  String getDescriptTask() {
    String difficultyText="";
    int difficulty = data.getItem(mainList.select.id).reciept.getScopeTotal();
    if (difficulty!=0)
      difficultyText = "сложность: "+difficulty+"\n";
    return difficultyText+"изготавливается: "+data.objects.getId(data.getItem(mainList.select.id).work_object).name;
  }
  String getProductDescript() {
    if (label==null)
      return "чертеж на: "+data.getItem(product).name+"\nпроцесс: "+progress+"/"+getMaxProgress()+"\n";
    else 
    return data.getItem(product).name+" разработан";
  }
}

class Container extends WorkObject {
  int capacity, weightMax, weightMin;
  ComponentList items;

  Container (int id, String name, int capacity, int weightMin, int weightMax) {
    super(id, name);
    items = new ComponentList(data.items);
    this.capacity = capacity;
    this.weightMax=weightMax;
    this.weightMin=weightMin;
  }
  public String getDescript() {
    return name+"\n"+
      "вместимость: "+getCapacity()+"/"+capacity+getIsJobLock();
  }
  public int getCapacity() {
    int capacity = 0;
    for (int item : items) 
      capacity+=data.getItem(item).weight;
    return capacity;
  }
  public boolean isFreeCapacity() {
    if (getCapacity()<capacity) 
      return true;
    else
      return false;
  }
  public boolean isFreeCapacity(int count) {  //заранее узнает сможет ли поместиться определенное количество предметов БЕЗ УЧЕТА ВЕСА
    if (getCapacity()+count<=capacity) 
      return true;
    else
      return false;
  }
  int getFreeCapacity() {
    return capacity-getCapacity();
  }
  void drawIndicator(boolean status) {
    if (status)
      fill(green);
    else
      fill(red);
    stroke(black);
    pushMatrix();
    translate(-world.size_grid/2, -world.size_grid/2);
    rect(19, 15, 5, 5);
    popMatrix();
  }
  public void draw() {
    super.draw();
    if (isFreeCapacity()) 
      drawIndicator(true);
    else 
    drawIndicator(false);
  }
}
class WorkObjectList extends ArrayList <WorkObject> {

  WorkObject getItemById(int id) {
    for (WorkObject object : this) {
      if (object instanceof ItemMap) {
        if (((ItemMap)object).item==id) 
          return object;
      }
    }
    return null;
  }
  WorkObjectList getItemsById(int id) {
    WorkObjectList objects= new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof ItemMap) {
        if (((ItemMap)object).item==id)
          objects.add(object);
      }
    }
    return objects;
  }
  WorkObjectList getIsItem(int id) {
    WorkObjectList objects= new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Container) {
        Container container = (Container)object;
        if (container.items.calculationItem(id)>0) {
          objects.add(object);
        }
      }
    }
    return objects;
  }
  WorkObject getNearestObject(int x, int y) {
    float [] dist=new float [this.size()];
    for (int i=0; i<this.size(); i++) {
      int [] xyPart = world.room.getAbsCoordObject(this.get(i));
      dist[i]=dist(xyPart[0], xyPart[1], x, y);
    }
    for (WorkObject part : this) {
      int [] xyPart = world.room.getAbsCoordObject(part);
      float tdist = dist(xyPart[0], xyPart[1], x, y);
      if (tdist==min(dist)) 
        return part;
    }
    return null;
  }
  WorkObjectList getObjectsAllowMove(Worker worker) {  //возвращает объекты для которых разрешено перемещение
    WorkObjectList objects= new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Terminal) {
        int [] place = world.getPlace(object.getX(), object.getY(), object.direction);
        if (place[0]>=0 && place[1]>=0 && place[0]<world.room.sizeX && place[1]<world.room.sizeY) {
          if (getPathTo(world.room.node[worker.x][worker.y], world.room.node[place[0]][place[1]])!=null) 
            objects.add(object);
        }
      } else {
        int [] xyObject = world.room.getAbsCoordObject(object);
        GraphList neighbor = getNeighboring(world.room.node[xyObject[0]][xyObject[1]], null);
        if (neighbor.size()>0) {
          Graph target = neighbor.getNearestGraph(worker.x, worker.y);
          if (getPathTo(world.room.node[worker.x][worker.y], world.room.node[target.x][target.y])!=null) 
            objects.add(object);
        }
      }
    }
    return objects;
  }
    WorkObjectList getObjectsWorking() {  //возвращает объекты незаблокированные другой работой
    WorkObjectList objects= new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Terminal) {
        if (((Terminal)object).hp>0)
        objects.add(object);
      }
    }
    return objects;
  }
  WorkObjectList getObjectsAllowJob() {  //возвращает объекты незаблокированные другой работой
    WorkObjectList objects= new WorkObjectList();
    for (WorkObject object : this) {
      if (object.job==null)
        objects.add(object);
    }
    return objects;
  }
  WorkObjectList getObjectsAllowWeight(int weight) {  //возвращает объекты которые может перенести
    WorkObjectList objects= new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof ItemMap) {
        if (data.getItem(((ItemMap)object).item).weight<=weight)  
          objects.add(object);
      }
    }
    return objects;
  }
  WorkObjectList getObjectsAllowProducts() {  //возвращает объекты в которых необходима работа
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Terminal) {
        if (((Terminal)object).product!=-1 && ((Terminal)object).label==null) 
          objects.add(object);
      }
    }
    return objects;
  }
  WorkObjectList gerObjectAllowRepair() {  //возвращает объекты которым необходим ремонт
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Terminal) {
        if (((Terminal)object).hp< data.objects.getId(object.id).maxHp)
          objects.add(object);
      }
    }
    return objects;
  }
  WorkObjectList getContainers() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Container) 
        objects.add(object);
    }
    return objects;
  }
  WorkObjectList getObjectsEntryItems() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Container || object instanceof ItemMap) 
        objects.add(object);
    }
    return objects;
  }
  WorkObjectList getContainersFreeCapacity() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Container) {
        Container container = (Container)object;
        if (container.getFreeCapacity()>0)
          objects.add(object);
      }
    }
    return objects;
  }
  WorkObjectList getWorkObjects() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Terminal) 
        objects.add(object);
    }
    return objects;
  }
  WorkObjectList getTerminals() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (!(object instanceof Workbench) && !(object instanceof DevelopBench)) 
        objects.add(object);
    }
    return objects;
  }
  WorkObjectList getWorkBenches(int type) {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Workbench) {
        if (data.objects.getId(((Workbench)object).id).type==type)
          objects.add(object);
      }
    }
    return objects;
  }
  WorkObjectList getWorkBenches() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Workbench) 
        objects.add(object);
    }
    return objects;
  }
  WorkObjectList getDevelopBenches() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof DevelopBench) 
        objects.add(object);
    }
    return objects;
  }
  WorkObjectList getItems() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof ItemMap) 
        objects.add(object);
    }
    return objects;
  }
  WorkObjectList getNoItemMap() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (!(object instanceof ItemMap)) 
        objects.add(object);
    }
    return objects;
  }
}
