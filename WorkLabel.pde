class WorkLabel extends ScaleActiveObject {
  Item item;
  int count;
  color colorBack;
  boolean newProduct;



  WorkLabel(float x, float y, float ww, float hh, Item item, int count, boolean newProduct, color colorBack) {
    super(x, y, ww, hh);
    this.item=item;
    this.count=count;
    this.colorBack=colorBack;
    this.newProduct=newProduct;
  }
  void draw () {
    pushMatrix();
    pushStyle();
    translate(x*getScaleX(), y*getScaleY());
    scale(getScaleX(), getScaleY());
    fill(colorBack);
    stroke(white);
    rect(0, 0, width, height);
    image(data.items.getId(item.id).sprite, 0, 0);
    if (count>1)
      drawCount(count);
    popStyle();
    popMatrix();
  }

  protected void drawCount(int count) {
    pushStyle();
    textSize(10);
    textAlign(RIGHT, BOTTOM);
    fill(white);
    text(count, world.size_grid-3, world.size_grid+2);
    popStyle();
  }
  public void mousePressed() {
    if (newProduct) {
  
     
          data.objects.getId(WorkObject.WORKBENCH).products.append(item.id);

        ComponentList components =  data.objects.getId(WorkObject.DEVELOPBENCH).products;
        components.removeValue(item.id);
        Terminal terminal = world.room.getObjectAtLabel(this);
        terminal.products.removeValue(item.id);
        terminal.removeLabel();
      
    } else {
      for (WorkObject object : world.room.getAllObjects().getContainers()) {
        Container container  = (Container) object;
        if (container.isFreeCapacity(count)) {
          container.items.addItemCount(item, count);
          Terminal terminal = world.room.getObjectAtLabel(this);
          terminal.removeLabel();
          break;
        } else {
          if (container.getFreeCapacity()>0) {
            int freeCapacity = container.getFreeCapacity();
            container.items.addItemCount(item, freeCapacity);
            count-=freeCapacity;
          }
        }
      }
    }
  }
}
