ArrayList <Timer> timers = new ArrayList <Timer>();

class Timer {
  boolean flag;
  long timing;
  float set;

  Timer() {  
    flag=false;
    timers.add(this);
  }

  void set(float tempSet) {
    timing=millis();
    flag=true;
    set=tempSet;
  }

  long getProcess() {
    return int(map(millis() - timing, 0, set, 0, world.size_grid)); //не работает
  }

  void tick() {
    if (millis() - timing > set) {                                                               // таймер прерывания на движение игрока 
      flag=false;
    }
  }

  boolean check() {
    return flag;
  }
}

class Date {
  int minute, hour, day, month, year;
  Timer timer;
  Date (int day, int month, int year) {
    minute=hour=22;
    this.day=day;
    this.month=month;
    this.year=year;
    timer = new Timer();
  }
  protected void tick() {
    if (!timer.check()) {
      update();
      timer.set(getTick());
    }
  }
  long getTick() {
    return 100;
  }
  void update() {
    minute++;
    if (minute>59) {
      minute=0;
      hour++;
      if (hour>23) {
        hour=0;
        day++;
        if (day>30) {
          day=1;
          month++;
          if (month>11) 
            year++;
        }
      }
    }
  }
String isNotZero(int num) {
    if (num<10)
      return "0"+str(num);
    else
      return str(num);
}
 String getDateNotTime() {
    return  isNotZero(day)+"."+isNotZero(month)+"."+year;
  }
  String getDate() {
    return  isNotZero(hour)+":"+isNotZero(minute)+" "+isNotZero(day)+"."+isNotZero(month)+"."+year;
  }
}
