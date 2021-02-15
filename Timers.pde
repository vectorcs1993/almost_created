ArrayList <Timer> timers = new ArrayList <Timer>();

class Timer {
  boolean flag;
  long timing;
  float set;
  Timer() {  
    flag=false;
    timers.add(this);
  }
  void set(float set) {
    timing=millis();
    flag=true;
    this.set=set;
  }
  void tick() {
    float speed = int(map(world.speed, world.minSpeed, world.maxSpeed, world.maxSpeed/world.stepSpeed, 0)+1);
    if (millis() - timing > set/speed)
      flag=false;
    else 
    flag=true;
  }
  boolean check() {
    return flag;
  }
  long getTime() {
    return millis() - timing;
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
  Date (int day, int month, int year, int hour, int minute) {
    this(day, month, year);
    this.minute=minute;
    this.hour=hour;
  }
  void tick() {
    if (!timer.check()) {
      update();
      timer.set(world.speed);
    }
  }
  void setDateFromString(String dateStr) {
    day = int(dateStr.substring(6, 8));
    month = int(dateStr.substring(9, 11));
    year = int(dateStr.substring(12, 16));
    hour = int(dateStr.substring(0, 2));
    minute = int(dateStr.substring(3, 5));
  }
  void newDay() {
    data.items.putPool(); //восполнение мировых запасов ресурсов
    company.setExpenses();
    printConsole("!!!новый рабочий день!!!");
    save("autosave");
  }
  void update() {
    minute++;
    if (minute>59) {
      minute=0;
      hour++;
      if (hour>23) {
        hour=0;
        day++;
        newDay();
        if (day>30) {
          day=1;
          month++;
          if (month>11) 
            year++;
        }
      }
    }
  }
  boolean isPassed(Date date) {
    if (date.month>=month && date.day>=day && date.hour>=hour && date.minute>=minute) 
      return false;
    else
      return true;
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
  String getTime() {
    return  isNotZero(hour)+":"+isNotZero(minute);
  }
  int getDays(int scope) { //принимает трудоемкость с учетом количества
    return int(scope*10/1440);
  }
}

Date getDateFromString(String dateStr) {
  if (dateStr!=null) {
    int day = int(dateStr.substring(6, 8));
    int month = int(dateStr.substring(9, 11));
    int year = int(dateStr.substring(12, 16));
    int hour = int(dateStr.substring(0, 2));
    int minute = int(dateStr.substring(3, 5));
    return new Date(day, month, year, hour, minute);
  } else 
  return null;
}
Date getDateForDays(int days) {
  int month =world.date.month;
  int year=world.date.year;
  int day =world.date.day;
  day+=days;
  while (day>30) {
    day-=30;
    month++;
    if (month>12) {
      month=1;
      year++;
    }
  }
  return new Date (day, month, year);
}
int getDaysForDates(Date date1, Date date2) {
  if (date1.day<date2.day)
    return date2.day-date1.day;
  else {
    return (date2.day+30)-date1.day;
  }
}
