class Company {
  String name;
  private float money;
  OrderList opened, closed, failed;
  int buildingLimited, ordersLimited, ordersOpenLimited, exp;
  boolean gameOver;
  WorkerList workers;
  ProfessionList professions;

  Company (String name) {
    this.name=name;
    gameOver=false;
    money=10000;
    opened=new OrderList();
    closed=new OrderList();
    failed=new OrderList();
    buildingLimited = 15;
    ordersLimited = 36;
    ordersOpenLimited=5;
    exp = 0;

    professions = new ProfessionList();

    professions.addNewProfession("разнорабочий");
    workers = new WorkerList();
    addWorker("Виктор Функ", 6);
    addWorker("Михаил Маричев", 8);
    addWorker("Аким Мульцин", 6);
  }
  public String getInfo() {
    return "наименование: "+name+"\n"+
      "размер компании"+": "+getLevel()+"\n"+
      "опыт компании"+": "+exp+"\n"+
      "бюджет"+": "+money+" $\n"+
      "лимит построек"+": "+buildingLimited+"\n"+
      "лимит новых заказов"+": "+ordersLimited+"\n"+
      "лимит открытых заказов"+": "+ordersOpenLimited+"\n"+
      "работников: "+workers.size() +"\n";
  }
  public void update() {


    for (Worker worker : workers) {
      if (worker.job==null) {
        if (worker.profession!=null) {
          if (worker.profession.jobs.hasValue(Job.SUPPLY)) { 
            //работа по выполнению закупки сырья
            WorkObject terminalPurchase = world.room.getAllObjects().getTerminals().getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowProducts().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
            if (terminalPurchase!=null) {    
              worker.job = new JobInTerminal(worker, (Terminal)terminalPurchase, JobInTerminal.SUPPLY);
              continue;
            }
          }
          if (worker.profession.jobs.hasValue(Job.DEVELOP)) { 
            //работа по разработке новых изделий
            WorkObject productDevelop = world.room.getAllObjects().getDevelopBenches().getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowProducts().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
            if (productDevelop!=null) {
              worker.job = new JobInTerminal(worker, (DevelopBench)productDevelop, JobInTerminal.DEVELOP);
              continue;
            }
          }
          if (worker.profession.jobs.hasValue(Job.CREATE)) { 
            //работа по созданию изделий
            WorkObject productBench = world.room.getAllObjects().getWorkBenches(Job.CREATE).getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowProducts().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
            if (productBench !=null) {
              Workbench bench = (Workbench)productBench;
              if (bench.isAllowCreate()) {
                worker.job = new JobInTerminal(worker, bench, JobInTerminal.CREATE);
                continue;
              }
            }
          }
          if (worker.profession.jobs.hasValue(Job.ASSEMBLY)) { 
            //работа по сборке изделий
            WorkObject productBench = world.room.getAllObjects().getWorkBenches(Job.ASSEMBLY).getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowProducts().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
            if (productBench !=null) {
              Workbench bench = (Workbench)productBench;
              if (bench.isAllowCreate()) {
                worker.job = new JobInTerminal(worker, bench, JobInTerminal.ASSEMBLY);
                continue;
              }
            }
          }  
          if (worker.profession.jobs.hasValue(Job.CARRY)) { 
            //работа по переноске предметов в объект производства
            WorkObjectList objectsBenches = world.room.getAllObjects().getWorkBenches().getObjectsAllowJob().getObjectsAllowMove(worker);
            for (WorkObject object : objectsBenches) {
              Workbench workbench = (Workbench)object;
              if (workbench.product!=-1) {
                //предметов на карте в объект производства
                int needId=world.room.getShearchInItemMap(workbench.getNeedItems());
                if (needId!=-1) {
                  int needItemCount = workbench.getNeedItemCount(needId);
                  WorkObject objectCarryComponent=null;
                  WorkObjectList itemsFree = world.room.getAllObjects().getItems().getObjectsAllowJob().getObjectsAllowMove(worker).getItemsById(needId);
                  if (!itemsFree.isEmpty()) 
                    objectCarryComponent=itemsFree.getNearestObject(worker.x, worker.y);
                  if (objectCarryComponent!=null) {
                    if (data.getItem(((ItemMap)objectCarryComponent).item).weight<=worker.capacity) {
                      worker.job = new JobCarryItemMapForBench(worker, (ItemMap)objectCarryComponent, needItemCount, workbench);                
                      continue;
                    }
                  }
                }
                if (worker.job!=null)
                  break;
                //предметов из контейнеров в объект производства
                int itemCarry=-1;
                WorkObject containerIsItemFree=null; 
                needId = world.room.getShearchInItem(workbench.getNeedItems());
                if (needId!=-1) {
                  int needItemCount = workbench.getNeedItemCount(needId);
                  WorkObjectList storageIsItem = world.room.getAllObjects().getIsItem(needId); 
                  if (!storageIsItem.isEmpty()) { 
                    containerIsItemFree=(Container)storageIsItem.getNearestObject(worker.x, worker.y);
                    itemCarry=((Container)containerIsItemFree).items.getComponent(needId);
                  }
                  if (containerIsItemFree!=null && itemCarry!=-1) {  
                    if (data.getItem(itemCarry).weight<=worker.capacity) {
                      worker.job = new JobCarryItemForBench(worker, itemCarry, needItemCount, (Container)containerIsItemFree, workbench);                
                      continue;
                    }
                  }
                }
              }
            }
            if (worker.job!=null)
              continue;
            //работа по перемещению предмета с карты в контейнер
            ItemMap itemMap=null;  //инициализирует предмет на карте
            WorkObjectList itemsMap = world.room.getAllObjects().getItems().getObjectsAllowJob().getObjectsAllowMove(worker); //ищет предмет в комнате
            if (!itemsMap.isEmpty()) { 
              itemMap=(ItemMap)itemsMap.getNearestObject(worker.x, worker.y);
              Container container=null;
              WorkObjectList containers = world.room.getAllObjects().getContainers().getContainersFreeCapacity().getObjectsAllowJob().getObjectsAllowMove(worker);  //ищет контейнер
              if (!containers.isEmpty()) {
                container = (Container)containers.getNearestObject(worker.x, worker.y);
                if (container!= null) {
                  if (data.getItem(itemMap.item).weight<=worker.capacity) {
                  worker.job = new JobCarryItemMap(worker, itemMap, container);
                  continue;
                  }
                }
              }
            }
          }
          if (worker.profession.jobs.hasValue(Job.REPAIR)) {
            WorkObject terminalRepair = world.room.getAllObjects().getWorkObjects().getObjectsAllowJob().gerObjectAllowRepair().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
            if (terminalRepair!=null) {
              Terminal terminal = (Terminal)terminalRepair;
              worker.job = new JobRepair(worker, terminal);
              continue;
            }
          }
          int x = int(random(world.room.sizeX));
          int y = int(random(world.room.sizeY));
          if (getPathTo(world.room.node[worker.x][worker.y], world.room.node[x][y])!=null) 
            worker.job= new JobMove (worker, world.room.node[x][y]);
        }
      }
    }
    money=getDecimalFormat(money);
    if (money<=0) 
      gameOver=true;
    if (gameOver) {
      dialog.showWarningDialog("Игра проиграна ", "Сообщение");
      exit();
    }
  }
  public void addWorker(String name, int capacity) {
    Worker worker = new Worker(workers.getLastWorkerId(), name, capacity);
    worker.profession=professions.get(0);
    workers.add(worker);
  }
  void setExpenses() {
    float sum_money=0;
    for (Worker worker : workers) 
      sum_money+=worker.payday;
    money-=sum_money;
    update();
  }
  int getLevel() {
    return int(exp/1000)+1;
  }
}

float getDecimalFormat(float valueFloat) {
  String valueString = str(valueFloat);
  int indexPoint = valueString.indexOf(".");
  return constrain(float(valueString.substring(0, constrain(indexPoint+2, 0, valueString.length()))), -99999, valueFloat);
}
