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
    return "передвигается";
  }
  void update() {
    if (getPathTo(world.room.node[worker.x][worker.y], target)==null)
      cancel();
    if (worker.path!=null) { //если путь не найден
      if (!worker.path.isEmpty()) { //если путь не завершен
        if (worker.path.isSolid()) //если на пути следования появляется препятствие
          worker.moveTo(target.x, target.y);  //путь перестраивается
        else
          moveWorker();
      }
    } else
      worker.moveTo(target.x, target.y); //ищет новый путь
  }
  void moveWorker() {
    worker.moveNextPoint(); //продолжается следование по пути
  }

  void close() {
    super.close();
    target=null;
  }
  int getType() {
    return MOVE;
  }
}
class JobMoveWithItemMap extends JobMove {   //работа по перетаскиванию большого предмета
  ItemMap itemMap;
  JobMoveWithItemMap(Worker worker, Graph target, ItemMap itemMap) {
    super(worker, target);
    this.itemMap=itemMap;
  }
  String getStatus() {
    return "передвигает "+itemMap.name;
  }
  void moveWorker() {
    worker.moveNextPointWithItemMap(itemMap);
  }
  void close() {
    super.close();
    itemMap=null;
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
    if (exit)
      return true;
    if (terminal.label==null) 
      return terminal.product==-1;
    else 
    return terminal.label!=null;
  }
  String getStatus() {
    if (terminal.product!=-1) {
      if (work==SUPPLY)
        return d.label.get("job_supplies")+" "+d.getName("items", terminal.product);
      else if (work==DEVELOP)
        return d.label.get("job_develops")+" "+d.getName("items", terminal.product);
      else if (work== CREATE)
        return d.label.get("job_created")+" "+d.getName("items", terminal.product);
      else if (work== ASSEMBLY)
        return d.label.get("job_assemble")+" "+d.getName("items", terminal.product);
      else 
      return "ожидание";
    } else 
    return "ожидание";
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
  int getType() {
    if (!moveToTerminal.isComplete())
      return CARRY;
    else
      return work;
  }
}
class JobPutInContainerItem extends JobProgress {
  int item;
  Container container;
  JobPutInContainerItem(Worker worker, int item, Container container) {
    super(worker, container, 0, 10);
    this.item = item;
    this.container=container;
  }
  String getName() {
    return d.label.get("job_puts");
  }
  void onAction() {
    for (int i = worker.items.size()-1; i>=0; i--) {
      if (container.isFreeCapacity()) {
        container.items.append(item);
        worker.items.removeValue(item);
      } else break;
    }
    if (worker.items.size()>0) {
      for (int id_item : worker.items.sortItem()) 
        world.room.addItem(this.worker.x, this.worker.y, id_item, worker.items.calculationItem(id_item));
      worker.items.clear();
    }
  }
  void close() {
    super.close();
    item= -1;
    container=null;
  }
  int getType() {
    return CARRY;
  }
}
class JobPutInBenchItem extends JobProgress {
  int item;
  Workbench bench;
  JobPutInBenchItem(Worker worker, int item, Workbench bench) {
    super(worker, bench, 0, 10);
    this.item = item;
    this.bench=bench;
  }
  String getName() {
    return d.label.get("job_puts");
  }
  void onAction() {
    bench.components.addAll(worker.items);
    worker.items.clear();
  }
  void close() {
    super.close();
    item= -1;
    bench=null;
  }
  int getType() {
    return CARRY;
  }
}
class JobPutInWorkerItemMap extends JobProgress {
  ItemMap itemMap;
  int needCount;
  JobPutInWorkerItemMap(Worker worker, ItemMap itemMap, int needCount) {
    super(worker, itemMap, 0, 10);
    this.itemMap = itemMap;
    this.needCount=needCount;
  }
  String getName() {
    return d.label.get("job_takes");
  }
  void onAction() {
    int count_remove = constrain(this.worker.capacity, 1, constrain(itemMap.count, 1, needCount));
    worker.items.setComponents(itemMap.item, count_remove);
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
  int getType() {
    return CARRY;
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
    return d.label.get("job_takes");
  }
  void onAction() {
    worker.items.setComponents(item, count);
    container.items.removeItems(item, count);
  }

  void close() {
    super.close();
    container= null;
  }
  int getType() {
    return CARRY;
  }
}
class JobPutInContainerItemMapLarge extends JobProgress {
  ItemMap itemMap;
  Container container;
  JobPutInContainerItemMapLarge(Worker worker, ItemMap itemMap, Container container) {
    super(worker, container, 0, 10);
    this.itemMap=itemMap;
    this.container = container;
  }
  String getName() {
    return d.label.get("job_takes");
  }
  void onAction() {
    container.items.setComponents(itemMap.item, itemMap.count);
    world.room.removeObject(itemMap);
  }
  void close() {
    super.close();
    container.job=null;
    itemMap.job=null;
    container= null;
    itemMap= null;
  }
  int getType() {
    return CARRY;
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
    return d.label.get("job_transfers");
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
    return "ожидание";
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
      worker.removeItems();
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
  int getType() {
    return CARRY;
  }
}
class JobDrag extends JobCarry {
  ItemMap itemMap;
  Container container;
  JobDrag(Worker worker, ItemMap itemMap, Container container) {
    super(worker);
    this.itemMap=itemMap;
    this.itemMap.job=this;
    Graph targetItemMap = getNeighboring(world.room.node[itemMap.getX()][itemMap.getY()], null).getGraphFreePath(worker.x, worker.y);
    this.container=container;
    this.container.job=this;
    Graph targetContainer = getNeighboring(world.room.node[container.getX()][container.getY()], null).getGraphFreePath(worker.x, worker.y);
    moveToObject = new JobMoveWithItemMap(worker, targetContainer, itemMap);
    move = moveFromObject = new JobMove(worker, targetItemMap);
    inWorker = new JobPutInWorkerItemMap (worker, itemMap, worker.capacity);
    inObject = new JobPutInContainerItemMapLarge (worker, itemMap, container);
  }
  void update() {
    this.worker.work(Job.CARRY);
    if (!move.isComplete())
      move.update();
    else {
      if (move==moveFromObject) {
        if (!inWorker.isComplete()) 
          inWorker.process=inWorker.processMax;
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
    inWorker = new JobPutInWorkerItemMap (worker, itemMap, worker.capacity);
    inObject = new JobPutInContainerItem (worker, itemMap.item, container);
  }
  String getStatus() {
    return super.getStatus()+" "+itemMap.name+" в "+container.name+" ("+getDescript()+")";
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

  JobCarryItemForBench(Worker worker, int item, int needCount, Container container, Workbench bench) {
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
    inWorker = new JobPutInWorkerItem (worker, item, constrain(worker.capacity, 1, constrain(container.items.calculationItem(item), 1, needCount)), container);
    inObject = new JobPutInBenchItem (worker, item, bench);
  }
  String getStatus() {
    return super.getStatus()+" "+d.getName("items", item)+" из "+container.name+" в "+bench.name+
      " ("+getDescript()+")";
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
  JobCarryItemMapForBench(Worker worker, ItemMap itemMap, int needCount, Workbench bench) {
    super(worker);
    this.itemMap=itemMap;
    this.itemMap.job=this;
    Graph targetItemMap = getNeighboring(world.room.node[itemMap.getX()][itemMap.getY()], null).getGraphFreePath(worker.x, worker.y);
    this.bench=bench;
    this.bench.job=this;
    Graph targetBench = getNeighboring(world.room.node[bench.getX()][bench.getY()], null).getGraphFreePath(worker.x, worker.y);
    moveToObject = new JobMove(worker, targetBench);
    move = moveFromObject = new JobMove(worker, targetItemMap);
    inWorker = new JobPutInWorkerItemMap (worker, itemMap, needCount);
    inObject = new JobPutInBenchItem (worker, item, bench);
  }
  String getStatus() {
    return super.getStatus()+" "+d.getName("items", item)+" в "+bench.name+" ("+getDescript()+")";
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
    float maxHp = d.objects.getId(terminal.id).maxHp;
    if (terminal.hp>=maxHp)
      printConsole("объект "+terminal.name+" восстановлен");
    return terminal.hp>=maxHp;
  }
  String getStatus() {
    return d.label.get("job_repaired")+" "+terminal.name;
  }
  void update() {
    if (!moveToObject.isComplete())
      moveToObject.update();
    else {
      terminal.hp++;
      this.worker.work(Job.REPAIR);
      constrain(terminal.hp, 0, d.objects.getId(terminal.id).maxHp);
      this.worker.setDirection(terminal.getX(), terminal.getY());
    }
  }
  void close() {
    super.close();
    terminal.job=null;
    terminal=null;
  }
  int getType() {
    if (!moveToObject.isComplete())
      return CARRY;
    else
      return REPAIR;
  }
}
