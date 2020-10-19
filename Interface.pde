SimpleButton buttonCreate, buttonCreate1, buttonCreate10, buttonCreateBack1, buttonCreateBack10, buttonCancelProduct, buttonOpenOrder, buttonCloseOrder;
RadioButton menuMain, menuTasker, menuContainer, menuOrders;
SimpleRadioButton buttonInfo, buttonManager, buttonMaintenance, buttonCargo, buttonTask; 
Listbox buildings, productsList, items, orders;
Text textConsole;
WindowLabel wMessage;

void setupInterface() {
  textConsole = new Text (192, 352, width-192-10, height-352, white, color(60));

  buildings=new Listbox(512, 63, 256, 288, Listbox.OBJECTS);
  buildings.loadObjects(data.objects);

  items=new Listbox(194, 32, 384, 320, Listbox.ITEMS);
  orders=new Listbox(194, 66, 604, 288, Listbox.ORDERS);
  productsList=new Listbox(512, 158, 287, 192, Listbox.ITEMS);

  buttonInfo = new SimpleRadioButton("информация", "getInfo"); 
  buttonManager=new SimpleRadioButton("управление", "getManager");
  buttonCargo=new SimpleRadioButton("содержит", "getCargo");
  buttonTask=new SimpleRadioButton("задачи", "getTasks");
  buttonMaintenance=new SimpleRadioButton("обслуживание", "getMaintenance");


  menuMain = new RadioButton (0, 32, 192, 190, RadioButton.VERTICAL);  //главное меню
  menuMain.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("объекты", "showObjects"), 
    new SimpleRadioButton("постройки", "showBuildings"), 
    new SimpleRadioButton("склад", "showItems"), 
    new SimpleRadioButton("компания", "showMenuCompany"), 
    new SimpleRadioButton("заказы", "showOrders"), 
    new SimpleRadioButton("меню", "showMenu")});
  menuContainer=new RadioButton (512, 32, 287, 123, RadioButton.VERTICAL);
  menuContainer.addButtons(new SimpleRadioButton [] {buttonInfo.clone(), buttonManager.clone(), buttonMaintenance.clone(), buttonCargo.clone()});
  menuTasker=new RadioButton (512, 32, 287, 123, RadioButton.VERTICAL);
  menuTasker.addButtons(new SimpleRadioButton [] {buttonInfo.clone(), buttonManager.clone(), buttonMaintenance.clone(), buttonTask.clone()});


  //специальный функционал для переключения скроллинг списка
  Runnable resetScroll = new Runnable() {
    public void run() {
      orders.resetScroll();
    }
  };
  menuOrders = new RadioButton (194, 32, 604, 32, RadioButton.HORIZONTAL);  //главное меню
  menuOrders.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("новые", "showAllOrders", resetScroll), 
    new SimpleRadioButton("открытые", "showOpenOrders", resetScroll), 
    new SimpleRadioButton("закрытые", "showCloseOrders", resetScroll), 
    new SimpleRadioButton("проваленные", "showFailOrders", resetScroll)});


  //создание кнопок 
  buttonCreate = new SimpleButton(230, 550, 192, 32, data.label.get("button_create"), new Runnable() {
    public void run() {
      Object object =world.room.currentObject; 
      Database.DataObject product = data.items.getId(productsList.select.id);
      if (object instanceof Terminal) {
        boolean purchase=false, useItem=false, develop=false, start=false; 
        Terminal terminal = (Terminal) object;
        if (!(terminal instanceof DevelopBench)) {
          if (terminal instanceof Workbench)
          useItem = true;
          else 
          purchase=true;
        } else 
        develop=true;
        if (useItem) {  
          if (world.room.getItems(Item.ALL).isItems(product.reciept, terminal.count_operation)) {//проверяет есть ли предметы на складах
            world.room.removeItems(product.reciept, terminal.count_operation); //использует предметы 
            start=true;
          } else 
          wMessage = new WindowLabel("не хватает: "+world.room.getItems(Item.ALL).getNeedItems(product.reciept, terminal.count_operation).getNames());
        } else if (purchase) {
          float sum_money = product.cost*terminal.count_operation;
          if (sum_money<=world.company.money) {
            world.company.money-=sum_money;
            start=true;
          } else
            wMessage = new WindowLabel("не хватает средств");
        } else if (develop) {
          if (product.cost_develop<world.company.money) {
            world.company.money-=product.cost_develop;
            start=true;
          } else 
          wMessage = new WindowLabel("не хватает средств");
        }
        if (start) {
          terminal.product=new Item(product.id);
          terminal.progress=0;
        }
      }
    }
  }
  );
  buttonCreate1 = new SimpleButton(230, 517, 64, 32, "+1", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.count_operation++;
      }
    }
  }
  );
  buttonCreate10 = new SimpleButton(296, 517, 64, 32, "+10", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.count_operation+=10;
      }
    }
  }
  );
  buttonCreateBack1 = new SimpleButton(362, 517, 64, 32, "-1", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.count_operation--;
      }
    }
  }
  );
  buttonCreateBack10 = new SimpleButton(428, 517, 64, 32, "-10", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.count_operation-=10;
      }
    }
  }
  );
  buttonCancelProduct= new SimpleButton(230, 550, 192, 32, data.label.get("button_cancel"), new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.removeLabel();
        terminal.product=null;
      }
    }
  }
  );
  buttonOpenOrder = new SimpleButton(570, 380, 193, 32, "открыть заказ", new Runnable() {
    public void run() {
      Order order = world.orders.getOrder(orders.select.id);
      world.company.opened.add(order);
      world.orders.remove(order);
    }
  }
  );
  buttonCloseOrder = new SimpleButton(570, 380, 193, 32, "закрыть заказ", new Runnable() {
    public void run() {
      Order order = world.company.opened.getOrder(orders.select.id);
      if (order!=null) {
        if (order.isComplete()) {
          world.room.removeItems(order.product.id, order.count);
          world.company.opened.remove(order);
          world.company.closed.add(order);
          world.company.money+=order.cost;
        } else
          wMessage = new WindowLabel("не выполнены условия");
      }
    }
  }
  );
  //  components.add(buttonCreate, buttonCreate1, buttonCreate10);
}

ArrayList <ScaleActiveObject> components = new ArrayList <ScaleActiveObject>();



void updateInterface() {

  buttonCreate.setActive(false);
  buttonCreate1.setActive(false);
  buttonCreate10.setActive(false);
  buttonCreateBack1.setActive(false);
  buttonCreateBack10.setActive(false);
  buttonCancelProduct.setActive(false);
  buttonOpenOrder.setActive(false);
  buttonCloseOrder.setActive(false);
  textConsole.setActive(false);
  menuContainer.setActive(false);
  menuOrders.setActive(false);
  menuTasker.setActive(false);
  buildings.setActive(false);
  orders.setActive(false);
  productsList.setActive(false);
  items.setActive(false);

  menuMain.control();


  fill(white);
  if (menuMain.select.event.equals("showObjects")) {
    world.room.setActiveLabels(true);
    world.setActive(true);
    WorkObject object = world.room.currentObject;
    if (object!=null) {
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        menuTasker.control();
        String event= menuTasker.select.event;
        if (event.equals("getInfo")) {
          textConsole.loadText(terminal.getDescript());
          textConsole.setActive(true);
        } else if (event.equals("getTasks")) {
          if (terminal.products!=null) {
            if (terminal.products.size()>0) 
              productsList.loadComponents(terminal.products);
            else {
              productsList.items.clear();
              productsList.select=null;
            }
          } else {
            productsList.items.clear();
            productsList.select=null;
          }
          if (terminal.product==null)
            productsList.setActive(true);
          if (productsList.select!=null) {
            if (terminal.count_operation==0)
              terminal.count_operation=1;
            showScaleText(terminal.getDescriptTask(), 197, 370);  
            if (terminal.product==null) {
              if (terminal instanceof DevelopBench) 
                buttonCreate.text="разработать";
              else {
                if (terminal instanceof Workbench) 
                  buttonCreate.text="изготовить";
                else
                  buttonCreate.text="закупить";
                buttonCreate1.setActive(true);
                buttonCreate10.setActive(true);
                if (terminal.count_operation>0) {
                  if (terminal.count_operation>1)
                    buttonCreateBack1.setActive(true);
                  if (terminal.count_operation>10)
                    buttonCreateBack10.setActive(true);
                }
              } 
              buttonCreate.setActive(true);
            } else {
              if (terminal.product.id==productsList.select.id)
                buttonCancelProduct.setActive(true);
              else
                buttonCreate.setActive(true);
            }
          }
        }
      } else if (object instanceof Container) {
        menuContainer.control();
        String event= menuContainer.select.event;
        Container container = (Container) object;
        if (event.equals("getCargo")) {


          if (container.items.size()>0) 
            productsList.loadItems(container.items);
          else {
            productsList.items.clear();
            productsList.select=null;
          }
          productsList.setActive(true);

          textConsole.loadText(container.getCapacityDescript());
          textConsole.setActive(true);
        }
      }
    } else {
      textConsole.loadText(data.label.get("selected_object"));
      textConsole.setActive(true);
    }
  } else if (menuMain.select.event.equals("showMenuCompany")) {
    world.setActive(false);
    world.room.setActiveLabels(false);
    showScaleText(world.company.getInfo(), 215, 50);
  } else if (menuMain.select.event.equals("showOrders")) {
    menuOrders.control();
    world.setActive(false);
    world.room.setActiveLabels(false);
    orders.setActive(true);
    if (menuOrders.select.event.equals("showAllOrders")) 
      orders.loadOrders(world.orders);
    else  if (menuOrders.select.event.equals("showOpenOrders"))
      orders.loadOrders(world.company.opened);
    else  if (menuOrders.select.event.equals("showCloseOrders"))
      orders.loadOrders(world.company.closed);
    else  if (menuOrders.select.event.equals("showFailOrders"))
      orders.loadOrders(world.company.failed);
    if (orders.select!=null) {
      textConsole.loadText(orders.getSelectInfo());
      if (menuOrders.select.event.equals("showAllOrders"))
        buttonOpenOrder.setActive(true);
      else if (menuOrders.select.event.equals("showOpenOrders"))
        buttonCloseOrder.setActive(true);
    } else
      textConsole.loadText(data.label.get("selected_order"));
    textConsole.setActive(true);
  } else if (menuMain.select.event.equals("showItems")) {
    world.room.setActiveLabels(false);
    world.setActive(false);
    items.loadItems(world.room.getItems(Item.ALL));
    if (items.select!=null)
      textConsole.loadText(items.getSelectInfo());
    else
      textConsole.loadText(data.label.get("selected_item"));
    items.setActive(true);
    textConsole.setActive(true);
  } else if (menuMain.select.event.equals("showBuildings")) {
    world.room.setActiveLabels(false);
    world.room.currentObject=null;
    world.setActive(true);
    if (buildings.select!=null)
      textConsole.loadText(buildings.getSelectInfo());
    else
      textConsole.loadText(data.label.get("selected_object"));
    textConsole.setActive(true);    
    buildings.setActive(true);
    if (buildings.select!=null && world.hover) {
      world.newObj = data.objects.getId(buildings.select.id);
    }
    showScaleText("постройки: "+world.room.getAllObjects().size()+"/"+world.company.buildingLimited, 518, 56);
  }

  showScaleText("$: "+str(world.company.money), 16, 25);
  showScaleText("время и дата: "+world.date.getDate(), 192, 25);
  text("FPS: "+int(frameRate)+"\n"
    +"mouse x: "+mouseX+"\n"
    +"mouse y: "+mouseY+"\n" 
    +"mouse abs x: "+world.getAbsCoordX()+"\n"
    +"mouse abs y: "+world.getAbsCoordY()+"\n" 
    +"screen_width: "+width+"\n"
    +"screen_height: "+height+"\n"
    +"object: "+world.getObjectInfo()+"\n"
    , 5, 380);


  if (wMessage!=null)
    wMessage.setActive(true);
}

class ScaleActiveObject extends ActiveElement {
  int level;

  ScaleActiveObject(float xx, float yy, float ww, float hh) {
    super(xx, yy, ww, hh);
    level = 0;
  }
  ScaleActiveObject(float xx, float yy, float ww, float hh, int level) {
    this(xx, yy, ww, hh);
    this.level = level;
  }
  boolean isActiveSelect() {
    if (level==world.level)
      return true;
    else return false;
  }

  boolean isInside(float xx, float yy) {
    if ((xx>x*getScaleX() && xx<x*getScaleX()+width*getScaleX()) &&
      (yy>y*getScaleY() && yy<y*getScaleY()+height*getScaleY()))
      return true;
    else 
    return false;
  }
}

class RadioButton extends ScaleActiveObject {
  int orientation;
  SimpleRadioButton select;
  ArrayList <SimpleRadioButton> buttons= new ArrayList <SimpleRadioButton>();
  final static int HORIZONTAL = 0;
  final static int VERTICAL= 1;

  RadioButton  (int x, int y, int widthObj, int  heightObj, int orientation) {
    super(x, y, widthObj, heightObj);
    this.orientation = constrain(orientation, 0, 1);
    select=null;
  }

  public void addButton(SimpleRadioButton button) {
    buttons.add(button);
    update();
  }

  public void control () {
    setActive(true); 
    for (SimpleRadioButton button : buttons) {
      if (button.pressed && button.isActiveSelect()) 
        setSelect(button);
    }
  }
  public void setActive(boolean active) {
    super.setActive(active);
    for (SimpleRadioButton button : buttons)
      button.setActive(active);
  }

  public void addButtons(SimpleRadioButton [] buttons) {
    this.buttons.clear();
    for (SimpleRadioButton button : buttons)
      this.buttons.add(button);
    update();
  }

  private void update() {
    for (int i=0; i<buttons.size(); i++) {
      SimpleRadioButton button = buttons.get(i);
      if (orientation==HORIZONTAL) {
        int widthButton = (int)width/buttons.size();
        button.width=widthButton;
        button.height=height;
        button.y=y;
        button.x=x+i*(widthButton+1);
      } else if (orientation==VERTICAL) {
        int heightButton =  (int)height/buttons.size();
        button.height=heightButton;
        button.width=width;
        button.x=x;
        button.y=y+i*(heightButton+1);
      }
    }
    setSelect(buttons.get(0));
  }

  protected void setSelect(SimpleRadioButton button) {
    select=button;
    for (SimpleRadioButton part : buttons) {
      if (part.equals(select)) 
        part.on=true;
      else 
      part.on=false;
    }
  }
}


class SimpleButton extends ScaleActiveObject {
  boolean on;
  String text;
  Runnable script;

  SimpleButton (float x, float y, float w, float h, String text, Runnable script, int level) {
    this(x, y, w, h, text, script);
    this.level=level;
  }

  SimpleButton (float x, float y, float w, float h, String text, Runnable script) {
    super(x, y, w, h);
    this.text=text;
    this.script=script;
    level=0;
  }
  void mousePressed () {
    if (script!=null)
      script.run();
  }
  void draw () {
    pushMatrix();
    scale(getScaleX(), getScaleY());
    pushStyle();  
    if (hover && isActiveSelect())
      if (mousePressed) 
        stroke(color(90));
      else 
      stroke(white);
    else noStroke();
    if ( on ) fill( white );
    else fill(black);
    rect(x, y, width, height);
    strokeWeight(1);
    textAlign(CENTER, CENTER);
    if ( on ) fill(black);
    else fill(white);
    textSize(18);
    text(text, x+this.width/2, y+this.height/2-textDescent());
    popStyle();
    popMatrix();
  }
}

class SimpleRadioButton extends SimpleButton {
  String event;

  SimpleRadioButton (String text, String event, Runnable script) {
    this(text, event);
    this.script=script;
  }
  SimpleRadioButton (String text, String event) {
    super(-600, -600, 1, 1, text, null);  
    this.event=event;
  }
  void mouseClicked () {
    if (mouseButton==LEFT)
      on=!on;
  }
  public SimpleRadioButton clone() {
    return new SimpleRadioButton (text, event, script);
  }
}

class Listbox extends ScaleActiveObject {
  ArrayList <ListItem> items;
  float itemHeight = 32;
  int entry=30;
  int listStartAt = 0;
  int hoverItem = -1;
  ListItem select=null;
  float valueY = 0;
  boolean hasSlider = false;
  static final int ITEMS=0, OBJECTS=1, ORDERS=2;

  Listbox (float x, float y, float w, float h, int entry) {
    super(x, y, w, h);
    this.entry=entry;
    valueY =y;
    items = new ArrayList <ListItem> ();
  }

  class ListItem {
    int id;
    String label;
    PImage sprite;
    ListItem (int id, String label, PImage sprite) {
      this(id, label);
      this.sprite=sprite;
    }
    ListItem (int id, String label) {
      this.id=id;
      this.label=label;
      sprite=null;
    }
  }

  private int getPrevSelect() {

    int prev_select = 0;
    if (items!=null) {
      if (select!=null)
        prev_select=constrain(items.indexOf(select), 0, items.size()-1);
      else 
      prev_select=-1;
      items.clear();
    }

    return prev_select;
  }

  private void setPrevSelect(int prev_select) {
    if (prev_select==-1 || items.isEmpty()) 
      select=null;
    else
      select= items.get(constrain(prev_select, 0, items.size()-1));
  }

  void loadItems(ItemList list) {
    int prev_select = getPrevSelect();
    for (int part : list.sortItem()) {
      Item item = list.getItem(part);
      addItem(data.items, item.name+" ("+list.calculationItem(part)+")", part);
    }
    setPrevSelect(prev_select);
  }
  void loadOrders(OrderList list) {
    int prev_select = getPrevSelect();
    for (Order part : list) 
      addItem(part.label, part.id, data.items.getId(part.product.id).sprite);
    setPrevSelect(prev_select);
  }
  void loadObjects(Database.DatabaseObjectList objects) {
    int prev_select = getPrevSelect();
    for (Database.DataObject part : objects)
      addItem(objects, part.name, part.id);
    setPrevSelect(prev_select);
  }

  void loadComponents(ComponentList list) {
    int prev_select = getPrevSelect();
    for (int part : list.sortItem()) 
      addItem(data.items, list.data.getId(part).name, part);
    setPrevSelect(prev_select);
  }

  public void addItem (Database.DatabaseObjectList data, String item, int id) {
    items.add(new ListItem (id, item, data.getId(id).sprite));
    hasSlider = items.size() * itemHeight*getScaleY() > this.height*getScaleY();
  }
  public void addItem (String item, int id, PImage sprite) {
    items.add(new ListItem (id, item, sprite));
    hasSlider = items.size() * itemHeight*getScaleY() > this.height*getScaleY();
  }
  public void mouseMoved ( float mx, float my ) {
    if (hasSlider && mx > (x+this.width-20)*getScaleX()) return;
    if (hover)
      hoverItem = listStartAt + int((my-y*getScaleY()) / (itemHeight*getScaleY()));
  }
  public void mouseExited ( float mx, float my ) {
    hoverItem = -1;
  }
  void mouseDragged (float mx, float my) {
    if (!hasSlider ) return;
    if (mx < x+this.width-20) return;
    valueY = my-itemHeight;
    valueY = constrain(valueY, y, y+this.height-itemHeight);
    update();
  }
  void mouseScrolled (float step) {
    if (items.size()*itemHeight>height && hover) {
      valueY += step*itemHeight;
      valueY = constrain(valueY, y, y+this.height-itemHeight);
      update();
    }
  }
  void resetScroll() {
    valueY=y;
    update();
  }
  void update () {
    float totalHeight = items.size() * itemHeight;
    float listOffset = (map(valueY, y, y+this.height-itemHeight, 0, totalHeight-this.height));
    listStartAt = int( listOffset / itemHeight );
  }
  public void mousePressed ( float mx, float my ) { 
    if (isActiveSelect()) {
      if (this.items==null) return;
      if (this.items.isEmpty()) return;
      if (hasSlider && mx > (x+this.width-20)*getScaleX()) return;
      int pressed=listStartAt + int((my-y*getScaleY())/(itemHeight*getScaleY()));
      if (pressed<=this.items.size()-1)
        select = items.get(constrain(pressed, 0, items.size()-1));
      else 
      select=null;
    }
  }
  boolean hoverNoSlider() {
    if (mouseX<(x+width-20)*getScaleX())
      return true;
    else 
    return false;
  }
  String getSelectInfo() {
    if (select!=null) {
      String description ="";
      if (entry==OBJECTS) {
        Database.DataObject dataObj = data.objects.getId(select.id);
        description = dataObj.description+", стоимость: "+dataObj.cost+" $";
      } else if (entry==ORDERS) {
        Order order = null;
        if (world.orders.getOrder(select.id)!=null)
          order=world.orders.getOrder(select.id);
        else if (world.company.opened.getOrder(select.id)!=null)
          order=world.company.opened.getOrder(select.id);
        else if (world.company.closed.getOrder(select.id)!=null)
          order=world.company.closed.getOrder(select.id);
        else if (world.company.failed.getOrder(select.id)!=null)
          order=world.company.failed.getOrder(select.id);
        if (order!=null)
          description=order.getDescript();
        else 
        description="нет данных";
      } else if (entry==ITEMS) {
        Database.DataObject dataObj = data.items.getId(select.id);
        description = dataObj.description;
        if (dataObj.reciept!=null) {
          ComponentList reciept = dataObj.reciept;
          if (reciept.size()>0)       
            description+=", "+data.label.get("reciept")+": "+reciept.getNames()+
              " , количество на выходе: "+dataObj.count_operation+
              ", сложность разработки: "+dataObj.complexity+
              ", трудоёмкость изготовления: "+dataObj.scope_of_operation;
        }
        description+=", стоимость: "+dataObj.cost+" $";
      }
      return data.label.get("description")+": "+description;
    } else 
    return data.label.get("no_text");
  }
  void draw () { 
    pushMatrix();
    scale(getScaleX(), getScaleY());
    stroke(white);
    noFill();
    rect(x, y, this.width, this.height);
    clip(x*getScaleX(), y*getScaleY(), this.width*getScaleX(), this.height*getScaleY());
    if ( items != null ) {
      for (int i = 0; i < int(this.height/itemHeight) && i <items.size(); i++) {
        stroke(white);
        if (i+listStartAt==items.indexOf(select))
          fill(white);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider() && isActiveSelect()) ? white : black);
        rect(x, y + (i*itemHeight), this.width, itemHeight);
        noStroke();
        if (i+listStartAt==items.indexOf(select))
          fill(black);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider() && isActiveSelect()) ? black : white);
        PImage image = items.get(constrain(i+listStartAt, 0, items.size()-1)).sprite;
        int h=5;
        if (image!=null) {
          image(image, x+1, y+(i+1)*itemHeight-32);
          h+=32;
        }
        text(items.get(constrain(i+listStartAt, 0, items.size()-1)).label, x+h, y+(i+1)*itemHeight-5 );
      }
    }
    noClip();
    if (hasSlider) {
      stroke(white);
      fill(black);
      rect(x+this.width-20, y, 20, this.height);
      fill(white);
      rect(x+this.width-20, valueY, 20, 20);
    }
    popMatrix();
  }
}

class Text extends ScaleActiveObject {
  String text;
  color text_color, background_color;
  float yT, grid_size;
  StringList texts = new StringList ();

  Text (int x, int y, int widthObj, int  heightObj, color text_color, color background_color) {
    super(x, y, widthObj, heightObj);
    this.text=null;
    this.background_color=background_color;
    this.text_color=text_color;
    yT=0;
    grid_size=30;
  }
  public void clear() {
    text=null;
    texts.clear();
  }
  public void loadText(String text) {
    this.text=text;
    texts.clear();
    text+=" ";
    String [] str= split(text, " ");
    if (str.length==1) 
      texts.append(text);
    int current_str=0;
    for (int i=0; i<str.length-1; i++) {
      String part = str[i], current, newStr;
      if (texts.size()>0 && current_str<texts.size()) {
        current = texts.get(current_str);
        newStr = current+" "+part;
      } else {
        current = "";
        newStr = part;
      }
      if (textWidth(newStr)<width) 
        texts.set(current_str, newStr);
      else {
        texts.append(part);
        current_str++;
      }
    }
    //  if (current_str<prevLine)  узнать назначение и убрать
    //  yT=0;
  }
  protected float getTextHeight() {
    return getTextNumStr()*grid_size*getScaleY();
  }
  protected int getTextNumStr() {
    return texts.size();
  }
  public void draw() {
    pushMatrix();
    scale(getScaleX(), getScaleY());
    pushStyle(); 
    fill(text_color);
    textLeading(grid_size);
    clip(x*getScaleX(), y*getScaleY(), (width+1)*getScaleX(), (height+1)*getScaleY());
    if (text!=null) {
      if (getTextHeight()>height) 
        rect(x+width-3, y-map(yT, 0, getTextHeight(), 0, height), 3, map(height/getTextNumStr(), 0, getTextHeight(), 0, height)*getTextNumStr());
      int yt=int(y+grid_size+yT );
      for (int i=0; i<texts.size(); i++) {
        String current = texts.get(i);
        if (current!=null) {       
          text(current, (x+8), yt);
          yt+=grid_size;
        }
      }
    }
    noClip();
    popStyle();
    popMatrix();
  }
  void mouseScrolled(float step) {
    if (step==-1) {
      if (getTextHeight()>=height*getScaleY())
        yT=constrain(yT+=10, -getTextHeight(), 0);
    } else if (step==1) {
      if (getTextHeight()>=height*getScaleY())
        yT=int(constrain(yT-=10, -(getTextHeight()-height*getScaleY())-10, 0));
    }
  }
}

class WindowLabel extends ActiveElement {
  String message, input;

  SimpleButton buttonOk;

  WindowLabel (String message) {
    super(200, 200, 400, 200);
    this.message=message;
    world.input=false;
    world.pause=true;
    world.level=1;
    buttonOk = new SimpleButton(x+width/2-63, y+height-64, 128, 32, "принято", new Runnable() {
      public void run() {
        if (wMessage!=null) {
          wMessage.close();
          wMessage=null;
        }
      }
    }
    , 1);
  }
  public void close() {
    world.input=true;
    world.pause=false;
    buttonOk.setActive(false);
    buttonOk=null;
    world.level=0;
    setActive(false);
  }
  void draw() {
    pushMatrix();  
    pushStyle();
    translate(x*getScaleX(), y*getScaleY());
    scale(getScaleX(), getScaleY());

    fill(black);
    stroke(white);
    rect(0, 0, width, height);
    fill(white);
    textAlign(CENTER);
    text(message, width/2, height/2);
    popStyle();
    popMatrix();
  }
}

void showScaleText(String text, float x, float y) {
  pushMatrix();   
  translate(x*getScaleX(), y*getScaleY());
  scale(getScaleX(), getScaleY());
  text(text, 0, 0);
  popMatrix();
}

float getScaleX() {
  return (context.width/float(_sizeX));
}
float getScaleY() {
  return (context.height/float(_sizeY));
}
