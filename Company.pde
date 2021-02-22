Company company;


class Company {
  String name;
  float money;
  OrderList opened, closed, failed;
  int buildingLimited, ordersOpenLimited, exp;
  WorkerList workers;
  ProfessionList professions;

  Company (String name, int exp, float money) {
    this.name=name;
    this.money=money;
    opened=new OrderList();
    closed=new OrderList();
    failed=new OrderList();
    buildingLimited = 15;
    ordersOpenLimited=3;
    this.exp = exp;
    professions = new ProfessionList();
    professions.addNewProfession("разнорабочий");
    workers = new WorkerList();
  }
  int getOrdersLimited() {
    return 5+getLevel();
  }
  void dispose() {
    opened.clear(); 
    closed.clear(); 
    failed.clear();
    workers.clear();
    professions.clear();
  }
  public String getInfo() {
    return  "общая информация:\n"+
      "наименование: "+name+"\n"+
      "размер компании"+": "+getLevel()+"\n"+
      "опыт компании"+": "+exp+"\n"+
      "лимит построек"+": "+buildingLimited+"\n"+
      "лимит новых заказов"+": "+getOrdersLimited()+"\n"+
      "лимит открытых заказов"+": "+ordersOpenLimited+"\n"+
      "работников: "+workers.size() +"\n";
  }
  public void update() {
    for (Worker worker : workers) {

      worker.updatePayday();

      if (worker.job==null) { //поиск работы
        if (worker.profession!=null) {
          if (worker.profession.jobs.hasValue(Job.SUPPLY)) { 
            //работа по выполнению закупки сырья
            WorkObject terminalPurchase = world.room.getAllObjects().getTerminals().getObjectsWorking().getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowProducts().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
            if (terminalPurchase!=null) {    
              worker.job = new JobInTerminal(worker, (Terminal)terminalPurchase, JobInTerminal.SUPPLY);
              continue;
            }
          }
          if (worker.profession.jobs.hasValue(Job.DEVELOP)) { 
            //работа по разработке новых изделий
            WorkObject productDevelop = world.room.getAllObjects().getDevelopBenches().getObjectsWorking().getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowProducts().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
            if (productDevelop!=null) {
              worker.job = new JobInTerminal(worker, (DevelopBench)productDevelop, JobInTerminal.DEVELOP);
              continue;
            }
          }
          if (worker.profession.jobs.hasValue(Job.CREATE)) { 
            //работа по созданию изделий
            WorkObject productBench = world.room.getAllObjects().getWorkBenches(Job.CREATE).getObjectsWorking().getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowProducts().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
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
            WorkObject productBench = world.room.getAllObjects().getWorkBenches(Job.ASSEMBLY).getObjectsWorking().getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowProducts().getNearestObject(worker.x, worker.y); //ищет терминалы в комнате
            if (productBench !=null) {
              Workbench bench = (Workbench)productBench;
              if (bench.isAllowCreate()) {
                worker.job = new JobInTerminal(worker, bench, JobInTerminal.ASSEMBLY);
                continue;
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
          if (worker.profession.jobs.hasValue(Job.CARRY)) { 
            //работа по переноске предметов в объект производства
            WorkObjectList objectsBenches = world.room.getAllObjects().getWorkBenches().getObjectsWorking().getObjectsAllowJob().getObjectsAllowMove(worker); 
            if (!objectsBenches.isEmpty()) {
              for (WorkObject object : objectsBenches) {
                Workbench workbench = (Workbench)object;
                if (workbench.product!=-1) {
                  //предметов на карте в объект производства
                  int needId=world.room.getShearchInItemMap(workbench.getNeedItems());
                  if (needId!=-1) {
                    int needItemCount = workbench.getNeedItemCount(needId);
                    WorkObject objectCarryComponent=null;
                    WorkObjectList itemsFree = world.room.getAllObjects().getItems().
                      getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowWeight(worker.capacity).getItemsById(needId);
                    if (!itemsFree.isEmpty()) 
                      objectCarryComponent=itemsFree.getNearestObject(worker.x, worker.y);
                    if (objectCarryComponent!=null) {
                      worker.job = new JobCarryItemMapForBench(worker, (ItemMap)objectCarryComponent, needItemCount, workbench);                
                      break;  //покидает цикл перебора объектов производства
                    }
                  }
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
                      if (d.getItem(itemCarry).weight<=worker.capacity) {
                        worker.job = new JobCarryItemForBench(worker, itemCarry, needItemCount, (Container)containerIsItemFree, workbench);                
                        break;
                      }
                    }
                  }
                }
              }
            }
            if (worker.job!=null)
              continue;
            //работа по перемещению предмета с карты в контейнер
            ItemMap itemMap=null;  //инициализирует предмет на карте
            WorkObjectList itemsMap = world.room.getAllObjects().getItems().
              getObjectsAllowJob().getObjectsAllowMove(worker).getObjectsAllowWeight(100).getObjectsSortNearest(worker); //ищет предмет в комнате
            if (!itemsMap.isEmpty()) { 
              for (WorkObject itemObject : itemsMap) {
                itemMap = (ItemMap)itemObject;
                int itemWeight=d.getItem(itemMap.item).weight;
                Container container=null;
                WorkObjectList containers = world.room.getAllObjects().getContainers().getContainersFreeCapacity().
                  getContainerForWeight(itemWeight).getObjectsAllowJob().getObjectsAllowMove(worker);  //ищет контейнер    
                if (!containers.isEmpty()) {
                  container = (Container)containers.getNearestObject(worker.x, worker.y);
                  if (container!= null) {
                    if (itemWeight<=worker.capacity)
                      worker.job = new JobCarryItemMap(worker, itemMap, container);
                    else
                      worker.job = new JobDrag(worker, itemMap, container);
                    break;
                  }
                }
              }
              if (worker.job!=null)
                continue;
            }
          }
          int x = int(random(world.room.sizeX));
          int y = int(random(world.room.sizeY));
          if (getPathTo(world.room.node[worker.x][worker.y], world.room.node[x][y])!=null) 
            worker.job= new JobMove (worker, world.room.node[x][y]);
        }
        
        
        
        
      } else {
        //если работа есть
      }
    }
    money=getDecimalFormat(money);
    if (money<=0) {
      dialog.showWarningDialog("Игра проиграна ", "Сообщение");
      exit();
    }
  }
  void addWorker(String name, int capacity) {
    Worker worker = new Worker(0, 0, workers.getLastId(), name, capacity, professions.get(0));
    workers.add(worker);
  }
  void setExpenses() {
    float sum_money=0;
    for (Worker worker : workers) 
      sum_money+=worker.payday;
    money-=sum_money;
    printConsole("[РАСХОД] заработная плата рабочим: "+sum_money+" $");
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
