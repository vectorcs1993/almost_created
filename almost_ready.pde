import de.bezier.guido.*;




int _sizeX=800;
int _sizeY=600;
World world;

PImage floor, terminal, container, no_data;
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



void settings() {


  size(_sizeX, _sizeY, P2D);
  
  smooth(2);
  PJOGL.setIcon("data/sprites/icon.png");
 
}


void setup() {
  PFont font = createFont("data/font/progress_pixel_bolt.ttf", 18);


  
  setupDatabase();
  surface.setResizable(true);
  surface.setTitle(data.label.get("title"));
  
  floor = loadImage("data/sprites/floor.png");
  terminal = loadImage("data/sprites/terminal.png");
  container = loadImage("data/sprites/container.png");
  no_data = loadImage("data/sprites/no_data.png");

  Interactive.make(this);
  textFont(font);
  textLeading(24);
  world = new World(192, 32, 320, 320);

  setupInterface();
   booster = new UiBooster();
}






void draw() {
  background(0);
  updateInterface();
  world.update();
    
}
