

class World extends ScaleActiveObject {
  Room room;
  float size_grid;
  Database.DataObject newObj;
  OrderList orders;
  boolean pause, input;
  int level;
  Date date;
  int speed, minSpeed, maxSpeed, stepSpeed;

  World (Date date, int speed) {
    super(1, 32, 512, 384);
    room = new Room(int(512/32), int(384/32));
    size_grid=32;
    minSpeed=50;
    maxSpeed=350;
    stepSpeed=100;
    this.speed=int(map(speed+1, 1, 4, maxSpeed, minSpeed));
    orders = new OrderList();
    this.date = date;
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
  void dispose() {
    room.dispose();
    room=null;
    newObj=null;
    orders.clear();
    date=null;
  }

  int getAbsCoordX() {
    return constrain(ceil((float(mouseX)-this.x*getScaleX())/(size_grid*getScaleX()))-1, 0, int(width/size_grid)-1);
  }
  int getAbsCoordY() {
    return constrain(ceil((float(mouseY)-this.y*getScaleY())/(size_grid*getScaleY()))-1, 0, int(height/size_grid)-1);
  }
  public void update() {
    if (!pause) {
      room.update();
      for (Timer part : timers)   //отсчет таймеров
        part.tick();
      date.tick();
      boolean newOrders=false;
      for (int i=orders.size()-1; i>=0; i--) {
        Order order = orders.get(i);
        order.update();
        if (order.isNotAllow(date)) {
          orders.remove(order);
          order = null;
          newOrders=true;
        }
      }
      if (newOrders)
        printConsole("список доступных заказов обновлен");
      OrderList failed = company.opened.getFailOrders(date);
      if (!failed.isEmpty()) {
        String ordersNames ="\n"+failed.getLabels();
        float refund=0, cost=0;
        for (Order order : failed) {
          float ref = order.cost*0.5;
          company.opened.remove(order);
          order.refund=ref;
          refund+=ref;
          cost+=order.cost;
          company.failed.add(order);
        }
        float forfeit = getDecimalFormat(refund);
        company.money-=forfeit;
        dialog.showInfoDialog("следующие заказы просрочились: "+ordersNames+" на сумму: "+getDecimalFormat(cost)+" $, штраф: "+forfeit+" $");
        printConsole("просроченные заказы: "+ordersNames+" на сумму: "+getDecimalFormat(cost)+" $, штраф: "+forfeit+" $");
        printConsole("[РАСХОД] штраф: "+forfeit+" $");
      }

      //добавление новых заказов
      int newCountOrders = company.getOrdersLimited()-company.opened.getCountTimersEnd();
      if (orders.size()<newCountOrders) 
        addRandomOrder();
    }
  }
  void addRandomOrder() {
    int item = d.getItemRandom(Database.RESHEARCHED); //определяет изделие
    int scope_one =d.getItem(item).scope_of_operation+d.getReciept(item).getScopeTotal();
    int count = 1+int(random(1000*company.getLevel())/scope_one); //определяет количество  
    int scope_total = count*scope_one;
    int day = constrain((date.getDays(scope_total)), 2, 10);//определяет срок на изготовление 2 дня - минималка
    float cost_one = d.getItem(item).cost*d.getReciept(item).getCostTotal();  //определяет стоимость предмета 
    float cost = count*cost_one;  //определяет общую стоимость объектов 
    float exp=scope_one/company.getLevel(); 
    IntList lastId = new IntList();
    lastId.append(orders.getLastId());
    lastId.append(company.opened.getLastId());
    lastId.append(company.closed.getLastId());
    lastId.append(company.failed.getLastId());
    if (cost<=1000*company.getLevel())
      orders.add(new Order(lastId.max(), item, count, cost, day, getDateForDays(day), getDateForDays(constrain(int(day), 1, day)), exp));
    lastId.clear();
    lastId=null;
  }
  void draw() {
    if (room!=null) {
      clip(x-getScaleX(), y-getScaleY(), (width+3)*getScaleX(), (height+3)*getScaleY());
      pushMatrix();
      translate(x*getScaleX(), y*getScaleY());
      scale(getScaleX(), getScaleY()); 
      room.draw();
      if (menuMain.select.event.equals("showBuildings")) {
        room.drawGrid();
        if (!mainList.isActive() || mainList.select==null) 
          newObj=null;
        if (newObj!=null && hover) {
          pushStyle();
          pushMatrix();
          translate(getAbsCoordX()*size_grid, getAbsCoordY()*size_grid);
          tint(white, 100);
          newObj.draw();
          popMatrix();
          if (!room.isPlaceBuilding(newObj, getAbsCoordX(), getAbsCoordY())) {
            translate(getAbsCoordX()*size_grid, getAbsCoordY()*size_grid);
            strokeWeight(4);
            stroke(red);
            line(5, 5, size_grid-5, size_grid-5);
            line(size_grid-5, 5, 5, size_grid-5);
          }
          popStyle();
        }
      }
      popMatrix();
      noClip();
    }
  }
  public String getObjectInfo() {
    if (room.isHoverLabel()) {
      WorkLabel label = room.getHoverLabel();
      return d.getName("items", label.item)+" ("+label.count+")";
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
      if (company.workers.getWorkers(getAbsCoordX(), getAbsCoordY()).isEmpty())
        return room.object[getAbsCoordX()][getAbsCoordY()];
      else
        return company.workers.getWorkers(getAbsCoordX(), getAbsCoordY()).get(0);
    } else 
    return null;
  }
  void selectCurrentObject() {
    if (room!=null) {
      WorkObject object = getObject();
      if (object!=null) {
        menuTasker.resetSelect();
        menuContainer.resetSelect(); 
        menuBench.resetSelect(); 
        menuWorker.resetSelect();
        room.currentObject=object;
        mainList.select=null;
      } else
        room.currentObject=null;
    }
  }
  public void mousePressed() {
    if (input) {
      if (room!=null) {
        if (!room.isHoverLabel()) {
          int _x=getAbsCoordX();
          int _y=getAbsCoordY();
          if (mouseButton==LEFT) {
            if (menuMain.select.event.equals("showObjects")) 
              selectCurrentObject();
            else if (menuMain.select.event.equals("showBuildings")) {
              if (mainList.select!=null) {
                Database.DataObject newObj = d.objects.getId(mainList.select.id);
                if (newObj.cost<=company.money) {
                  if (room.isPlaceBuilding(newObj, _x, _y)) {
                    if (room.getAllObjects().getNoItemMap().size()<company.buildingLimited) {
                      WorkObject newObject = d.getNewObject(newObj);
                      if (newObject!=null) {
                        company.money-=newObj.cost;
                        printConsole("[РАСХОД] постройка объекта "+d.getName("objects", newObj.id)+": "+getDecimalFormat(newObj.cost)+" $");
                        world.room.object[_x][_y]=newObject;
                      }
                    } else 
                    dialog.showInfoDialog(d.label.get("message_exceeded_the_limit_of_buildings"));
                  } else 
                  dialog.showInfoDialog(d.label.get("message_it_is_impossible_to_place"));
                } else 
                dialog.showInfoDialog(d.label.get("message_not_enough_funds"));
              }
            } else {      //сброс в режим просмотра объектов
              menuMain.setSelect(menuMain.buttons.get(0));
              selectCurrentObject();
            }
          } else if (mouseButton==RIGHT) {
            if (menuMain.select.event.equals("showBuildings"))
              menuMain.resetSelect();
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
    }
    void dispose() {
      object = null;
      node = null;
      currentObject = null;
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
    void moveObject(ItemMap moved, int x, int y) {
      int tx = moved.getX();
      int ty = moved.getY();
      object[x][y]=moved;
      object[tx][ty]=null;
      node[tx][ty].solid=false;
    }
    Terminal getObjectAtLabel(WorkLabel label) {
      for (WorkObject part : getAllObjects().getWorkObjects()) {
        Terminal terminal = (Terminal)part; 
        if (terminal .label==label)
          return terminal;
      }
      return null;
    }
    void update() {
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
    void removeObject(WorkObject object) {
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
    void setActiveLabels(boolean active) {
      for (WorkLabel part : getAllLabels()) 
        part.setActive(active);
    }
    int addItem(int cx, int cy, int id, int count) {
      int [] neighbors = new int [] {59, 49, 61, 71, 48, 50, 72, 70};
      int stack = d.getItem(id).getStack();
      for (int i=0; i<neighbors.length; i++) {  //цикл перебирает все соседник клетки в соответствией с матрицей размещения
        int ix=cx+matrixShearch[neighbors[i]][0]; //корректировка координаты х
        int iy=cy+matrixShearch[neighbors[i]][1]; //корректировка координаты у
        if (ix<0 || iy<0 || ix>=sizeX || iy>=sizeY)  //если алгоритм выходит за пределы карты
          continue;  //переходим к следующей клетке
        if (object[ix][iy]==null) { //если клетка пустая,
          if (stack>=count) { //и если количество предметов умещается в стэк 
            object[ix][iy] = new ItemMap(id, count); //то создает новый объект предмета на карте
            return 0;
          } else {
            object[ix][iy] = new ItemMap(id, stack); //то создает новый объект предмета на карте
            count-=stack;
          }
        } else {
          if (object[ix][iy] instanceof ItemMap) {
            ItemMap itemMap = (ItemMap) object[ix][iy];
            if (itemMap.item==id) {
              int newCount = itemMap.count+count;
              if (newCount>stack) {        //проверяем не переполнен ли стэк объекта itemMap, если да, то
                itemMap.count=stack;      //устанавливаем значение itemMap.count равным значению стэка вложенного предмета
                count=newCount-stack;      //вычисляем сколько предметов осталось после размещения
              } else {              //если стэк объекта itemMap не переполнен
                itemMap.count=newCount;          //устанавливает значение count
                return 0;              //продолжает поиск что бы разместить оставшиеся предметы
              }
            }
          }
        }
      }
      printConsole("не удалось выгрузить "+d.getName("items", id)+" ("+count+"), нет свободного места");
      return count;
    }
    ComponentList getItemsIsContainers() {
      ComponentList list = new ComponentList ();
      for (WorkObject object : getAllObjects().getObjectsEntryItems()) {
        if (object instanceof Container) {
          if (((Container)object).items.size()>0)
            list.addAll(((Container)object).items);
        }
      }
      return list;
    }
    ComponentList getItemsAll() {
      ComponentList list = new ComponentList ();
      for (WorkObject object : getAllObjects().getObjectsEntryItems()) {
        if (object instanceof Container) {
          if (((Container)object).items.size()>0)
            list.addAll(((Container)object).items);
        } else if (object instanceof ItemMap) 
          list.setComponents(((ItemMap)object).item, ((ItemMap)object).count);
      }
      return list;
    }
    ComponentList getItemsIsDeveloped() { //возвращает список предметов уже разработанных (уникальный)
      ComponentList list = new ComponentList();
      for (Database.DataObject object : d.objects) {
        for (int p : object.products) {
          if (!list.hasValue(p))
            list.append(p);
        }
      }
      return list;
    }
    ComponentList getListAllowProducts() { //возвращает список доступных для разработки чертежей
      ComponentList list = new ComponentList();
      ComponentList all_product = getItemsIsDeveloped();  //список изделий уже разработанных
      all_product.addAll(d.getResources());
      for (int product : d.getProducts()) { //берет список всех изделий
        if (!all_product.hasValue(product)) { //если чертеж еще не разработан
          boolean add = true;
          for (int p : d.getReciept(product).sortItem()) {
            if (!all_product.hasValue(p))
              add=false;
          }
          if (add && !list.hasValue(product))
            list.append(product);
        }
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
        if (world.room.getItemsIsContainers().getComponent(part)!=-1) 
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
        if (container.items.size()>0) {
          if (container.items.getComponent(id)!=-1) 
            container.items.removeItems(container.items.getComponent(id), 1);
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
      if (company!=null) {
        for (Worker worker : company.workers) {
          if (currentObject!=null) {
            if (currentObject.equals(worker)) 
              worker.drawPath();
          }
          worker.update();
        }
      }
      if (menuMain.select.event.equals("showObjects")) {
        if (currentObject!=null) {
          for (int ix=0; ix<sizeX; ix++) {
            for (int iy=0; iy<sizeY; iy++) {
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
      } else if (menuMain.select.event.equals("showMenuCompany")) {
        if (menuCompany.select.event.equals("getWorkers")) {
          if (mainList.select!=null) {
            Worker worker = company.workers.getWorkerIsId(mainList.select.id);
            if (worker!=null)
              worker.drawSelected();
          }
        } else if (menuCompany.select.event.equals("getProfessions")) {
          if (mainList.select!=null) {  
            for (Worker worker : company.workers.getWorkers(company.professions.getProfessionIsName(mainList.select.label)))
              worker.drawSelected();
          }
        }
      }
    }
  }
}
