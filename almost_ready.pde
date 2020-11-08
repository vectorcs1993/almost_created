import de.bezier.guido.*;

int _sizeX=800;
int _sizeY=600;
World world;

PImage floor, no_data;
color blue = color(0, 0, 255);                                                                               //задание цветовых констант
color red = color(255, 0, 0);
color green = color(0, 255, 0);
color white = color(255, 255, 255);
color black = color(0, 0, 0);
color brick = color(150, 75, 0);
color gray = color(185, 176, 176);
color yellow = color(100, 255, 0);
color negr= color(150, 75, 0);
color euro= color(213, 172, 129);

PFont fontConsole, fontMain;

void settings() {
  size(_sizeX, _sizeY, P2D);
  smooth(2);
  PJOGL.setIcon("data/sprites/icon.png");
}


void setup() {
  fontMain = createFont("data/font/progress_pixel_bolt.ttf", 18);
  fontConsole = loadFont("data/font/ArialNarrow-14.vlw");
  setupDatabase();
  surface.setResizable(true);
  surface.setTitle(data.label.get("title"));
  floor = loadImage("data/sprites/floor.png");
  no_data = loadImage("data/sprites/no_data.png");

  Interactive.make(this);
  textFont(fontMain);
  textLeading(24);
  world = new World(192, 32, 320, 320);
  setupInterface();
}

void draw() {
  background(0);
  updateInterface();
  world.update();
}


void keyPressed() {
 world.company.exp+=1000; 
  
}
