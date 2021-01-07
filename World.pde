

class World extends ScaleActiveObject {
   Room room;
  float size_grid;
  Company company;
  Database.DataObject newObj;
  OrderList orders, allOrders;
  boolean pause, input;
  int level;
  Date date;

  World (float xx, float yy, float ww, float hh) {
    super(xx, yy, ww, hh);
    room = new Room(int(ww/32), int(hh/32));
    size_grid=32;
    company=new Company ("Robocraft");
    orders = new OrderList();
    allOrders = new OrderList();
    date = new Date (1, 5, 2019);
    input=true;
    level=0;
    int n=0;
    for (int ix=-5; ix<6; ix++) {
      for (int iy=-5; iy<6; iy++) {
        matrixShearch[n][0]=ix;
        matrixShearch[n][1]=iy;
        n++;
      }
    }
  }
  public int getAbsCoordX() {
    return constrain(ceil((float(mouseX)-this.x*getScaleX())/(size_grid*getScaleX()))-1, 0, int(width/size_grid)-1);
  }
  public int getAbsCoordY() {
    return constrain(ceil((float(mouseY)-this.y*getScaleY())/(size_grid*getScaleY()))-1, 0, int(height/size_grid)-1);
  }
  public void update() {
    company.update();


    if (!pause) {

      room.update();
      for (Timer part : timers)   //отсчет таймеров
        part.tick();
      date.tick();
      //добавление новых заказов
      allOrders.clear();
      allOrders.addAll(orders);
      allOrders.addAll(company.opened);
      allOrders.addAll(company.closed);
      allOrders.addAll(company.failed);
      if (orders.isEmpty() || orders.size()<company.ordersLimited) {
        Item item = new Item(data.items.getRandom(Item.PRODUCTS).id); //определяет изделие
        int scope_one =item.scope_of_operation+item.reciept.getScopeTotal();
        int count = 1+int(random(1000*world.company.getLevel())/scope_one); //определяет количество  
        int scope_total = count*scope_one;
        int deadLine = 2+int(date.getDays(scope_total));//определяет срок на изготовление 2 дня - минималка
        float cost_one = item.cost*item.reciept.getCostTotal();  //определяет стоимость предмета 
        float cost = count*cost_one;  //определяет общую стоимость объектов 
        float exp=scope_one/world.company.getLevel();  
        if (cost<=1000*world.company.getLevel())
          orders.add(new Order(allOrders.getLastId(), item, count, cost, deadLine, exp));
      }
      for (Order order : orders)
        order.update();
      OrderList failed = company.opened.getFailOrders(date);
      if (!failed.isEmpty()) {
        String ordersNames ="\n"+failed.getLabels();
        float cost=0;
        for (Order order : failed) {
          company.opened.remove(order);
          cost+=order.cost;
          company.failed.add(order);
        }
        cost = getDecimalFormat(cost);
        booster.showInfoDialog("следующие заказы просрочились: "+ordersNames+" на сумму: "+cost+" $");
      }
    }
  }

  public void draw() {
    if (room!=null) {
      pushMatrix();
      translate(x*getScaleX(), y*getScaleY());
      scale(getScaleX(), getScaleY()); 
      room.draw();
      if (menuMain.select.event.equals("showBuildings"))
        room.drawGrid();
      if (!buildings.isActive() || buildings.select==null) 
        newObj=null;
      if (newObj!=null && hover) {
        pushStyle();
        tint(white, 100);
        newObj.draw();
        if (!room.isPlaceBuilding(newObj, getAbsCoordX(), getAbsCoordY())) {
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
  int [] getPlace(int x, int y, int direction) {
    if (direction==0)
      return new int [] {x, y-1};
    else if (direction==1)
      return new int [] {x+1, y};
    else if (direction==2)
      return new int [] {x, y+1};
    else 
    return new int [] {x-1, y};
  }

  public WorkObject getObject() {
    if (hover) {
      if (company.getWorkers(getAbsCoordX(), getAbsCoordY()).isEmpty())
        return room.object[getAbsCoordX()][getAbsCoordY()];
      else
        return company.getWorkers(getAbsCoordX(), getAbsCoordY()).get(0);
    } else 
    return null;
  }
  public void mousePressed() {
    if (input) {
      if (!room.isHoverLabel()) {
        int _x=getAbsCoordX();
        int _y=getAbsCoordY();
        if (mouseButton==LEFT) {
          if (menuMain.select.event.equals("showObjects")) {
            if (room!=null) {
              WorkObject object = getObject();
              if (object!=null) 
                room.currentObject=object;
              else
                room.currentObject=null;
            }
          } else if (menuMain.select.event.equals("showBuildings")) {
            if (buildings.select!=null) {
              Database.DataObject newObj = data.objects.getId(buildings.select.id);
              if (newObj.cost<=company.money) {
                if (room.isPlaceBuilding(newObj, _x, _y)) {
                  if (room.getAllObjects().getNoItemMap().size()<company.buildingLimited) {
                    WorkObject newObject = data.getNewObject(newObj);
                    if (newObject!=null) {
                      company.money-=newObj.cost;
                      world.room.object[_x][_y]=newObject;
                    }
                  } else 
                  booster.showInfoDialog("превышен лимит построек");
                } else 
                booster.showInfoDialog("невозможно разместить");
              } else 
              booster.showInfoDialog("не хватает средств");
            }
          }
        }
      }
    }
  }
  class Room {
    int sizeX, sizeY;
    WorkObject [][] object;
    Graph [][] node;
    WorkObject currentObject;

    Room (int sizeX, int sizeY) {
      this.sizeX=sizeX;
      this.sizeY=sizeY;
      object = new WorkObject [sizeX][sizeY];
      node = new Graph [sizeX][sizeY];
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          object[ix][iy]=null;
          node[ix][iy]=new Graph(ix, iy);
        }
      }
      object[3][3] = new Terminal(WorkObject.TERMINAL);
      object[4][4] = new Workbench(WorkObject.WORKBENCH);
      object[7][4] = new Workbench(WorkObject.SAW_MACHINE);
      object[7][5] = new Workbench(WorkObject.WORKSHOP_MECHANICAL);
      object[5][4] = new DevelopBench(WorkObject.DEVELOPBENCH);
      object[6][4] = new Container(0);
    }


    float [] getAbsCoord(int x, int y) {
      return new float [] {x*size_grid+size_grid/2, y*size_grid+size_grid/2};
    } 

    float [] getCoordObject(WorkObject object) {
      int [] res = getAbsCoordObject(object);
      if (res!=null)
        return new float [] {x+res[0]*size_grid, y+res[1]*size_grid, size_grid};
      else
        return null;
    }  

    int [] getAbsCoordObject(WorkObject object) {
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          WorkObject current = this.object[ix][iy];
          if (current!=null) {
            if (current==object)
              return new int [] {ix, iy};
          }
        }
      }
      return null;
    }
    int [] getRandomCoord() { //доделать

      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          WorkObject current = this.object[ix][iy];
          if (current!=null) {
            return new int [] {ix, iy};
          }
        }
      }
      return null;
    }

    public Terminal getObjectAtLabel(WorkLabel label) {
      for (WorkObject part : getAllObjects().getWorkObjects()) {
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
            if (current instanceof Terminal) {
              Terminal terminal = (Terminal) this.object[ix][iy];
              terminal.tick();
            }
          }
        }
      }
    }
    public void removeObject(WorkObject object) {
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          if (this.object[ix][iy]==object) {
            this.object[ix][iy]=null;
            node[ix][iy].solid=false;
            if (currentObject==object)
              currentObject=null;
            break;
          }
        }
      }
    }

    public void setActiveLabels(boolean active) {
      for (WorkLabel part : getAllLabels()) 
        part.setActive(active);
    }

    public boolean addItem(int cx, int cy, int id, int count) {
      int [] neighbors = new int [] {59, 49, 61, 71, 48, 50, 72, 70};
      for (int i=0; i<neighbors.length; i++) {  //цикл перебирает все соседник клетки в соответствией с матрицей размещения
        int ix=cx+matrixShearch[neighbors[i]][0]; //корректировка координаты х
        int iy=cy+matrixShearch[neighbors[i]][1]; //корректировка координаты у
        if (ix<0 || iy<0)  //если алгоритм выходит за пределы карты
          continue;
        if (object[ix][iy]==null) {
          object[ix][iy] = new ItemMap(id, count);
          return true;
        } else {

          if (object[ix][iy] instanceof ItemMap) {
            ItemMap itemMap = (ItemMap) object[ix][iy];
            if (itemMap.item==id) {
              itemMap.count+=count;
              return true;
            }
          }
        }
      }
      return false;
    }

    public ItemList getItems(int filter) {
      ItemList list = new ItemList ();
      for (WorkObject object : getAllObjects().getContainers()) {
        if (!((Container)object).items.isEmpty())
          list.addAll(((Container)object).items);
      }
      return list;
    }
    int getShearchInItemMap(IntList items) { 
      for (int part : items) { 
        if (getAllObjects().getItems().getItemById(part)!=null) 
          return part;
      }
      return -1;
    }
    int getShearchInItem(IntList items) {
      for (int part : items) { 
        if (world.room.getItems(Item.ALL).getItem(part)!=null) 
          return part;
      }
      return -1;
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
    public boolean isPlaceBuilding(Database.DataObject newObj, int x, int y) {
      if (object[x][y]!=null || node[x][y].solid) 
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
      for (WorkObject part : getAllObjects().getWorkObjects()) {
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



    private void drawGrid() {
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          pushMatrix();
          translate(ix*size_grid, iy*size_grid);
          pushStyle();
          noFill();
          stroke(white);
          rect(0, 0, size_grid, size_grid);
          popStyle();
          popMatrix();
        }
      }
    }

    public void draw() {
      for (int ix=0; ix<sizeX; ix++) {
        for (int iy=0; iy<sizeY; iy++) {
          pushMatrix();
          translate(ix*size_grid+size_grid/2, iy*size_grid+size_grid/2);
          pushStyle();
          image(floor, -world.size_grid/2, -world.size_grid/2);
          popStyle();
          WorkObject current = object[ix][iy];
          if (current!=null) {

            current.draw();
            if (!(current instanceof ItemMap))
              node[ix][iy].solid=true;
          } 

          popMatrix();
        }
      }
      for (Worker worker : company.workers) {
        if (currentObject!=null) {
          if (currentObject.equals(worker)) 
            worker.drawPath();
        }
        worker.update();
      }
      if (menuMain.select.event.equals("showObjects")) {
        if (currentObject!=null) {
          for (int ix=0; ix<sizeX; ix++) {
            for (int iy=0; iy<sizeY; iy++) {
              //if (node[ix][iy].solid) {
              //fill(white);
              //text("s", ix*size_grid, iy*size_grid);
              //}
              if (object[ix][iy]==currentObject) {
                pushMatrix();
                translate(ix*size_grid, iy*size_grid);
                currentObject.drawSelected();
                if (currentObject instanceof Terminal)
                  currentObject.drawPlace(yellow);
                popMatrix();

                break;
              }
            }
          }
          for (Worker worker : company.workers) {
            if (currentObject.equals(worker)) 
              worker.drawSelected();
          }
        }
      }
    }
  }
}
