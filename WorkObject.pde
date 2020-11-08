abstract class WorkObject {
  int id, progress;
  PImage sprite;
  String name;
  Timer timer; 
  static final int CONTAINER = 0, TERMINAL = 14, WORKBENCH=16, DEVELOPBENCH =17, FOUNDDRY =18, SAW_MACHINE =19, STONE_CARVER =20, WORKSHOP_MECHANICAL =21;


  WorkObject(int id) {
    this.id=id; 
    sprite=getSpriteDatabase();
    name = getNameDatabase();
    timer = new Timer();
  }
  protected float getTick() {
    return world.date.getTick();
  }
  protected void tick() {
    if (!timer.check()) {
      update();
      timer.set(getTick());
    }
  }
  public void update() {
  }
  public void draw() {
    image(sprite, 0, 0);
  }
  public void drawSelected() {
    pushStyle();
    noFill();
    stroke(green);
    strokeWeight(3);
    rect(0, 0, world.size_grid, world.size_grid);
    popStyle();
  }
  protected PImage getSpriteDatabase() {
    return data.objects.getId(id).sprite;
  }
  protected String getNameDatabase() {
    return data.objects.getId(id).name;
  }

  abstract protected String getDescript();
}



class Terminal extends WorkObject {
  float hp, hp_max, wear, speed;
  Item product;
  WorkLabel label;
  ComponentList products;
  int count_operation;
  private float refund;
  
  Terminal (int id) {
    super(id);
    label=null;
    progress=0;
    product=null;
    products = new ComponentList(data.items);
    products = data.objects.getId(id).products;
    hp_max=100;
    hp=hp_max;
    wear=0.1;
    speed=60;
    count_operation=0;
    refund=0;
  }
  color getColor() {
    return blue;
  }
  String getDescriptTask() {
    Database.DataObject item = data.items.getId(productsList.select.id);
    if (item.pool>0) {
    return "количество: "+count_operation+"\n"
      +"цена: "+getDecimalFormat(count_operation*item.getCostForPool())+" $\n"
      +"пул: "+item.pool+"\n";
    } else 
    return "недоступно";
  }
  String getProductDescript() {
    if (label==null)
      return "доставка товара: "+product.name+" ("+progress+"/"+getMaxProgress()+")"+"\n";
    else 
    return product.name+" доставлен";
  }


  protected float getTick() {
    return speed;
  }
  boolean getNewProduct() {
    return false;
  }
  int getMaxProgress() {
    return 100+100/count_operation;
  }

  public void update() {
    speed=constrain(speed, 0, 1000);
    hp=constrain(hp, 0, 100);
    wear=constrain(wear, 0.01, 0.5);

    if (product!=null) {
      if (hp>0) {
        if (label==null) {
          progress++;
          hp-=wear;
          if (progress>=getMaxProgress()) {
            float x=world.room.getCoordObject(this)[0];
            float y=world.room.getCoordObject(this)[1];
            float size=world.room.getCoordObject(this)[2];
            label=new WorkLabel(x-10, y-10, size, size, product, product.count_operation*count_operation, getNewProduct(), getColor());
            if (!menuMain.select.event.equals("showObjects")) 
              label.setActive(false);
            progress=0;
          }
        }
      }
    }
  }
  public void removeLabel() {
    if (label!=null) {
      label.setActive(false);
      label=null;
      product=null;
    } 
    progress=0;
    count_operation=0;
  }
  public void drawStatus(int ty, float a, float b, color one, color two) {
    if (a<b) {
      pushStyle();
      strokeWeight(3);
      stroke(one);
      float xMax = map(a, 0, b, 2, world.size_grid-2);
      line(2, ty, xMax, ty);
      stroke(two);
      line(xMax, ty, world.size_grid-2, ty);
      popStyle();
    }
  }
  public void draw() {
    super.draw();
    if (product!=null) {
      if (progress>0)
        drawStatus(5, progress, getMaxProgress(), green, red);
    }
    if (hp<hp_max)
      drawStatus(9, hp, hp_max, blue, red);
  }
  protected String getDescript() {
    return "наименование"+": "+name+"\n"+
      "состояние"+": "+getDecimalFormat(hp)+"/"+hp_max+"\n";
  }
  protected String getCharacters() {
    return "скорость"+": "+map(speed, 1000, 0, 0, 100)+"\n"+
      "износостойкость"+": "+map(wear, 0.01, 0.5, 100, 0)+"\n";
  }
}

class Workbench extends Terminal {

  Workbench (int id) {
    super(id);
  }
  color getColor() {
    return black;
  }

  int getMaxProgress() {
    return product.scope_of_operation*count_operation;
  }
  String getDescriptTask() {
    Database.DataObject product = data.items.getId(productsList.select.id);
    return "операции: "+count_operation+"\n"
      +"изделия: "+count_operation*data.items.getId(productsList.select.id).count_operation+" шт.\n"
      +"трудоёмкость: "+count_operation*(product.scope_of_operation+product.reciept.getScopeTotal())+"\n";
  }
  String getProductDescript() {
      if (label==null)
        return "изделие: "+product.name+" ("+progress+"/"+getMaxProgress()+")"+"\n";
      else 
      return product.name+" изготовлено";
  }
}


class DevelopBench extends Workbench {
  DevelopBench (int id) {
    super(id);
  }
  color getColor() {
    return gray;
  }
  boolean getNewProduct() {
    return true;
  }
  int getMaxProgress() {
    return data.items.getId(product.id).reciept.getScopeTotal();
  }
  String getDescriptTask() {
    return "сложность: "+data.items.getId(productsList.select.id).reciept.getScopeTotal()+"\n"+
      "цена: "+data.items.getId(productsList.select.id).getCostDevelop()+"$\n";
  }
  String getProductDescript() {
      if (label==null)
        return "чертеж на: "+product.name+" ("+progress+"/"+getMaxProgress()+")"+"\n";
      else 
      return product.name+" разработан";
  }
}

class Container extends WorkObject {
  int capacity;
  ItemList items;

  Container (int id) {
    super(id);
    items = new ItemList();
    capacity = 200;
  }
  protected String getDescript() {
    return "наименование"+": "+name+"\n"
      // text_product+": "+isProductNull()+"\n"+
      // text_items+": "+components.getNames(data.items)+
      ;
  }

  public String getCapacityDescript() {    
    return "вместимость: "+getCapacity()+"/"+capacity;
  }
  public int getCapacity() {
    int capacity = 0;
    for (Item item : items) 
      capacity+=item.weight;
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

  public int getFreeCapacity() {
    return capacity-getCapacity();
  }
  public void drawIndicator(boolean status) {
    if (status)
      fill(green);
    else
      fill(red);
    stroke(black);
    rect(19, 15, 5, 5);
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


  public WorkObjectList getContainers() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Container) 
        objects.add(object);
    }
    return objects;
  }
  public WorkObjectList getTerminals() {
    WorkObjectList objects = new WorkObjectList();
    for (WorkObject object : this) {
      if (object instanceof Terminal) 
        objects.add(object);
    }
    return objects;
  }
}
