PImage worker;


class Worker extends WorkObject {
  String name;
  float cost, payday;
  int x, y, direction;
  PImage sprite;

  //служебные для поиска пути
  private GraphList path;
  private Graph target, nextNode;

  Timer update;

  Worker (int id) {
    super(-1);
    this.id=id;
    cost = 500;  
    payday = 50;
    x=y=direction=0;
    sprite = worker;
    path = new GraphList ();
    target = nextNode = null;
    update = new Timer();
    name = "worker "+id;
  }
  void draw() {
    pushMatrix();
    pushStyle();
    translate(x*world.size_grid+(world.size_grid/2), y*world.size_grid+(world.size_grid/2));
    rotate(getDirectionRad(direction));
    image(sprite, -world.size_grid/2, -world.size_grid/2);
    popStyle();
    popMatrix();
  }
  public void drawSelected() {
    pushStyle();
    noFill();
    stroke(green);
    strokeWeight(3);
    rect(x*world.size_grid, y*world.size_grid, world.size_grid, world.size_grid);
    popStyle();
  }
  public String getDescript() {
    return "рабочий: "+name+"\n"
      +"зарплата: "+payday+" $/день";
  }
  void update() {
    if (!update.check() && !world.pause) {
      if (path!=null) {
        if  (path.isEmpty()) {
          int x=  int(random(10));
          int y = int(random(10));
          if (getPathTo(world.room.node[this.x][this.y], world.room.node[x][y])!=null)
            moveTo(x, y);
        } else {
          if (path.isSolid()) {
            int x=  int(random(10));
            int y = int(random(10));
            if (getPathTo(world.room.node[this.x][this.y], world.room.node[x][y])!=null)
              moveTo(x, y);
          } else
            moveNextPoint();
        }
      }
      update.set(300);
    }
    draw();
  }


  protected float getDirectionRad(int dir) {
    dir=constrain(dir, 0, 7);
    switch (dir) {
    case 1: 
      return radians(90);
    case 2:  
      return radians(180);
    case 3:  
      return radians(270);
    case 4:  
      return radians(45);
    case 5:  
      return radians(135);
    case 6:  
      return radians(-135);
    case 7:  
      return radians(-45);
    default:  
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
        int pathFull=path.size();
        if (path!=null) 
          if (!path.isEmpty())
            target=path.get(0);
      }
    }
  }
  public void moveTo(Graph object) {
    int oldx=x;
    int oldy=y;
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
    world.room.node[oldx][oldy].solid=false;
    world.room.node[x][y].solid=true;
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
