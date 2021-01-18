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
    if (count>1 && !newProduct)
      drawCount(count);
    popStyle();
    popMatrix();
  }

  protected void drawCount(int count) {
    pushMatrix();
    // translate(-world.size_grid/2, -world.size_grid/2);
    pushStyle();
    strokeWeight(1);
    rectMode(CORNERS);
    fill(black);
    stroke(white);
    rect(world.size_grid-textWidth(str(count))-3, world.size_grid-world.size_grid/2+3, world.size_grid-1, world.size_grid-1);
    textSize(10);
    textAlign(RIGHT, BOTTOM);
    fill(white);
    text(count, world.size_grid-3, world.size_grid+1);
    popStyle();
    popMatrix();
  }
  public void mousePressed() {
    if (newProduct) {
      data.objects.getId(data.items.getId(item.id).work_object).products.append(item.id);
      ComponentList components =  data.objects.getId(WorkObject.DEVELOPBENCH).products;
      components.removeValue(item.id);
      components.addNewProducts(data.items.getId(item.id).reciept);
      Terminal terminal = world.room.getObjectAtLabel(this);
      terminal.products.removeValue(item.id);
      terminal.products.addNewProducts(data.items.getId(item.id).reciept);
      terminal.removeLabel();

    } else {
      Terminal terminal = world.room.getObjectAtLabel(this);
      int [] place = world.room.getAbsCoordObject(terminal);
      count = world.room.addItem(place[0], place[1], item.id, count);
      if (count<=0)
        terminal.removeLabel();
    }
  }
}
