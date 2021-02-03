import de.bezier.guido.*;
import uibooster.*;
import controlP5.*;
import java.util.Map;

int _sizeX=800;
int _sizeY=600;
World world;
UiBooster dialog;

PImage floor, no_data, lock;
color blue = color(0, 0, 255);                                                                               //задание цветовых констант
color red = color(255, 0, 0);
color green = color(0, 255, 0);
color white = color(200);
color black = color(0, 0, 0);
color brick = color(150, 75, 0);
color gray = color(185, 176, 176);
color yellow = color(100, 255, 0);
color negr= color(150, 75, 0);
color euro= color(213, 172, 129);

PFont fontConsole, fontMain;

void settings() {
  size(_sizeX, _sizeY, JAVA2D);
  noSmooth();

  dialog = new UiBooster();
}


void setup() {
  surface.setIcon(loadImage("data/sprites/icon.png"));
  setupDatabase();
  surface.setResizable(true);
  surface.setTitle(data.label.get("title"));
  floor = loadImage("data/sprites/floor.png");
  spr_worker= loadImage("data/sprites/worker/worker.png");
  lock= loadImage("data/sprites/hud/hud_lock.png");
  no_data = loadImage("data/sprites/no_data.png");

  Interactive.make(this);
  interfaces = new ControlP5(this);

  textLeading(24);
  world = new World(1, 32, 512, 384);
  setupInterface();

}

void draw() {
  background(0);
  updateInterface();
  world.update();

}
void keyPressed() {
  world.room.addItem(world.getAbsCoordX(), world.getAbsCoordY(), 5, 1);
 
}
