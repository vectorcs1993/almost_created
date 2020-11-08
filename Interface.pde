SimpleButton buttonCreate, buttonCreate1, buttonCreate10, buttonCreateBack1, buttonCreateBack10, buttonCancelProduct, buttonOpenOrder, buttonCloseOrder, buttonCancelOrder, 
  buttonPause, buttonStart, buttonRemoveObject, buttonRemoveItem, buttonRemoveAllItem, buttonRepair;
RadioButton menuMain, menuTasker, menuContainer, menuOrders, menuReciept;
SimpleRadioButton buttonInfo, buttonManager, buttonMaintenance, buttonTask; 
Listbox buildings, productsList, componentsList, items, orders, helpList;
Text textConsole;
WindowLabel wMessage;


void setupInterface() {
  textConsole = new Text (192, 362, width-192-10, height-342, white, color(60));

  buildings=new Listbox(512, 63, 286, 288, Listbox.OBJECTS);
  buildings.loadObjects(data.objects);
  items=new Listbox(194, 32, 384, 320, Listbox.ITEMS);
  orders=new Listbox(194, 66, 604, 288, Listbox.ORDERS);
  productsList=new Listbox(512, 202, 287, 192, Listbox.ITEMS);
  componentsList=new Listbox(512, 437, 287, 160, Listbox.ITEMS, -1);
  helpList=new Listbox(194, 66, 604, 288, Listbox.HELP_MESSAGE);
  helpList.loadHelpMessages(data.helpMessages);

  buttonInfo = new SimpleRadioButton("информация", "getInfo"); 
  buttonManager=new SimpleRadioButton("управление", "getManager");
  buttonTask=new SimpleRadioButton("задачи", "getTasks");
  buttonMaintenance=new SimpleRadioButton("обслуживание", "getMaintenance");


  menuMain = new RadioButton (0, 32, 192, 190, RadioButton.VERTICAL);  //главное меню
  menuMain.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("производство", "showObjects"), 
    new SimpleRadioButton("строительство", "showBuildings"), 
    new SimpleRadioButton("склад", "showItems"), 
    new SimpleRadioButton("компания", "showMenuCompany"), 
    new SimpleRadioButton("заказы", "showOrders"), 
    new SimpleRadioButton("помощь", "showHelp"), 
    new SimpleRadioButton("меню", "showMenu")});
  menuContainer=new RadioButton (513, 32, 286, 91, RadioButton.VERTICAL);
  menuContainer.addButtons(new SimpleRadioButton [] {buttonInfo.clone(), buttonManager.clone(), buttonMaintenance.clone()});
  menuTasker=new RadioButton (513, 32, 286, 123, RadioButton.VERTICAL);
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
    new SimpleRadioButton("отмененные", "showFailOrders", resetScroll)});
    
 menuReciept = new RadioButton (512, 397,287, 32, RadioButton.HORIZONTAL);  //главное меню
  menuReciept.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("компоненты", "showComponents"), 
    new SimpleRadioButton("ресурсы", "showResources")});

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
          float sum_money = product.getCostForPool()*terminal.count_operation;
          if (sum_money<=world.company.money) {
            terminal.refund=sum_money;
            world.company.money-=sum_money;
            product.pool-=terminal.count_operation;       
            start=true;
          } else
            wMessage = new WindowLabel("не хватает средств");
        } else if (develop) {
          float cost_dev = product.getCostDevelop();
          if (cost_dev<world.company.money) {
            world.company.money-=cost_dev;
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
  buttonPause = new SimpleButton(582, 0, 96, 30, "пауза", new Runnable() {
    public void run() {
      world.pause=true;
    }
  }
  );
  buttonStart = new SimpleButton(680, 0, 96, 30, "старт", new Runnable() {
    public void run() {
      world.pause=false;
    }
  }
  );
  buttonRemoveObject= new SimpleButton(536, 176, 160, 32, "уничтожить", new Runnable() {
    public void run() {
      WorkObject object =world.room.currentObject;
      world.room.removeObject(object);
    }
  }
  );
  buttonRemoveItem= new SimpleButton(584, 32, 160, 32, "списать", new Runnable() {
    public void run() {
      Item item = world.room.getItems(Item.ALL).getItem(items.select.id);
      world.room.removeItems(item.id, 1);
    }
  }
  );
  buttonRemoveAllItem= new SimpleButton(584, 66, 192, 32, "списать все", new Runnable() {
    public void run() {
      ItemList itemList = world.room.getItems(Item.ALL);
      Item item = itemList.getItem(items.select.id);
      world.room.removeItems(item.id, itemList.calculationItem(item.id));
    }
  }
  );
  buttonRepair= new SimpleButton(536, 176, 215, 32, "отремонтировать", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.hp=terminal.hp_max;
        wMessage = new WindowLabel("стоимость ремонта "+terminal.name+": "+400+"$");
        world.company.money-=400;
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
        if (!(object instanceof Workbench) && !(object instanceof DevelopBench)) {
          Database.DataObject product = data.items.getId(productsList.select.id);
          terminal.count_operation=constrain(terminal.count_operation, 1, product.pool);
        }
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
        if (!(object instanceof Workbench) && !(object instanceof DevelopBench)) {
          Database.DataObject product = data.items.getId(productsList.select.id);
          terminal.count_operation=constrain(terminal.count_operation, 1, product.pool);
        }
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

        if (!(object instanceof Workbench) && !(object instanceof DevelopBench) && terminal.label==null) {
          Database.DataObject product = data.items.getId(productsList.select.id);
          product.pool+=terminal.count_operation; 
          world.company.money+=terminal.refund;
        }
        terminal.removeLabel();
        terminal.product=null;
      }
    }
  }
  );
  buttonOpenOrder = new SimpleButton(570, 380, 193, 32, "открыть заказ", new Runnable() {
    public void run() {
      if (world.company.opened.size()<world.company.ordersOpenLimited) {
        Order order = world.orders.getOrder(orders.select.id);
        world.company.opened.add(order);
        world.orders.remove(order);
      } else
        wMessage = new WindowLabel("превышен лимит открытых заказов");
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
          world.company.exp+=order.exp;
        } else
          wMessage = new WindowLabel("не выполнены условия");
      }
    }
  }
  );
  buttonCancelOrder = new SimpleButton(570, 414, 193, 32, "отменить заказ", new Runnable() {
    public void run() {
      Order order = world.company.opened.getOrder(orders.select.id);
      if (order!=null) {
        world.company.opened.remove(order);
        world.company.failed.add(order);
        float forfeit = getDecimalFormat(order.cost*0.05);
        world.company.money-=forfeit;
        world.company.update();
        wMessage = new WindowLabel("заказ отменен, штраф: "+forfeit+" $");
      }
    }
  }
  );
}


void taskControl(Terminal terminal) {
  boolean ready = true;
  showScaleText(terminal.getDescriptTask(), 197, 370);  
  if (terminal instanceof DevelopBench) 
    buttonCreate.text="разработать";
  else {
    if (terminal instanceof Workbench) {
      buttonCreate.text="изготовить";
    } else {
      if (data.items.getId(productsList.select.id).pool<=0) //если пул не пустой, то ресурс можно купить
        ready = false;
      buttonCreate.text="закупить";
    }
    if (ready) {
      buttonCreate1.setActive(true);
      buttonCreate10.setActive(true);
      if (terminal.count_operation>0) {
        if (terminal.count_operation>1)
          buttonCreateBack1.setActive(true);
        if (terminal.count_operation>10)
          buttonCreateBack10.setActive(true);
      }
    }
  }
  if (ready)
    buttonCreate.setActive(true);
}




void updateInterface() {

  buttonCreate.setActive(false);
  buttonCreate1.setActive(false);
  buttonCreate10.setActive(false);
  buttonCreateBack1.setActive(false);
  buttonCreateBack10.setActive(false);
  buttonCancelProduct.setActive(false);
  buttonOpenOrder.setActive(false);
  buttonCloseOrder.setActive(false);
  buttonCancelOrder.setActive(false);
  buttonRemoveObject.setActive(false);
  buttonRemoveItem.setActive(false);
  buttonRemoveAllItem.setActive(false);
  buttonRepair.setActive(false);
  textConsole.setActive(false);
  menuContainer.setActive(false);
  menuOrders.setActive(false);
  menuTasker.setActive(false);
  menuReciept.setActive(false);
  buildings.setActive(false);
  orders.setActive(false);
  productsList.setActive(false);
  componentsList.setActive(false);
  helpList.setActive(false);
  items.setActive(false);

  menuMain.control();

  if (world.pause) {
    buttonStart.setActive(true);
    buttonPause.setActive(false);
  } else {
    buttonStart.setActive(false);
    buttonPause.setActive(true);
  }
  fill(white);
  if (menuMain.select.event.equals("showHelp")) {
    world.setActive(false);
    helpList.setActive(true);
    if (helpList.select!=null) 
      textConsole.loadText(data.helpMessages.get(data.helpMessages.key(helpList.select.id)));
    else
      textConsole.loadText(data.label.get("selected_question"));
    textConsole.setActive(true);
  } else if (menuMain.select.event.equals("showObjects")) {
    world.room.setActiveLabels(true);
    world.setActive(true);
    WorkObject object = world.room.currentObject;
    String event="";
    if (object!=null) {
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        menuTasker.control();
        event= menuTasker.select.event;
        if (event.equals("getInfo")) {
          textConsole.loadText(terminal.getDescript());
          textConsole.setActive(true);
        } else if (event.equals("getMaintenance")) {
          textConsole.loadText(terminal.getCharacters());
          textConsole.setActive(true);
          if (terminal.hp<terminal.hp_max)
            buttonRepair.setActive(true);
        } else if (event.equals("getTasks")) { //если выбрана вкладка задачи

          if (terminal.product==null) {        //если продукт не назначен
            if (terminal.products!=null) {      //если список продуктов существует
              if (terminal.products.size()>0) { //если список продуктов не пустой
                //заголовок списка
                if (terminal instanceof DevelopBench) 
                  showScaleText("чертежи:", 512, 190);
                else {
                  if (terminal instanceof Workbench) 
                    showScaleText("изделия:", 512, 190);  
                  else
                    showScaleText("ресурсы:", 512, 190);
                }
                productsList.loadComponents(terminal.products); //загружает продукты в список
                productsList.setActive(true);  //отображает список
                if (productsList.select!=null) {  //если 
                  if (terminal.count_operation==0)
                    terminal.count_operation=1;
                  taskControl(terminal);
                  ComponentList reciept = data.items.getId(productsList.select.id).reciept;
                  if (reciept!=null) {
                     menuReciept.control();
                    if (menuReciept.select.event.equals("showResources")) 
                       componentsList.loadReciept(reciept.getResources().getMult(terminal.count_operation));
                    else if (menuReciept.select.event.equals("showComponents")) 
                    componentsList.loadReciept(reciept.getMult(terminal.count_operation));  
                    componentsList.setActive(true);
                  }
                }
              } else 
              showScaleText("недоступно", 214, 421);
            }
          } else {
            showScaleText(terminal.getProductDescript(), 214, 421);
            if (terminal.label==null)
              buttonCancelProduct.setActive(true);
          }
        }
      } else if (object instanceof Container) {
        menuContainer.control();
        event= menuContainer.select.event;
        Container container = (Container) object;
        if (event.equals("getInfo")) {
          textConsole.loadText(container.getCapacityDescript());
          textConsole.setActive(true);
        }
      }
      if (event.equals("getManager")) {
        buttonRemoveObject.setActive(true);
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
      else if (menuOrders.select.event.equals("showOpenOrders")) {
        buttonCloseOrder.setActive(true);
        buttonCancelOrder.setActive(true);
      }
    } else
      textConsole.loadText(data.label.get("selected_order"));
    textConsole.setActive(true);
  } else if (menuMain.select.event.equals("showItems")) {
    world.room.setActiveLabels(false);
    world.setActive(false);
    items.loadItems(world.room.getItems(Item.ALL));
    if (items.select!=null) {
      textConsole.loadText(items.getSelectInfo());
      buttonRemoveItem.setActive(true);
      buttonRemoveAllItem.setActive(true);
    } else
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

  pushStyle();

  textFont(fontConsole);
  text("FPS: "+int(frameRate)+"\n"
    +"mouse x: "+mouseX+"\n"
    +"mouse y: "+mouseY+"\n" 
    +"mouse abs x: "+world.getAbsCoordX()+"\n"
    +"mouse abs y: "+world.getAbsCoordY()+"\n" 
    +"screen_width: "+width+"\n"
    +"screen_height: "+height+"\n"
    +"object: "+world.getObjectInfo()+"\n"
    , 5, 380);
  popStyle();

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
    if (isActiveSelect()) {
      if (script!=null)
        script.run();
    }
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
  static final int ITEMS=0, OBJECTS=1, ORDERS=2, HELP_MESSAGE=3;

  Listbox (float x, float y, float w, float h, int entry) {
    super(x, y, w, h);
    this.entry=entry;
    valueY =y;
    items = new ArrayList <ListItem> ();
  }
  Listbox (float x, float y, float w, float h, int entry, int level) {
    this(x, y, w, h, entry);
    this.level=level;
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
    update();
  }
  void loadHelpMessages(StringDict list) {
    int prev_select = getPrevSelect();  
    for (String part : list.keyArray()) {
      addItem(part, list.index(part), null);
    }
    setPrevSelect(prev_select);
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

  void loadReciept(ComponentList list) {
    int prev_select = getPrevSelect();
    for (int part : list.sortItem()) 
      addItem(data.items, "("+list.calculationItem(part)+") "+list.data.getId(part).name, part);
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
    if (hover && isActiveSelect())
      hoverItem = listStartAt + int((my-y*getScaleY()) / (itemHeight*getScaleY()));
  }
  public void mouseExited ( float mx, float my ) {
    hoverItem = -1;
  }
  void mouseDragged (float mx, float my) {
    if (!hasSlider || !isActiveSelect()) return;
    if (mx < x+this.width-20) return;
    valueY = my-itemHeight;
    valueY = constrain(valueY, y, y+this.height-itemHeight);
    update();
  }
  void mouseScrolled (float step) {
    if (items.size()*itemHeight>height && hover && isActiveSelect()) {
      float heightScroll = items.size()*itemHeight-this.height; 
      float hS = heightScroll/itemHeight;
      valueY += constrain(step, -1, 1)*((items.size()*itemHeight)/hS);
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
    listStartAt = constrain(listStartAt, 0, listStartAt);
  }
  public void mousePressed ( float mx, float my ) { 
    if (isActiveSelect()) {
      if (this.items==null) return;
      if (this.items.isEmpty()) return;
      if (hasSlider && mx > (x+this.width-20)*getScaleX()) return;
      int pressed=listStartAt + int((my-y*getScaleY())/(itemHeight*getScaleY()));
      if (pressed<this.items.size())
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
              // ", сложность разработки: "+dataObj.complexity+
              ", трудоёмкость изготовления: "+dataObj.scope_of_operation;
        }
        description+=", стоимость: "+dataObj.cost+" $";
      }
      return description;
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

  Text (float x, float y, int widthObj, int  heightObj, color text_color, color background_color) {
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

class WindowLabel extends ScaleActiveObject {
  String message, input;
  Text text;
  SimpleButton buttonOk;

  WindowLabel (String message) {
    super(150, 200, 500, 200);
    this.message=message;
    text = new Text (x+width/2-240, y+10, 480, 128, white, color(60));
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
    text.setActive(false);
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
    text.setActive(true);
    text.loadText(message);
    popStyle();
    popMatrix();
  }
}

void showScaleText(String text, float x, float y) {
  pushMatrix(); 
  fill(white);
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
