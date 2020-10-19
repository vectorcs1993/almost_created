interface executing {
}

abstract class WorkObject {
  int id, progress;
  PImage sprite;
  String name;
  Timer timer; 
  static final int CONTAINER = 0, TERMINAL = 14, WORKBENCH=16, DEVELOPBENCH =17, FOUNDDRY =18;


  WorkObject(int id) {
    this.id=id; 
    sprite=getSpriteDatabase();
    name = getNameDatabase();
    timer = new Timer();
  }
  protected float getTick() {
    return 1000;
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



class Terminal extends WorkObject implements executing {
  float hp, hp_max, wear, speed;
  Item product;
  WorkLabel label;
  ComponentList products;
  int count_operation;

  Terminal (int id) {
    super(id);
    label=null;
    progress=0;
    product=null;
    products = new ComponentList(data.items);
    products = data.objects.getId(id).products;
    hp_max=100;
    hp=hp_max;
    wear=0.12;
    speed=60;
    count_operation=0;
  }
  color getColor() {
    return blue;
  }
  String getDescriptTask() {
    return "количество: "+count_operation+"\n"
      +"суммарная стоимость: "+count_operation*data.items.getId(productsList.select.id).cost+"$\n"+
      getProductDescript();
  }
  String getProductDescript() {
    if (product!=null) {
      if (label==null)
        return "доставка товара: "+product.name+" ("+progress+"/"+getMaxProgress()+")"+"\n";
      else 
      return product.name+" доставлен";
    } else
      return "не выбран товар для доставки"+"\n";
  }


  protected float getTick() {
    return speed;
  }
  boolean getNewProduct() {
    return false;
  }
  int getMaxProgress() {
    return 120;
  }

  public void update() {
    speed=constrain(speed, 0, 1000);
    hp=constrain(hp, 0, 100);
    wear=constrain(wear, 0.01, 0.5);
    if (product!=null) {
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
      "состояние"+": "+hp+"/"+hp_max+"\n"+
      "скорость"+": "+map(speed, 1000, 0, 0, 100)+"\n"+
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
    return "количество операций: "+count_operation+"\n"
      +"суммарное количество: "+count_operation*data.items.getId(productsList.select.id).count_operation+"\n"
      +"суммарная трудоёмкость: "+count_operation*data.items.getId(productsList.select.id).scope_of_operation+"\n"
      +"компоненты: "+data.items.getId(productsList.select.id).reciept.getNames(count_operation)+"\n"+
      getProductDescript();
  }
  String getProductDescript() {
    if (product!=null) {
      if (label==null)
        return "изделие: "+product.name+" ("+progress+"/"+getMaxProgress()+")"+"\n";
      else 
      return product.name+" изготовлено";
    } else
      return "нет задания на изготовление"+"\n";
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
    return product.complexity;
  }
  String getDescriptTask() {
    return "сложность разработки: "+data.items.getId(productsList.select.id).complexity+"\n"+
      "стоимость разработки: "+data.items.getId(productsList.select.id).cost_develop+"$\n"+
      getProductDescript();
  }
  String getProductDescript() {
    if (product!=null) {
      if (label==null)
        return "чертеж на: "+product.name+" ("+progress+"/"+getMaxProgress()+")"+"\n";
      else 
      return product.name+" разработан";
    } else
      return "нет задания на разработку"+"\n";
  }
}

class Container extends WorkObject {
  int capacity;
  ItemList items;

  Container (int id) {
    super(id);
    items = new ItemList();
    capacity = 20;
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
