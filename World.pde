

class World extends ScaleActiveObject {
  Room room;
  float size_grid;
  Company company;
  Database.DataObject newObj;
  OrderList orders;
  boolean pause, input;
  int level;
  Date date;

  World (float xx, float yy, float ww, float hh) {
    super(xx, yy, ww, hh);
    room = new Room(10, 10);
    size_grid=32;
    company=new Company ("Robocraft");
    orders = new OrderList();
    date = new Date (1, 5, 2019);
    input=true;
    level=0;
  }
  public int getAbsCoordX() {
    return constrain(ceil((float(mouseX)-this.x*getScaleX())/(size_grid*getScaleX()))-1, 0, int(width/size_grid)-1);
  }
  public int getAbsCoordY() {
    return constrain(ceil((float(mouseY)-this.y*getScaleY())/(size_grid*getScaleY()))-1, 0, int(height/size_grid)-1);
  }
  public void update() {
    if (!pause) {
      room.update();
      for (Timer part : timers)   //отсчет таймеров
        part.tick();
      date.tick();
      //добавление новых заказов
      OrderList allOrders = new OrderList();
      allOrders.addAll(orders);
      allOrders.addAll(company.opened);
      allOrders.addAll(company.closed);
      allOrders.addAll(company.failed);
      if (orders.isEmpty() || orders.size()<company.ordersLimited) {
        Item item = new Item(data.items.getRandom(Item.ALL).id);
        int count = (int)random(100)+1;
        int time = (int)random(5)+1;
        float cost = count*(item.cost+random(50));
        orders.add(new Order(allOrders.getLastId(), item, count, cost, time));
      }

      for (Order order : orders)
        order.update();


      OrderList failed = company.opened.getFailOrders(date);
      if (!failed.isEmpty()) {
        for (Order order : failed) {
          company.opened.remove(order);
          company.failed.add(order);
        }
      }
    }
  }

  public void draw() {
    if (room!=null) {
      pushMatrix();
      translate(x*getScaleX(), y*getScaleY());
      scale(getScaleX(), getScaleY()); 
      room.draw();
      if (!buildings.isActive() || buildings.select==null) 
        newObj=null;
      if (newObj!=null && hover && isActiveSelect()) {
        pushStyle();
        tint(white, 100);
        newObj.draw();
        if (!room.isPlaceBuilding(getAbsCoordX(), getAbsCoordY())) {
          translate(getAbsCoordX()*size_grid, getAbsCoordY()*size_grid);
          strokeWeight(4);
          stroke(red);
          line(5, 5, size_grid-5, size_grid-5);
          line(size_grid-5, 5, 5, size_grid-5);
        }
        popStyle();
      }
      popMatrix();
    }
  }
  public String getObjectInfo() {
    if (room.isHoverLabel()) {
      WorkLabel label = room.getHoverLabel();
      return label.item.name+" ("+label.count+")";
    } else {
      WorkObject object = getObject();
      if (object!=null)
        return object.name;
      else
        return "нет";
    }
  }

  public WorkObject getObject() {
    if (hover)
      return room.object[getAbsCoordX()][getAbsCoordY()];
    else 
    return null;
  }


  public void mousePressed() {
    if (input) {
      if (!room.isHoverLabel()) {
        int _x=getAbsCoordX();
        int _y=getAbsCoordY();
        if (mouseButton==LEFT) {
          if (menuMain.select.event.equals("showObjects")) {
            if (room!=null) 
              room.currentObject=getObject();
          } else if (menuMain.select.event.equals("showBuildings")) {
            if (buildings.select!=null) {
              Database.DataObject newObj = data.objects.getId(buildings.select.id);
              if (newObj.cost<=company.money) {
                if (room.isPlaceBuilding(_x, _y)) {
                  if (room.getAllObjects().size()<company.buildingLimited) {
                    WorkObject newObject = data.getNewObject(newObj);
                    if (newObject!=null) {
                      company.money-=newObj.cost;
                      world.room.object[_x][_y]=newObject;
                    }
                  } else 
                  wMessage = new WindowLabel("превышен лимит построек");
                } else 
                wMessage = new WindowLabel("невозможно разместить");
              } else 
              wMessage = new WindowLabel("не хватает средств");
            }
          }
        }
      }
    }
  }
  class Room {
    int sizeX, sizeY;
    WorkObject [][] object;

    WorkObject currentObject;

    Room (int sizeX, int sizeY) {
      this.sizeX=sizeX;
      this.sizeY=sizeY;
      object = new WorkObject [sizeX][sizeY];

      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          object[ix][iy]=null;
        }
      }
      object[3][3] = new Terminal(WorkObject.TERMINAL);
      object[4][4] = new Workbench(WorkObject.WORKBENCH);
      object[5][4] = new DevelopBench(WorkObject.DEVELOPBENCH);
      object[6][4] = new Container(0);
      ((Container)object[6][4]).items.add(new Item(Item.STEEL));
      ((Container)object[6][4]).items.add(new Item(Item.STEEL));
      ((Container)object[6][4]).items.add(new Item(Item.PLATE_STEEL));
      ((Container)object[6][4]).items.add(new Item(Item.STONE));
    }

    float [] getCoordObject(WorkObject object) {
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          WorkObject current = this.object[ix][iy];
          if (current!=null) {
            if (current==object)
              return new float [] {x+ix*size_grid, y+iy*size_grid, size_grid};
          }
        }
      }
      return null;
    }
    public Terminal getObjectAtLabel(WorkLabel label) {
      for (WorkObject part : getAllObjects().getTerminals()) {
        Terminal terminal = (Terminal)part; 
        if (terminal .label==label)
          return terminal;
      }
      return null;
    }
    public void update() {
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          WorkObject current = this.object[ix][iy];
          if (current!=null) {
            current.tick();
          }
        }
      }
    }
    public void setActiveLabels(boolean active) {
      for (WorkLabel part : getAllLabels()) 
        part.setActive(active);
    }
    public ItemList getItems(int filter) {
      ItemList list = new ItemList ();
      for (WorkObject object : getAllObjects().getContainers()) {
        if (!((Container)object).items.isEmpty())
          list.addAll(((Container)object).items);
      }
      return list;
    }

    public void removeItems(ComponentList items, int count) {
      while (count!=0) {
        for (int part : items) 
          this.removeItem(part);
        count--;
      }
    }
    public void removeItems(int id, int count) {
      while (count!=0) {
        this.removeItem(id);
        count--;
      }
    }
    public void removeItem(int id) {
      for (WorkObject object : getAllObjects().getContainers()) {
        Container container = (Container)object;
        if (!container.items.isEmpty()) {
          if (container.items.getItem(id)!=null) 
            container.items.removeItemCount(container.items.getItem(id), 1);
        }
      }
    }
    //метод проверяющий возможность разместить объект на под курсором мыши
    public boolean isPlaceBuilding(int x, int y) {
      if (object[x][y]!=null) 
        return false;
      else
        return true;
    }
    boolean isHoverLabel() {
      for (WorkLabel part : getAllLabels()) {
        if (part.hover)
          return true;
      }
      return false;
    }
    WorkLabel getHoverLabel() {
      for (WorkLabel part : getAllLabels()) {
        if (part.hover)
          return part;
      }
      return null;
    }
    public ArrayList <WorkLabel> getAllLabels() {
      ArrayList <WorkLabel> labels = new ArrayList <WorkLabel>();
      for (WorkObject part : getAllObjects().getTerminals()) {
        Terminal terminal = (Terminal)part; 
        if (terminal.label!=null) 
          labels.add(terminal.label);
      }

      return labels;
    }

    public WorkObjectList getAllObjects() {
      WorkObjectList objects = new WorkObjectList();
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          if (object[ix][iy]!=null)
            objects.add(object[ix][iy]);
        }
      }
      return objects;
    }


    public void draw() {
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          pushMatrix();
          translate(ix*size_grid, iy*size_grid);
          pushStyle();
          if (ix==0 || ix==sizeX-1 || iy==0 || iy==sizeY-1)
            tint(white, 100);
          image(floor, 0, 0);
          popStyle();
          WorkObject current = object[ix][iy];
          if (current!=null) 
            current.draw();
          popMatrix();
        }
      }
      if (currentObject!=null) {
        for (int ix=0; ix<sizeX; ix++) {
          for (int iy=0; iy<sizeY; iy++) {
            if (object[ix][iy]==currentObject) {
              pushMatrix();
              translate(ix*size_grid, iy*size_grid);
              currentObject.drawSelected();
              popMatrix();
              break;
            }
          }
        }
      }
    }
  }
}
