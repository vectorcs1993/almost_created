
class JobMove extends Job {   //работа по перемещению 
  Graph target;
  JobMove (Worker worker, Graph target) {
    super(worker);
    this.target=target;
    worker.moveTo(target.x, target.y);
  }
  boolean isComplete() {
    return  worker.x==target.x && worker.y==target.y || exit;
  }
  String getStatus() {
    return "идет в:"+" "+target.x+","+target.y;
  }
  void update() {
    if (getPathTo(world.room.node[worker.x][worker.y], target)==null)
      cancel();
    if (worker.path!=null) { //если путь не найден
      if (!worker.path.isEmpty()) { //если путь не завершен
        if (worker.path.isSolid()) {//если на пути следования появляется препятствие
          worker.moveTo(target.x, target.y);  //путь перестраивается
        } else
          worker.moveNextPoint(); //продолжается следование по пути
      }
    } else
      worker.moveTo(target.x, target.y); //ищет новый путь
  }
  void close() {
    super.close();
    target=null;
  }
}
class JobInTerminal extends Job {
  Terminal terminal;
  JobMove moveToTerminal; 
  int work;
  JobInTerminal (Worker worker, Terminal terminal, int work) {
    super(worker);
    this.work=work;
    this.terminal=terminal;
    this.terminal.job=this;
    int [] place = world.getPlace(terminal.getX(), terminal.getY(), terminal.direction);
    Graph targetTerminal = world.room.node[place[0]][place[1]];
    moveToTerminal = new JobMove(worker, targetTerminal);
  }
  boolean isComplete() {
    return terminal.label!=null;
  }
  String getStatus() {
    if (work==SUPPLY)
      return "закупает "+terminal.product.name;
    else if (work==DEVELOP)
      return "разрабатывает чертеж "+terminal.product.name;
    else if (work== CREATE)
      return "создает "+terminal.product.name;
    else 
    return null;
  }
  void update() {
    if (!moveToTerminal.isComplete())
      moveToTerminal.update();
    else {
      terminal.work();
      this.worker.work(work);
      this.worker.setDirection(terminal.getX(), terminal.getY());
    }
  }
  void close() {
    super.close();
    moveToTerminal.close();
    moveToTerminal=null;
    terminal.job=null;
    terminal= null;
  }
}
class JobPutInContainerItem extends JobProgress {
  Item item;
  Container container;
  JobPutInContainerItem(Worker worker, Item item, Container container) {
    super(worker, container, 0, 10);
    this.item = item;
    this.container=container;
  }
  String getName() {
    return "кладет предмет";
  }
  void onAction() {
    for (int i = worker.items.size()-1; i>=0; i--) {
      if (container.isFreeCapacity()) {
        Item item  =  worker.items.get(i);
        container.items.add(item);
        worker.items.remove(item);
      } else break;
    }
    if (!worker.items.isEmpty()) {
      for (int id_item : worker.items.sortItem()) 
        world.room.addItem(this.worker.x, this.worker.y, id_item, worker.items.calculationItem(id_item));
      worker.items.clear();
    }
  }
  void close() {
    super.close();
    item= null;
    container=null;
  }
}
class JobPutInBenchItem extends JobProgress {
  Item item;
  Workbench bench;
  JobPutInBenchItem(Worker worker, Item item, Workbench bench) {
    super(worker, bench, 0, 10);
    this.item = item;
    this.bench=bench;
  }
  String getName() {
    return "кладет предмет";
  }
  void onAction() {
    bench.components.addAll(worker.items);
    worker.items.clear();
  }
  void close() {
    super.close();
    item= null;
    bench=null;
  }
}
class JobPutInWorkerItemMap extends JobProgress {
  ItemMap itemMap;
  JobPutInWorkerItemMap(Worker worker, ItemMap itemMap) {
    super(worker, itemMap, 0, 10);
    this.itemMap = itemMap;
  }
  String getName() {
    return "берет предмет";
  }
  void onAction() {
    int count_remove = constrain(this.worker.capacity, 1, itemMap.count);
    worker.items.addItemCount(new Item(itemMap.item), count_remove);
    itemMap.count-=count_remove;
    if (itemMap.count<=0) {
      world.room.removeObject(itemMap);
      itemMap=null;
    }
  }
  void close() {
    super.close();
    itemMap= null;
  }
}
class JobPutInWorkerItem extends JobProgress {
  int item, count;
  Container container;
  JobPutInWorkerItem(Worker worker, int item, int count, Container container) {
    super(worker, container, 0, 10);
    this.item=item;
    this.count=count;
    this.container = container;
  }
  String getName() {
    return "берет предмет";
  }
  void onAction() {
    worker.items.addItemCount(new Item(item), count);
    container.items.removeItemCount(item, count);
  }
  void close() {
    super.close();
    container= null;
  }
}
class JobCarry extends Job {
  JobMove move, moveFromObject, moveToObject;
  JobProgress inWorker, inObject;
  JobCarry(Worker worker) {
    super(worker);
    move=null;
  }
  boolean isComplete() {
    return exit;
  }
  String getStatus() {
    return "переносит ";
  }
  void update() {
    this.worker.work(Job.CARRY);
    if (!move.isComplete())
      move.update();
    else {
      if (move==moveFromObject) {
        if (!inWorker.isComplete()) 
          inWorker.update();
        else {
          move= moveToObject;
          worker.moveTo(move.target.x, move.target.y);
        }
      } else if (move==moveToObject) {
        if (!inObject.isComplete()) 
          inObject.update();
        else
          exit=true;
      }
    }
    if (getPathTo(world.room.node[worker.x][worker.y], move.target)==null)
      cancel();
  }
  String getDescript() {
    if (!move.isComplete() && !inWorker.isComplete() && !inObject.isComplete() && move==moveFromObject) 
      return moveFromObject.getStatus();
    else if (move.isComplete() && !inWorker.isComplete() && !inObject.isComplete() && move==moveFromObject) 
      return inWorker.getStatus();
    else if (!move.isComplete() && inWorker.isComplete() && !inObject.isComplete() && move== moveToObject) 
      return moveFromObject.getStatus();
    else if (move.isComplete() && inWorker.isComplete() && !inObject.isComplete() && move== moveToObject) 
      return inObject.getStatus();
    else 
    return "не понятно";
  }
  int getProcess() {
    if (move.isComplete() && !inWorker.isComplete() && !inObject.isComplete() && move==moveFromObject) 
      return inWorker.process;
    else if (move.isComplete() && inWorker.isComplete() && !inObject.isComplete() && move== moveToObject) 
      return inObject.process;
    else return 0;
  }
  int getProcessMax() {
    if (move.isComplete() && !inWorker.isComplete() && !inObject.isComplete() && move==moveFromObject) 
      return inWorker.processMax;
    else if (move.isComplete() && inWorker.isComplete() && !inObject.isComplete() && move== moveToObject) 
      return inObject.processMax;
    else return 0;
  }
  void cancel() {
    if (inWorker.isComplete()) {
      for (int item : worker.items.sortItem())
        world.room.addItem(this.worker.x, this.worker.y, item, worker.items.calculationItem(item));
      this.worker.items.clear();
    }
    super.cancel();
  }
  void close() {
    super.close();
    moveToObject.close();
    move =null;
    moveToObject=null;
    moveFromObject.close();
    moveFromObject=null;
    inWorker.close();
    inWorker=null;
    inObject.close();
    inObject=null;
  }
}
class JobCarryItemMap extends JobCarry {
  ItemMap itemMap;
  Container container;
  JobCarryItemMap(Worker worker, ItemMap itemMap, Container container) {
    super(worker);
    this.itemMap=itemMap;
    this.itemMap.job=this;
    Graph targetItemMap = getNeighboring(world.room.node[itemMap.getX()][itemMap.getY()], null).getGraphFreePath(worker.x, worker.y);
    this.container=container;
    this.container.job=this;
    Graph targetContainer = getNeighboring(world.room.node[container.getX()][container.getY()], null).getGraphFreePath(worker.x, worker.y);
    moveToObject = new JobMove(worker, targetContainer);
    move = moveFromObject = new JobMove(worker, targetItemMap);
    inWorker = new JobPutInWorkerItemMap (worker, itemMap);
    inObject = new JobPutInContainerItem (worker, new Item(itemMap.item), container);
  }
  String getStatus() {
    return super.getStatus()+itemMap.name+" в "+container.name+"\n("+getDescript()+")";
  }
  void close() {
    super.close();
    itemMap.job=null;
    itemMap=null;
    container.job=null;
    container=null;
  }
}
class JobCarryItemForBench extends JobCarry {
  int item;
  Workbench bench;
  Container container;

  JobCarryItemForBench(Worker worker, int item, Container container, Workbench bench) {
    super(worker);
    this.item=item;
    this.container=container;
    this.container.job=this;
    Graph targetContainer = getNeighboring(world.room.node[container.getX()][container.getY()], null).getGraphFreePath(worker.x, worker.y);
    moveFromObject = new JobMove(worker, targetContainer);
    this.bench=bench;
    this.bench.job=this;
    Graph targetBench = getNeighboring(world.room.node[bench.getX()][bench.getY()], null).getGraphFreePath(worker.x, worker.y);
    moveToObject = new JobMove(worker, targetBench);
    move = moveFromObject = new JobMove(worker, targetContainer);
    inWorker = new JobPutInWorkerItem (worker, item, 1, container);
    inObject = new JobPutInBenchItem (worker, new Item(item), bench);
  }
  String getStatus() {
    return super.getStatus()+data.items.getId(item).name+" из: "+container.name+" в: "+bench.name+
      "\n("+getDescript()+")";
  }
  void close() {
    super.close();
    bench.job=null;
    bench=null;
    container.job=null;
    container=null;
  }
}
class JobCarryItemMapForBench extends JobCarry {
  int item;
  Workbench bench;
  ItemMap itemMap;
  JobCarryItemMapForBench(Worker worker, ItemMap itemMap, Workbench bench) {
    super(worker);
    this.itemMap=itemMap;
    this.itemMap.job=this;
    Graph targetItemMap = getNeighboring(world.room.node[itemMap.getX()][itemMap.getY()], null).getGraphFreePath(worker.x, worker.y);
    this.bench=bench;
    this.bench.job=this;
    Graph targetBench = getNeighboring(world.room.node[bench.getX()][bench.getY()], null).getGraphFreePath(worker.x, worker.y);
    moveToObject = new JobMove(worker, targetBench);
    move = moveFromObject = new JobMove(worker, targetItemMap);
    inWorker = new JobPutInWorkerItemMap (worker, itemMap);
    inObject = new JobPutInBenchItem (worker, new Item(item), bench);
  }
  String getStatus() {
    return super.getStatus()+data.items.getId(item).name+" в: "+bench.name+
      "\n("+getDescript()+")";
  }
  void close() {
    super.close();
    bench.job=null;
    bench=null;
    itemMap.job=null;
    itemMap=null;
  }
}
class JobRepair extends Job {
  JobMove moveToObject;
  Terminal terminal;
  JobRepair (Worker worker, Terminal terminal) {
    super(worker);
    this.terminal=terminal;
    this.terminal.job=this;
    Graph targetBench = getNeighboring(world.room.node[terminal.getX()][terminal.getY()], null).getGraphFreePath(worker.x, worker.y);
    moveToObject = new JobMove(worker, targetBench);
  }
  boolean isComplete() {
    return terminal.hp>=100;
  }
  String getStatus() {
    return "ремонтирует объект: "+terminal.name;
  }
  void update() {
    if (!moveToObject.isComplete())
      moveToObject.update();
    else {
      terminal.hp++;
      this.worker.work(Job.REPAIR);
      constrain(terminal.hp, 0, terminal.hp_max);
      this.worker.setDirection(terminal.getX(), terminal.getY());
    }
  }
  void close() {
    super.close();
    terminal.job=null;
    terminal=null;
  }
}
