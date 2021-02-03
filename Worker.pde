PImage spr_worker;
int max_skill_level=5;

class Worker extends WorkObject {
  float cost, payday;
  int x, y, capacity;
  PImage sprite;
  HashMap skills_values, skills_levels;
  ComponentList items;
  Profession profession;

  //служебные для поиска пути
  GraphList path;
  Graph target, nextNode;
  Timer update, upgrade;

  Worker (int id, String name, int capacity) {
    super(-1);
    this.id=id;
    this.capacity=capacity;
    cost = 500;  
    payday = 10;
    x=y=direction=0;
    sprite = spr_worker;
    path = new GraphList ();
    target = nextNode = null;
    update = new Timer();
    upgrade = new Timer();
    items = new ComponentList(data.items);
    this.name = name;
    profession = null;
    skills_values = createSkillsValues();
    skills_levels = createSkillsLevels();
  }
  void draw() {
    pushMatrix();
    pushStyle();
    translate(x*world.size_grid+(world.size_grid/2), y*world.size_grid+(world.size_grid/2));
    rotate(getDirectionRad());
    image(sprite, -world.size_grid/2, -world.size_grid/2);
    if (items.size()>0)
      image(data.getItem(items.get(0)).sprite, -world.size_grid/2, -world.size_grid/2-13);
    popStyle();
    popMatrix();
  }
  void drawSelected() {
    pushStyle();
    noFill();
    stroke(green);
    strokeWeight(3);
    rect(x*world.size_grid, y*world.size_grid, world.size_grid, world.size_grid);
    popStyle();
  }
  String getDescriptList() {
    return "табельный номер: "+id+"\n"
      +"работа: "+getJobDescript()+"\n"
      +"должность: "+getProfessionDescript()+"\n"
      +"зарплата: "+payday+" $/день"+"\n"
      +"грузоподъемность: "+capacity+"\n"
      +getSkills()+"\n";
  }

  String getDescript() {
    return name+"\n"+getDescriptList();
  }
  String getJobDescript() {
    if (job!=null)
      return job.getStatus();
    else
      return "нет";
  }
  String getProfessionDescript() {
    if (profession!=null)
      return profession.name;
    else
      return "не назначена";
  }
  HashMap createSkillsValues() {
    HashMap skills = new HashMap <Integer, Integer>(); 
    for (int i : getAllSkills())
      skills.put(i, 0);
    return skills;
  }
  HashMap createSkillsLevels() {
    HashMap skills = new HashMap <Integer, Integer>(); 
    for (int i : getAllSkills())
      skills.put(i, 1);
    return skills;
  }
  String getSkills() {
    String string = "";
    for (int skill : getAllSkills()) {
      if (skills_values.get(skill).hashCode()!=0)
        string+=getSkillName(skill)+": "+skills_levels.get(skill).hashCode()+" ("+skills_values.get(skill).hashCode()+")\n";
      else
        string+=getSkillName(skill)+": "+skills_levels.get(skill).hashCode()+"\n";
    }
    return string;
  }
  int [] getAllSkills() {
    return new int [] {Job.CARRY, Job.DEVELOP, Job.REPAIR, Job.CREATE, Job.ASSEMBLY, Job.SUPPLY};
  }
  void update() {
    if (!update.check() && !world.pause) {  //если пришло время обновления
      int timer = 10;
      if (job!=null) {
        timer = getWorkModificator(job.getType()); 
        if (job.isComplete()) 
          cancelJob();
        else 
        job.update();
      }
      update.set(map(timer, 0, max_skill_level, 400, 50));
    }
    draw();
    if (job!=null) {
      pushMatrix();
      translate(x*world.size_grid+world.size_grid/2, y*world.size_grid+world.size_grid/2);
      drawStatus(9, job.getProcess(), job.getProcessMax(), yellow, red);
      popMatrix();
    }
  }
  void cancelJob() {
    job.close();
    job=null;
  }
  float getDirectionRad() {
    switch (direction) {
    case 1:   //направо
      return radians(90);
    case 2:  //вниз
      return radians(180);
    case 3:  //влево
      return radians(270);
    case 4:  //вверх-вправо
      return radians(45);
    case 5:  //вниз-вправо
      return radians(135);
    case 6:  //вниз-влево
      return radians(-135);
    case 7:  //вверх-влево
      return radians(-45);
    default:  //вверх
      return radians(0);
    }
  }
  public void moveTo(int x, int y) {
    if (!world.room.node[x][y].solid) {
      target=world.room.node[x][y];
      if (path!=null) 
        path.clear();
      path=getPathTo(world.room.node[this.x][this.y], world.room.node[x][y]);
      if (path!=null) {
        if (path!=null) 
          if (!path.isEmpty())
            target=path.get(0);
      }
    }
  }
  public void moveTo(Graph object) {
    if (object.x<x && object.y==y) { //влево          270              
      x-=1;
    } else if (object.x>x && object.y==y) {       //вправо 90
      x+=1;
    } else if (object.y<y && object.x==x) {      //вверх 0
      y-=1;
    } else if (object.y>y && object.x==x) {   //вниз 180
      y+=1;
    } else if (object.x<x && object.y<y) {  //влево  и вверх -45                      
      x-=1;
      y-=1;
    } else if (object.x>x && object.y<y) {  //вправо и вверх 45                      
      x+=1;
      y-=1;
    } else if (object.x>x && object.y>y) { //вправо и вниз 135                      
      x+=1;
      y+=1;
    } else if (object.x<x && object.y>y) {  //влево и вниз -135                      
      x-=1;
      y+=1;
    } 
    x=constrain(object.x, 0, world.room.sizeX-1);                             
    y=constrain(object.y, 0, world.room.sizeY-1);
  }
  void moveNextPoint() {
    if (!path.isEmpty()) {
      nextNode=path.get(path.size()-1);
      if (!nextNode.solid) { 
        if (direction!=getDirectionToObject(nextNode.x, nextNode.y)) 
          setDirection(nextNode.x, nextNode.y);
        else {
          moveTo(nextNode);
          path.remove(nextNode);
        }
      }
    }
  }
  void work(int work) {
    if (max_skill_level>getWorkModificator(work)) {   //если уровень рабочего не превышает максимальный
      int skill =  skills_values.get(work).hashCode()+1;
      skills_values.put(work, skill);
      int level = skills_levels.get(work).hashCode();
      if (skills_values.get(work).hashCode()>=getExpForLevel(level)) {
        skills_levels.put(work, level+1);
        printConsole("рабочий "+name+" достиг уровня: "+str(level+1)+" в навыке "+getSkillName(work));
      }
    }
  }
  private int getExpForLevel(int level) { //функция возвращает порог опыта для соответствующего ему уровня level
    return int(1000*pow(2, level-1));
  }
  int getWorkModificator(int work) {
    if (work==Job.MOVE) { //если рабочий просто бродит то его скорость равна максимальной скорости при транспортировке
      work=Job.CARRY;
      return skills_levels.get(Job.CARRY).hashCode();    
    } else 
    return skills_levels.get(work).hashCode();
  }
  private void setDirection(int x, int y) {
    if (x<this.x && y==this.y)
      direction=3;
    if (x>this.x && y==this.y)
      direction=1;
    if (y<this.y && x==this.x)
      direction=0;
    if (y>this.y && x==this.x)
      direction=2;
    if (y<this.y && x<this.x)
      direction=7;
    if (y<this.y && x>this.x)
      direction=4;
    if (y>this.y && x>this.x)
      direction=5;
    if (y>this.y && x<this.x)
      direction=6;
  }
  private int getDirectionToObject(int x, int y) {
    if (x<this.x && y==this.y)
      return 3;
    if (x>this.x && y==this.y)
      return 1;
    if (y<this.y && x==this.x)
      return 0;
    if (y>this.y && x==this.x)
      return 2;
    if (y<this.y && x<this.x)
      return 7;
    if (y<this.y && x>this.x)
      return 4;
    if (y>this.y && x>this.x)
      return 5;
    if (y>this.y && x<this.x)
      return 6;
    else 
    return -1;
  }
  public void drawPath() {   //функция отображает путь выбранного персонажа
    if (target!=null) {
      pushMatrix();
      translate(target.x*world.size_grid, target.y*world.size_grid);
      noFill();
      strokeWeight(3);
      stroke(blue);
      rect(0, 0, world.size_grid, world.size_grid);
      popMatrix();
    }
    noFill();
    strokeWeight(2);
    stroke(white);
    if (path!=null) {
      if (!path.isEmpty()) {
        line(world.room.getAbsCoord(x, y)[0], world.room.getAbsCoord(x, y)[1], 
          world.room.getAbsCoord(path.get(path.size()-1).x, path.get(path.size()-1).y)[0], world.room.getAbsCoord(path.get(path.size()-1).x, path.get(path.size()-1).y)[1] );
        int sizeMap= path.size()-1;
        for (int i=0; i<sizeMap; i++) {
          Graph next = path.get(i);
          Graph part = path.get(i+1);
          line(world.room.getAbsCoord(next.x, next.y)[0], 
            world.room.getAbsCoord(next.x, next.y)[1]
            , world.room.getAbsCoord(part.x, part.y)[0], 
            world.room.getAbsCoord(part.x, part.y)[1]);
        }
      }
    }
  }
}

class WorkerList extends ArrayList <Worker> {
  int getLastWorkerId() {
    if (this.isEmpty())
      return 1;
    IntList s = new IntList();
    for (Worker part : this) 
      s.append(part.id);
    return s.max()+1;
  }
  Worker getCurrentWorker() {
    for (Worker worker : this) {
      if (worker==world.room.currentObject)
        return worker;
    }
    return null;
  }
  Worker getWorkerIsId(int id) {
    for (Worker worker : this) {
      if (worker.id==id)
        return worker;
    }
    return null;
  }
  public void removeWorkerId(int id) {
    for (int i=this.size()-1; i>=0; i--) {
      Worker worker = this.get(i);
      if (this.get(i).id==id) {
        if (worker.job!=null) 
          worker.cancelJob();
        this.remove(i);
        break;
      }
    }
  }
  WorkerList getWorkers(int x, int y) {
    WorkerList people  = new WorkerList();
    for (Worker worker : this) {
      if (worker.x==x && worker.y==y)
        people.add(worker);
    }
    return people;
  }

  WorkerList getWorkers(Profession profession) {
    WorkerList people  = new WorkerList();
    for (Worker worker : this) {
      if (worker.profession==profession)
        people.add(worker);
    }
    return people;
  }
  String getNames() {
    String names="";
    for (Worker worker : this) {
      names+=worker.name;
      if (this.indexOf(worker)!=this.size()-1)
        names+=", ";
    }
    return names;
  }
}


class ProfessionList extends ArrayList <Profession> {
  void addNewProfession(String name) {
    this.add(new Profession(name, new int [] {Job.CARRY, Job.DEVELOP, Job.CREATE, Job.ASSEMBLY, Job.SUPPLY, Job.REPAIR}));
  }

  Profession getProfessionIsName(String name) {
    for (Profession profession : this) {
      if (profession.name.equals(name)) 
        return profession;
    }
    return null;
  }

  void removeProfessionIsName(String name) {
    Profession profession = getProfessionIsName(name);
    if (profession!=null)
      this.remove(profession);
  }
  String [] getList() {
    String [] list = new String [this.size()+1];
    list[0]="не выбрано";
    int i = 1;
    for (Profession profession : this) {
      list[i]=profession.name;
      i++;
    }
    return list;
  }
}


class Profession {
  String name;
  IntList jobs;
  Profession (String name, int [] jobs) {
    this.name = name;
    this.jobs = new IntList();
    for (int job : jobs)
      this.jobs.append(job);
  }
}
