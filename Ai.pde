int [][] matrixShearch = new int [122][2];
int [] matrixRadius = { 59, 49, 61, 71, 48, 50, 72, 70, //1 радиус
  47, 36, 37, 38, 39, 40, 51, 62, 73, 84, 83, 82, 81, 80, 69, 58, //2 радиус
  46, 35, 24, 25, 26, 27, 28, 29, 30, 41, 52, 63, 74, 85, 96, 95, 94, 93, 92, 91, 90, 79, 68, 57, //3 радиус
  56, 45, 34, 23, 12, 13, 14, 15, 16, 17, 18, 19, 20, 31, 42, 53, 64, 75, 86, 97, 108, 107, 106, 105, 104, 103, 102, 101, 100, 89, 78, 67, //4 радиус
  55, 44, 33, 22, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 21, 32, 43, 54, 65, 76, 87, 98, 109, 120, 119, 118, 117, 116, 115, 114, 113, 112, 111, 110, 99, 88, 77, 66}; //5 радиус 
int [][] matrixLine ={ {49, 38, 27, 16, 5}, //линия 0
  {71, 82, 93, 104, 115}, //линия 1
  {59, 58, 57, 56, 55}, //линия 2
  {61, 62, 63, 64, 65}, //линия 3

  //вспомогательные
  {72, 84, 96, 108}, //линия 4
  {70, 80, 90, 100}, //линия 5
  {48, 36, 24, 12}, //линия 6
  {50, 40, 30, 20}, //линия 7
  //юго-запад
  {50, 39, 28, 17, 6}, //линия 8
  {50, 40, 29, 18, 7}, //линия 9
  {50, 40, 30, 19, 8}, //линия 10
  {50, 40, 30, 20, 9}, //линия 11
  {50, 40, 30, 20, 21}, //линия 12
  {50, 40, 30, 31, 32}, //линия 13
  {50, 40, 41, 42, 43}, //линия 14
  {50, 51, 52, 53, 54}, //линия 15

  {72, 73, 74, 75, 76}, //линия 16
  {72, 84, 85, 86, 87}, //линия 17
  {72, 84, 96, 97, 98}, //линия 18
  {72, 84, 96, 108, 109}, //линия 19
  {72, 84, 96, 108, 119}, //линия 20
  {72, 84, 96, 107, 118}, //линия 21
  {72, 84, 95, 106, 117}, //линия 22
  {72, 83, 94, 105, 116}, //линия 23

  {70, 81, 92, 103, 114}, //линия 24
  {70, 80, 91, 102, 113}, //линия 25
  {70, 80, 90, 101, 112}, //линия 26
  {70, 80, 90, 100, 111}, //линия 27
  {70, 80, 90, 100, 99}, //линия 28
  {70, 80, 90, 89, 88}, //линия 29
  {70, 80, 79, 78, 77}, //линия 30
  {70, 69, 68, 67, 66}, //линия 31


  {48, 47, 46, 45, 44}, //линия 32
  {48, 36, 35, 34, 33}, //линия 33
  {48, 36, 24, 23, 22}, //линия 34
  {48, 36, 24, 12, 11}, //линия 35
  {48, 36, 24, 12, 1}, //линия 36
  {48, 36, 24, 13, 2}, //линия 37
  {48, 36, 25, 14, 3}, //линия 38
  {48, 37, 26, 15, 4}, //линия 39

};



class Graph {
  int x, y; 
  float g, f, h;
  boolean solid;
  Graph parent;

  Graph (int x, int y, boolean solid) {
    this.solid=solid;
    this.x=x;
    this.y=y;
  }
  Graph (int x, int y) {
    this(x, y, false);
  }
  public Graph getParent() {
    return parent;
  }
  boolean getFreePath(Worker worker) {
    return getPathTo(world.room.node[x][y], world.room.node[worker.x][worker.y])!=null;
  }
}
class GraphList extends ArrayList <Graph> {
  public Graph getMinF() {
    float [] s=new float [this.size()];
    for (int i=0; i<this.size(); i++) 
      s[i]=this.get(i).f;
    for (Graph part : this) {
      if (part.f==min(s)) 
        return part;
    }
    return null;
  }
  public Graph getNearestGraph(int tx, int ty) {
    float [] dist=new float [this.size()];
    for (int i=0; i<this.size(); i++) 
      dist[i]=dist(this.get(i).x, this.get(i).y, tx, ty);
    for (Graph part : this) {  
      float tdist = dist(part.x, part.y, tx, ty);
      if (tdist==min(dist)) 
        return part;
    }
    return null;
  }
  public boolean isSolid() {
    for (Graph part : this) {
      if (part.solid)
        return true;
    }
    return false;
  }
  public Graph getGraphFreePath(int x, int y) { //возвращает первый граф из списка до которого успешно проложен путь
    for (Graph part : this) {
      if (getPathTo(world.room.node[x][y], world.room.node[part.x][part.y])!=null) 
        return part;
    }
    return null;
  }
}
float getG (Graph start, Graph end) {
  if (start.x==end.x || start.y==end.y) 
    return world.size_grid;
  else 
  return world.size_grid+1;//0.1;
}
float getHeuristic(Graph start, Graph target) {
  return dist(start.x*world.size_grid+world.size_grid/2, start.y*world.size_grid+world.size_grid/2, 
    target.x*world.size_grid+world.size_grid/2, target.y*world.size_grid+world.size_grid/2);
}
void updateF(Graph current, Graph neighbor, Graph target) {
  neighbor.parent=current;
  neighbor.g=current.g+getG(current, neighbor);
  neighbor.h=getHeuristic(neighbor, target);
  neighbor.f=neighbor.g+neighbor.h;
}
boolean getDiagonal (int startX, int startY, int endX, int endY) {
  if (startX==endX || startY==endY) 
    return false;
  else 
  return true;
}
boolean isNeighbor(int x1, int y1, int x2, int y2) {
  int [] neighbor = getArrayDirection(x1, y1, x2, y2);
  for (int i=0; i<neighbor.length; i++) {
    int tempX=constrain(x1+matrixShearch[neighbor[i]][0], 0, world.room.sizeX-1);
    int tempY=constrain(y1+matrixShearch[neighbor[i]][1], 0, world.room.sizeY-1);
    if (x2==tempX && y2==tempY)
      return true;
  }
  return false;
}
int [] getArrayDirection(int x1, int y1, int x2, int y2) {
  if (getDiagonal(x1, y1, x2, y2)) {
    if (x1>x2 && y1>y2)    //влево и вверх
      return   new int [] {72, 61, 71, 50, 70, 49, 59, 48};
    else if (x1<x2 && y1>y2)   //вправо и вверх
      return   new int [] {50, 49, 61, 72, 48, 59, 71, 70};
    else if (x1>x2 && y1<y2)   //влево и вниз
      return   new int [] {48, 59, 49, 50, 70, 61, 71, 72};
    else    //вправо и вниз
    return   new int [] {70, 59, 71, 48, 72, 49, 61, 50};
  } else {
    if (x1>x2 && y1==y2) 
      return   new int [] {71, 72, 70, 61, 59, 50, 48, 49};
    else if (x1<x2 && y1==y2) 
      return new int [] {49, 50, 48, 61, 59, 70, 72, 71};
    else if (x1==x2 && y1>y2) 
      return   new int [] {61, 50, 72, 49, 71, 48, 70, 59};
    else 
    return   new int [] {59, 48, 70, 49, 71, 50, 72, 61};
  }
}
boolean getApplyDiagonalMove (int x, int y, int curX, int curY) {   //функция разрешающая, запрещающая диагональное перемещение луча света
  if (getDiagonal(curX, curY, x, y)) {
    int resX1, resY1, resX2, resY2;
    resX1=resX2=curX;
    resY1=resY2=curY;
    if (curX<x && curY<y) {
      resX1=curX+1;
      resY2=curY+1;
    } else
      if (curX>x && curY>y) {
        resX1=curX-1;
        resY2=curY-1;
      } else
        if  (curX>x && curY<y) { 
          resX1=curX-1;
          resY2=curY+1;
        } else 
        if (curX<x && curY>y) {
          resX1=curX+1;
          resY2=curY-1;
        }
    if (world.room.node[resX1][resY1].solid || world.room.node[resX2][resY2].solid) 
      return false;
    else 
    return true;
  } else 
  return true;
}
GraphList getNeighboring(Graph objectThis, Graph target) {
  GraphList tempList = new GraphList();
  int [] neighbor;
  if (target!=null)
    neighbor = getArrayDirection(objectThis.x, objectThis.y, target.x, target.y);
  else 
  neighbor=new int [] {59, 48, 70, 49, 71, 50, 72, 61};
  for (int i=0; i<neighbor.length; i++) {
    int tempX=constrain(objectThis.x+matrixShearch[neighbor[i]][0], 0, world.room.sizeX-1);
    int tempY=constrain(objectThis.y+matrixShearch[neighbor[i]][1], 0, world.room.sizeY-1);
    if (!world.room.node[tempX][tempY].solid && getApplyDiagonalMove(tempX, tempY, objectThis.x, objectThis.y))
      tempList.add(world.room.node[tempX][tempY]);
  }
  return tempList;
}
GraphList getPathTo(Graph start, Graph target) {
  GraphList open = new GraphList ();
  GraphList close = new GraphList ();
  Graph current;
  start.g=0;
  start.h=getHeuristic(start, target);
  start.f=start.g+start.h;
  start.parent=null;
  open.add(start);
  while (!open.isEmpty()) {
    current = open.getMinF();
    if (close.size()>5000) 
      break;
    if (current.x==target.x && current.y==target.y) 
      return getReconstructPath(target);
    open.remove(current);
    close.add(current);
    for (Graph part : getNeighboring(current, target)) {
      if (!close.contains(part)) {
        if (open.contains(part)) {
          if (part.g>current.g) 
            updateF(current, part, target);
        } else {
          updateF(current, part, target);
          open.add(part);
        }
      }
    }
  }
  return null;
}
GraphList getReconstructPath(Graph start) {
  GraphList map = new GraphList ();
  Graph current=start;
  while (current.getParent()!=null) {
    map.add(current);
    current=current.getParent();
  }
  return map;
}
