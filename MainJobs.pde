abstract class Job {   //главный класс работы
  String name;
  Worker worker;
  boolean exit;
  final static int CARRY=0, DEVELOP=1, REPAIR=2, CREATE=5, ASSEMBLY=6, SUPPLY=7, MOVE=3;
  
  Job(Worker worker) {
    this.worker=worker;
    name="работа";
    exit=false;
  }
  abstract boolean isComplete();
  abstract int getType();
  abstract void update();
  abstract String getStatus();
  int getProcess() {
    return 0;
  }  
  int getProcessMax() {
    return 0;
  }
  void cancel() {
    exit=true;
  }
  void close() {
    worker=null;
  }
}
abstract class JobProgress extends Job { //промежуточный класс работы со шкалой прогресса
  int process, processMax;
  WorkObject object;
  JobProgress(Worker worker, WorkObject object, int start, int finish) {
    super(worker);
    this.object=object;
    process = start;
    processMax= finish;
  }
  String getStatus() {
    return getName()+" "+getProcess()+" %";
  }
  public boolean isComplete() {
    return process>=processMax;
  }
  int getProcess() {
    return (int)map(process, 0, processMax, 0, 100);
  }
  void update() {
    if (process<processMax) {
      process++;
      this.worker.setDirection(object.getX(), object.getY());
      if (process>=processMax) 
        onAction();
    }
  }
  abstract String getName();
  abstract void onAction();
  void close() {
    super.close();
    process=0;
  }
}




String getSkillName(int skill) {
  String string = "неизвестно";
  if (skill==Job.CARRY)
    string=d.label.get("job_carry");
  else if (skill==Job.DEVELOP)
    string=d.label.get("job_develop");
  else if (skill==Job.SUPPLY)
    string=d.label.get("job_supply");
  else if (skill==Job.REPAIR)
    string=d.label.get("job_repair");
  else if (skill==Job.CREATE)
    string=d.label.get("job_create");
  else if (skill==Job.ASSEMBLY)
    string=d.label.get("job_assembly");

  return string;
}
