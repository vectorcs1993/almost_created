import processing.net.*;   
import de.bezier.guido.*;
import uibooster.*;
import controlP5.*;

int _sizeX=800;
int _sizeY=600;
World world;
UiBooster booster;
Client client;
boolean connect;

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
  size(_sizeX, _sizeY, JAVA2D);
  noSmooth();

  booster = new UiBooster();
}


void setup() {
  //fontMain = createFont("data/font/progress_pixel_bolt.ttf", 18);
  surface.setIcon(loadImage("data/sprites/icon.png"));
  setupDatabase();
  surface.setResizable(true);
  surface.setTitle(data.label.get("title"));
  floor = loadImage("data/sprites/floor.png");
  worker= loadImage("data/sprites/worker/worker.png");
  no_data = loadImage("data/sprites/no_data.png");

  Interactive.make(this);
  interfaces = new ControlP5(this);


  //textFont(fontMain);
  textLeading(24);
  world = new World(192, 32, 320, 320);
  setupInterface();
  client = new Client(this, "192.168.0.10", 10002);
  connect = client.ip()!=null;
  if (!connect)
    input("Не удалось подключиться к серверу!");

}

void draw() {
  background(0);
  updateInterface();
  world.update();
  if (connect && !client.active()) {
    input("Потеряно соединение с сервером");
    connect=false;
  }
 
}


void keyPressed() {
  world.company.addWorker();
}


void clientEvent(Client client) {

  if (connect) {

    if (client.active()) {
      JSONObject message = parseJSONObject(client.readString());
      int idMessage = message.getInt("id_message");
      String time = hour()+":"+minute()+":"+second();
      String messageConsole="";




      if (idMessage==3)
        messageConsole = message.getString("name")+" : потеряно соединение";
      if (idMessage==2)
        messageConsole = message.getString("name")+": "+message.getString("text");
      console.append("\n"+time+" "+messageConsole).scroll(1);
    }
  }
}
