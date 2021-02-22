SimpleButton buttonCreate, buttonCreate1, buttonCreate10, buttonCreateBack1, buttonCreateBack10, buttonCreateManual, buttonCancelProduct, 
  buttonOpenOrder, buttonCloseOrder, buttonCancelOrder, buttonPause, buttonStart, buttonRemoveObject, buttonRotateObject, buttonRemoveItem, buttonRemoveAllItem, 
  buttonRecrutAdd, buttonRecrutRemove, buttonProfSet, buttonRenameObject, buttonRenameCompany, 
  buttonProfRename, buttonProfAdd, buttonProfRemove, buttonSave, buttonLoad;
RadioButton menuMain, menuTasker, menuContainer, menuBench, menuOrders, menuReciept, menuDevelop, menuCompany, menuWorker, buttonsSpeed;
SimpleRadioButton buttonInfo, buttonManager, buttonMaintenance, buttonTask, buttonCargo; 
Listbox mainList, secondList;
ControlP5 interfaces;
Textarea console, objectInfo, listInfo;

CheckList tasks;
PImage info, task, maintenance, action, cargo, spr_production, spr_buildings, spr_orders, 
  spr_order_new, spr_order_in_work, spr_order_complete, spr_order_closed, spr_company, spr_workers, spr_professions, 
  spr_play, spr_pause, spr_settings;

void setupInterface() {
  info = loadImage("data/sprites/hud/hud_info.png");
  task = loadImage("data/sprites/hud/hud_task.png");
  maintenance = loadImage("data/sprites/hud/hud_maintenance.png");
  action = loadImage("data/sprites/hud/hud_action.png");
  cargo = loadImage("data/sprites/hud/hud_cargo.png");
  spr_production = loadImage("data/sprites/hud/hud_production.png");
  spr_buildings = loadImage("data/sprites/hud/hud_buildings.png");
  spr_orders = loadImage("data/sprites/hud/hud_orders.png");
  spr_order_new = loadImage("data/sprites/hud/hud_order_new.png");
  spr_order_in_work = loadImage("data/sprites/hud/hud_order_in_work.png");
  spr_order_closed = loadImage("data/sprites/hud/hud_order_closed.png");
  spr_order_complete = loadImage("data/sprites/hud/hud_order_complete.png");
  spr_company = loadImage("data/sprites/hud/hud_company.png");
  spr_workers = loadImage("data/sprites/hud/hud_workers.png");
  spr_professions = loadImage("data/sprites/hud/hud_professions.png");
  spr_play = loadImage("data/sprites/hud/hud_play.png");
  spr_pause = loadImage("data/sprites/hud/hud_pause.png");
  spr_settings = loadImage("data/sprites/hud/hud_settings.png");
  //специальный функционал для переключения скроллинг списка
  Runnable resetScroll = new Runnable() {
    public void run() {
      mainList.resetScroll();
    }
  };
  mainList=new Listbox(512, 96, 287, 192);
  secondList=new Listbox(512, 326, 287, 128, false);

  //кнопки повторяются етодом clone()
  buttonInfo = new SimpleRadioButton("getInfo", info);
  buttonManager=new SimpleRadioButton("getManager", action);
  buttonTask=new SimpleRadioButton("getTasks", task);
  buttonMaintenance=new SimpleRadioButton("getMaintenance", maintenance);
  buttonCargo=new SimpleRadioButton("getCargo", cargo);

  buttonsSpeed = new RadioButton (345, 1, 96, 32, RadioButton.HORIZONTAL);  //главное меню
  buttonsSpeed.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("x1", "speed1"), 
    new SimpleRadioButton("x2", "speed2"), 
    new SimpleRadioButton("x3", "speed3"), 
    new SimpleRadioButton("x4", "speed4")});

  menuMain = new RadioButton (513, 1, 192, 32, RadioButton.HORIZONTAL);  //главное меню
  menuMain.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("showObjects", spr_production), 
    new SimpleRadioButton("showOrders", spr_orders), 
    new SimpleRadioButton("showItems", cargo), 
    new SimpleRadioButton("showBuildings", spr_buildings), 
    new SimpleRadioButton("showMenuCompany", spr_company), 
    new SimpleRadioButton("showSettings", spr_settings)});
  menuContainer=new RadioButton (513, 32, 96, 32, RadioButton.HORIZONTAL);
  menuContainer.addButtons(new SimpleRadioButton [] {buttonCargo.clone(), buttonInfo.clone(), buttonManager.clone()});
  menuWorker=new RadioButton (513, 32, 64, 32, RadioButton.HORIZONTAL);
  menuWorker.addButtons(new SimpleRadioButton [] {buttonInfo.clone(), buttonCargo.clone()});
  menuTasker=new RadioButton (513, 32, 128, 32, RadioButton.HORIZONTAL);
  menuTasker.addButtons(new SimpleRadioButton [] {buttonTask.clone(), buttonInfo.clone(), buttonManager.clone(), buttonMaintenance.clone()});

  menuBench=new RadioButton (513, 32, 160, 32, RadioButton.HORIZONTAL);
  menuBench.addButtons(new SimpleRadioButton [] {buttonTask.clone(), buttonInfo.clone(), buttonManager.clone(), buttonMaintenance.clone(), buttonCargo.clone()});

  menuOrders = new RadioButton (513, 32, 128, 32, RadioButton.HORIZONTAL);
  menuOrders.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("showAllOrders", spr_order_new, resetScroll), 
    new SimpleRadioButton("showOpenOrders", spr_order_in_work, resetScroll), 
    new SimpleRadioButton("showCloseOrders", spr_order_complete, resetScroll), 
    new SimpleRadioButton("showFailOrders", spr_order_closed, resetScroll)});

  menuReciept = new RadioButton (512, 290, 287, 32, RadioButton.HORIZONTAL);
  menuReciept.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("компоненты", "showComponents"), 
    new SimpleRadioButton("ресурсы", "showResources")});

  menuDevelop= new RadioButton (512, 290, 287, 32, RadioButton.HORIZONTAL);
  menuDevelop.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("компоненты", "showComponents"), 
    new SimpleRadioButton("применяемость", "showEntry")});

  menuCompany=new RadioButton (611, 32, 96, 32, RadioButton.HORIZONTAL);
  menuCompany.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("getInfo", info), 
    new SimpleRadioButton("getWorkers", spr_workers), 
    new SimpleRadioButton("getProfessions", spr_professions)});

  //чек-бокс для определения функций дронов
  tasks= new CheckList(530, 290, 200, 350);
  tasks.add(new CheckBox [] { new CheckBox(d.label.get("job_carry"), 530, 310, 10, 10, Job.CARRY), 
    new CheckBox(d.label.get("job_supply"), 530, 330, 10, 10, Job.SUPPLY), 
    new CheckBox(d.label.get("job_develop"), 530, 350, 10, 10, Job.DEVELOP), 
    new CheckBox(d.label.get("job_create"), 530, 370, 10, 10, Job.CREATE), 
    new CheckBox(d.label.get("job_assembly"), 530, 390, 10, 10, Job.ASSEMBLY), 
    new CheckBox(d.label.get("job_repair"), 530, 410, 10, 10, Job.REPAIR)
    });

  //создание кнопок 
  buttonCreate = new SimpleButton(565, 563, 192, 32, d.label.get("button_create"), new Runnable() {
    public void run() {
      Object object =world.room.currentObject; 
      Database.DataObject product = d.getItem(mainList.select.id);
      if (object instanceof Terminal) { 
        boolean purchase=false, useItem=false, develop=false, start=false; 
        Terminal terminal = (Terminal) object; 
        if (terminal.job==null) {
          if (terminal instanceof DevelopBench)
          develop=true;
          else if (terminal instanceof Workbench) 
          useItem = true;
          else
            purchase=true;
          if (useItem || develop)   
          start=true;
          else if (purchase) {
            float sum_money = product.getCostForPool()*terminal.count_operation;
            if (sum_money<=company.money) {
              terminal.refund=sum_money;
              company.money-=sum_money;
              printConsole("[РАСХОД] покупка "+d.getName("items", product.id)+": "+getDecimalFormat(sum_money)+" $");
              product.pool-=terminal.count_operation;       
              start=true;
            } else
              dialog.showInfoDialog("не хватает средств");
          }
          if (start) {
            terminal.product=product.id;
            terminal.progress=0;
            if (terminal instanceof Workbench)
            printConsole("новое задание для "+terminal.name+" на изготовление "+d.getName("items", product.id)+" ("+terminal.count_operation+")");
            else if (terminal instanceof DevelopBench)
            printConsole("новое задание для "+terminal.name+" на разработку "+d.getName("items", product.id));
            else
              printConsole("новое задание для "+terminal.name+" на доставку "+d.getName("items", product.id)+" ("+terminal.count_operation+")");
            mainList.select=null;
          }
        }
      }
    }
  }
  );
  buttonPause = new SimpleButton(313, 0, 32, 32, spr_pause, new Runnable() {
    public void run() {
      world.pause=true;
    }
  }
  );
  buttonStart = new SimpleButton(313, 0, 32, 32, spr_play, new Runnable() {
    public void run() {
      world.pause=false;
    }
  }
  );
  buttonSave = new SimpleButton(528, 94, 160, 32, "сохранить", new Runnable() {
    public void run() {
      save("save");
    }
  }
  );
  buttonLoad = new SimpleButton(528, 128, 160, 32, "загрузить", new Runnable() {
    public void run() {
      load();
    }
  }
  );
  buttonRemoveObject= new SimpleButton(528, 94, 160, 32, "уничтожить", new Runnable() {
    public void run() {
      WorkObject object = (WorkObject)world.room.currentObject;
      world.room.removeObject(object);
    }
  }
  );
  buttonRotateObject= new SimpleButton(528, 128, 160, 32, "повернуть", new Runnable() {
    public void run() {
      WorkObject object = (WorkObject)world.room.currentObject;
      object.setNextDirection();
    }
  }
  );
  buttonRenameCompany= new SimpleButton(528, 520, 160, 32, "переименовать", new Runnable() {
    public void run() {
      String name = dialog.showTextInputDialog("введите название:");
      if (name!=null) {
        if (name.length()>0) {
          printConsole("комнания "+company.name+" переименована в: "+name);
          company.name=name;
        }
      }
    }
  }
  );
  buttonRenameObject= new SimpleButton(528, 162, 160, 32, "переименовать", new Runnable() {
    public void run() {
      WorkObject object = world.room.currentObject; 
      if (object!=null) {
        String name = dialog.showTextInputDialog("введите имя:");
        if (name!=null) {
          if (name.length()>0) {
            printConsole("объект "+object.name+" переименован в: "+name);
            object.name=name;
          }
        }
      }
    }
  }
  );
  buttonRemoveItem= new SimpleButton(584, 512, 160, 32, "продать", new Runnable() {
    public void run() {
      dialog.showConfirmDialog(
        "вы действительно хотите распродать предметы за половину цены?", 
        "распродажа", 
        new Runnable() {
        public void run() {
          int item = world.room.getItemsIsContainers().getComponent(mainList.select.id);
          world.room.removeItems(item, 1);
          Database.DataObject itemObj = d.getItem(item);
          float cost;
          ComponentList reciept = d.getReciept(itemObj.id);
          if (reciept!=null)
          cost = getDecimalFormat((itemObj.cost*reciept.getCostTotal())/2);
          else
            cost=itemObj.cost/2;
          company.money+=cost;
          printConsole("[ПОСТУПЛЕНИЕ] распродажа имущества: "+cost+" $");
        }
      }
      , 
        null
        );
    }
  }
  );
  buttonRemoveAllItem= new SimpleButton(584, 546, 192, 32, "продать все", new Runnable() {
    public void run() {
      dialog.showConfirmDialog(
        "вы действительно хотите распродать предметы за половину цены?", 
        "распродажа", 
        new Runnable() {
        public void run() {
          ComponentList itemList = world.room.getItemsIsContainers();
          int item = itemList.getComponent(mainList.select.id);
          Database.DataObject itemObj = d.getItem(item);
          float cost;
          ComponentList reciept = d.getReciept(itemObj.id);
          if (reciept!=null)
          cost = getDecimalFormat((d.getItem(item).cost*reciept.getCostTotal()*itemList.calculationItem(item))/2);
          else
            cost=(itemObj.cost*itemList.calculationItem(item))/2;
          world.room.removeItems(item, itemList.calculationItem(item));
          company.money+=cost;
          printConsole("[ПОСТУПЛЕНИЕ] распродажа имущества: "+cost+" $");
        }
      }
      , 
        null
        );
    }
  }
  );
  buttonCreateManual = new SimpleButton(651, 532, 32, 32, "+n", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        String input = dialog.showTextInputDialog("введите количество:");
        if (input!=null) {
          if (int(input)>0) {
            terminal.count_operation=int(input);
            if (!(object instanceof Workbench) && !(object instanceof DevelopBench)) {
              Database.DataObject product = d.getItem(mainList.select.id);
              terminal.count_operation=constrain(constrain(terminal.count_operation, 1, terminal.max_count_operation), 1, product.pool);
            }
          }
        }
      }
    }
  }
  );
  buttonCreate1 = new SimpleButton(583, 532, 32, 32, "+1", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.count_operation++;
        if (!(object instanceof Workbench) && !(object instanceof DevelopBench)) {
          Database.DataObject product = d.getItem(mainList.select.id);
          terminal.count_operation=constrain(constrain(terminal.count_operation, 1, terminal.max_count_operation), 1, product.pool);
        }
      }
    }
  }
  );
  buttonCreate10 = new SimpleButton(617, 532, 32, 32, "+10", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.count_operation+=10;
        if (!(object instanceof Workbench) && !(object instanceof DevelopBench)) {
          Database.DataObject product = d.getItem(mainList.select.id);
          terminal.count_operation=constrain(constrain(terminal.count_operation, 1, terminal.max_count_operation), 1, product.pool);
        }
      }
    }
  }
  );
  buttonCreateBack1 = new SimpleButton(549, 532, 32, 32, "-1", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.count_operation--;
      }
    }
  }
  );
  buttonCreateBack10 = new SimpleButton(515, 532, 32, 32, "-10", new Runnable() {
    public void run() {
      Object object =world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        terminal.count_operation-=10;
      }
    }
  }
  );
  buttonCancelProduct= new SimpleButton(565, 563, 192, 32, d.label.get("button_cancel"), new Runnable() {
    public void run() {
      Object object = world.room.currentObject;
      if (object instanceof Terminal) {
        Terminal terminal = (Terminal)object;
        if (terminal.progress<terminal.getMaxProgress()) {
          if (object instanceof Workbench) {
            if (terminal.progress>0) {
              dialog.showConfirmDialog(
                "вы действительно хотите отменить задание, возможны потери ресурсов?", 
                "отмена задания", 
                new Runnable() {
                public void run() {
                  ((Terminal)world.room.currentObject).cancelProduct();
                }
              }
              , 
                null
                );
            } else
              terminal.cancelProduct();
          } else {
            if (!(object instanceof DevelopBench)) 
            terminal.refund();
            terminal.cancelProduct();
          }
        }
      }
    }
  }
  );
  buttonOpenOrder = new SimpleButton(570, 552, 193, 32, "открыть заказ", new Runnable() {
    public void run() {
      if (company.opened.size()<company.ordersOpenLimited) {
        Order order = world.orders.getOrder(mainList.select.id);
        company.opened.add(order);
        world.orders.remove(order);
        order.deadLine=null;
        order.deadLine=getDateForDays(order.day);
        order.newOrder=getDateForDays(1);//constrain(int(order.day/2), 1, order.day));
        printConsole("заказ № "+order.id+" "+d.getName("items", order.product)+" ("+order.count+") открыт");
      } else
        dialog.showInfoDialog("превышен лимит открытых заказов");
    }
  }
  );
  buttonCloseOrder = new SimpleButton(570, 528, 193, 32, "закрыть заказ", new Runnable() {
    public void run() {
      Order order = company.opened.getOrder(mainList.select.id);
      if (order!=null) {
        if (order.isComplete()) {
          world.room.removeItems(order.product, order.count);
          company.opened.remove(order);
          company.closed.add(order);
          company.money+=order.cost;
          company.exp+=order.exp;
          printConsole("заказ № "+order.id+" "+d.getName("items", order.product)+" ("+order.count+") закрыт");
          printConsole("[ПОСТУПЛЕНИЕ] выполнение заказа: "+order.cost+" $");
        } else
          dialog.showInfoDialog("не выполнены условия");
      }
    }
  }
  );
  buttonCancelOrder = new SimpleButton(570, 562, 193, 32, "отменить заказ", new Runnable() {
    public void run() {
      dialog.showConfirmDialog(
        "при отмене заказа будет начислен штраф, продолжить?", 
        "отмена заказа", 
        new Runnable() {
        public void run() {
          Order order = company.opened.getOrder(mainList.select.id);
          if (order!=null) {
            company.opened.remove(order);
            company.failed.add(order);
            float forfeit = getDecimalFormat(order.cost*0.1);
            company.money-=forfeit;
            order.refund = forfeit;
            company.update();
            printConsole("заказ № "+order.id+" "+d.getName("items", order.product)+" ("+order.count+") отменен, штраф: "+forfeit+" $");
            dialog.showInfoDialog("заказ отменен, штраф: "+forfeit+" $");
            printConsole("[РАСХОД] штраф: "+forfeit+" $");
          }
        }
      }
      , null);
    }
  }
  );
  buttonProfAdd = new SimpleButton(528, 520, 160, 32, "новая должность", new Runnable() {
    public void run() {
      String name = dialog.showTextInputDialog("новая должность:");
      if (name!=null) {
        if (name.length()>0) {
          company.professions.addNewProfession(name);
          printConsole("изменено штатное расписание, введена должность: "+name);
        }
      }
    }
  }
  );
  buttonProfRemove = new SimpleButton(528, 554, 160, 32, "упразднить", new Runnable() {
    public void run() {
      Profession prof = company.professions.getProfessionIsName(mainList.select.label);
      company.professions.remove(prof);
      for (Worker worker : company.workers) {
        if (worker.profession==prof)
        worker.profession=null;
      }
      printConsole("должность "+mainList.select.label+" упразднена, следующие рабочие не назначены: "+company.workers.getWorkers(null).getNames());
    }
  }
  );
  buttonProfRename= new SimpleButton(528, 475, 160, 32, "изменить", new Runnable() {
    public void run() {
      Profession profession = company.professions.getProfessionIsName(mainList.select.label);
      if (profession!=null) {
        String name = dialog.showTextInputDialog("изменить должность:");
        if (name!=null) {
          if (name.length()>0) 
          profession.name=name;
        }
      }
    }
  }
  );
  buttonRecrutAdd = new SimpleButton(528, 520, 160, 32, "нанять рабочего", new Runnable() {
    public void run() {
      String name = "Виктор Пелевин";
      company.addWorker(name, 6);
      printConsole("принят новый рабочий: "+name);
    }
  }
  );
  buttonRecrutRemove = new SimpleButton(528, 554, 160, 32, "уволить", new Runnable() {
    public void run() {
      String name = company.workers.getWorkerIsId(mainList.select.id).name;
      company.workers.removeWorkerId(mainList.select.id);
      printConsole("рабочий "+name+" был уволен");
    }
  }
  );
  buttonProfSet= new SimpleButton(528, 475, 160, 32, "назначить", new Runnable() {
    public void run() {
      Worker worker = company.workers.getWorkerIsId(mainList.select.id);
      if (worker!=null) {
        String select = dialog.showSelectionDialog("выберите должность", "назначить", company.professions.getList());
        if (select != null) {
          if (!select.equals("не выбрано")) {
            Profession profession =  company.professions.getProfessionIsName(select); 
            if (profession!=null) {
              worker.profession=profession;
              printConsole("рабочий "+worker.name+" назначен на должность "+profession.name);
            }
          } else
            worker.profession = null;
        }
      }
    }
  }
  );
  console = interfaces.addTextarea("console")
    .setPosition(1, _sizeY-world.room.sizeY*32)
    .setSize(_sizeX-290, 184)
    .setFont(createFont("arial", 14))
    .setLineHeight(18)
    .setColor(white)
    .setBorderColor(white)
    .setColorBackground(black)
    .setScrollForeground(white)
    .setScrollBackground(black);
  objectInfo = interfaces.addTextarea("info")
    .setPosition(515, 78)
    .setSize(283, 312)
    .setFont(fontMain)
    .setLineHeight(22)
    .setColor(white)
    .setBorderColor(white)
    .setColorBackground(black)
    .setScrollForeground(white)
    .setScrollBackground(black);
  listInfo = interfaces.addTextarea("listInfo")
    .setPosition(515, 291)
    .setSize(283, 160)
    .setFont(fontMain)
    .setLineHeight(16)
    .setColor(white)
    .setBorderColor(white)
    .setColorBackground(black)
    .setScrollForeground(white)
    .setScrollBackground(black);
}
void printConsole(String text) {
  if (text.length()>0) {
    if (console.getText().length()!=0)
      console.append("\n");
    console.append("["+world.date.getDate()+"] "+text).scroll(1);
  }
}
void infoControl(Textarea textArea, String text) {
  textArea.setText(text);
  textArea.setVisible(true);
}
void maintenanceControl(Terminal terminal) {
  showScaleText(terminal.getCharacters(), 518, 90);
}
void cargoControl(ComponentList items) {
  showScaleText("содержимое:", 524, 90);
  mainList.loadItems(items);
  mainList.setActive(true);
  if (mainList.select!=null) {
    showScaleText("применяемость:", 524, 312);
    secondList.setActive(true);
    secondList.loadDevelopComponents(d.getComponentsIsComponent(mainList.select.id));
    showScaleText("вес: "+d.getItem(mainList.select.id).weight, 518, 476);
  }
}
void taskControl(Terminal terminal) {
  boolean ready = true;
  showScaleText(terminal.getDescriptTask(), 518, 476);
  if (terminal instanceof DevelopBench) 
    buttonCreate.text="разработать";
  else {
    if (terminal instanceof Workbench) {
      buttonCreate.text="изготовить";
    } else {
      if (d.getItem(mainList.select.id).pool<=0) //если пул не пустой, то ресурс можно купить
        ready = false;
      buttonCreate.text="закупить";
    }
    if (ready) {
      buttonCreateManual.setActive(true);
      buttonCreate1.setActive(true);
      buttonCreate10.setActive(true);
      if (terminal.count_operation>0) {
        if (terminal.count_operation>1)
          buttonCreateBack1.setActive(true);
        if (terminal.count_operation>10)
          buttonCreateBack10.setActive(true);
      }
    }
  }
  if (ready)
    buttonCreate.setActive(true);
}
void taskMainControl(Terminal terminal) {
  if (terminal.product==-1) {        //если продукт не назначен
    if (terminal instanceof DevelopBench) {
      terminal.products.clear();
      terminal.products=world.room.getListAllowProducts();
    }
    if (terminal.products!=null) {      //если список продуктов существует
      if (terminal.products.size()>0) { //если список продуктов не пустой
        //заголовок списка
        if (terminal instanceof DevelopBench) 
          showScaleText("чертежи:", 524, 90);
        else if (terminal instanceof Workbench) 
          showScaleText("изделия:", 524, 90);  
        else
          showScaleText("ресурсы:", 524, 90);
        if (terminal instanceof DevelopBench) 
          mainList.loadComponents(terminal.products.getListNotWork()); //загружает откорректированный список чертежей
        else
          mainList.loadComponents(terminal.products); //загружает продукты в список
        mainList.setActive(true);  //отображает список
        if (mainList.select!=null) {  //если 
          if (terminal.count_operation==0)
            terminal.count_operation=1;
          taskControl(terminal);
          ComponentList reciept = d.getReciept(mainList.select.id);
          if (reciept!=null) {
            if (terminal instanceof Workbench) {
              menuReciept.control();
              if (menuReciept.select.event.equals("showResources")) 
                secondList.loadReciept(reciept.getResources().getMult(terminal.count_operation));
              else if (menuReciept.select.event.equals("showComponents")) 
                secondList.loadReciept(reciept.getMult(terminal.count_operation));  
              secondList.setActive(true);
            } else {
              menuDevelop.control();
              if (menuDevelop.select.event.equals("showComponents")) 
                secondList.loadReciept(reciept);
              else if (menuDevelop.select.event.equals("showEntry")) 
                secondList.loadDevelopComponents(d.getComponentsIsComponent(mainList.select.id));
              secondList.setActive(true);
            }
          } else {
            showScaleText("применяемость:", 524, 312);
            secondList.setActive(true);
            secondList.loadDevelopComponents(d.getComponentsIsComponent(mainList.select.id));
          }
        }
      } else {
        if (terminal instanceof Workbench)
          infoControl(objectInfo, "выдача заданий недоступна, необходимо разрабатывать чертежи");
        else if (terminal instanceof DevelopBench)
          infoControl(objectInfo, "нет доступных чертежей для разработки");
      }
    }
  } else {
    if (terminal.label==null) {
      if (terminal instanceof Workbench) {
        // if (terminal.progress<int(terminal.getMaxProgress()*0.8))   //если работа еще не началась
        buttonCancelProduct.setActive(true);  
        //else
        //showScaleText("невозможно отменить", 556, 564);
        if (!(((Workbench)terminal).isAllowCreate()) && ((Workbench)terminal).progress==0) {
          showScaleText(terminal.getProductDescript(), 522, 80);
          mainList.setActive(true);
          mainList.loadTaskComponents((Workbench)terminal);
        } else 
        infoControl(objectInfo, terminal.getProductDescript() +"\n"+((Workbench)terminal).getDescriptProgress());
      } else {
        buttonCancelProduct.setActive(true);
        infoControl(objectInfo, terminal.getProductDescript());
      }
    } else
      infoControl(objectInfo, terminal.getProductDescript());
  }
}
void selectRadioButton(RadioButton buttons) {
  fill(blue);
  noStroke();
  rect(buttons.x*getScaleX(), buttons.y*getScaleY(), buttons.width*getScaleX(), buttons.height*getScaleY());
}
void selectButton(SimpleRadioButton button) {
  fill(blue);
  noStroke();
  rect(button.x*getScaleX(), button.y*getScaleY(), button.width*getScaleX(), button.height*getScaleY());
}
void updateInterface() {
  //текст консоли
  console.setPosition(new float [] {1, map(_sizeY-182, 0, _sizeY, 0, context.height)});
  console.setSize(int(context.width-290*getScaleX()), int(180*getScaleY()));
  stroke(white);
  noFill();
  rect(console.getPosition()[0]-1, console.getPosition()[1]-1, int(context.width-290*getScaleX())+2, int(181*getScaleY()));

  //текст информации об объекте
  float oy=map(78, 0, _sizeY, 0, context.height);
  float ox=map(515, 0, _sizeX, 0, context.width);
  objectInfo.setPosition(  new float [] {ox, oy});
  objectInfo.setSize(int(map(283, 0, _sizeX, 0, context.width)), int(map(312, 0, _sizeY, 0, context.height)));//int(283*getScaleX()), int(64*getScaleY()));
  objectInfo.setVisible(false);

  // //текст информации об объектах в списках
  float ly=map(291, 0, _sizeY, 0, context.height);
  float lx=map(515, 0, _sizeX, 0, context.width);
  listInfo.setPosition(new float [] {lx, ly});
  listInfo.setSize(int(283*getScaleX()), int(160*getScaleY()));
  listInfo.setVisible(false);

  buttonCreate.setActive(false);
  buttonCreateManual.setActive(false);
  buttonCreate1.setActive(false);
  buttonCreate10.setActive(false);
  buttonCreateBack1.setActive(false);
  buttonCreateBack10.setActive(false);
  buttonCancelProduct.setActive(false);
  buttonOpenOrder.setActive(false);
  buttonCloseOrder.setActive(false);
  buttonCancelOrder.setActive(false);
  buttonRemoveObject.setActive(false);
  buttonRemoveItem.setActive(false);
  buttonRemoveAllItem.setActive(false);
  buttonRecrutAdd.setActive(false);
  buttonRecrutRemove.setActive(false);
  buttonProfAdd.setActive(false);
  buttonProfRemove.setActive(false);
  buttonProfRename.setActive(false);
  buttonProfSet.setActive(false);
  buttonRecrutRemove.setActive(false);
  buttonRotateObject.setActive(false);
  buttonRenameObject.setActive(false);
  buttonRenameCompany.setActive(false);
  buttonSave.setActive(false);
  buttonLoad.setActive(false);
  menuWorker.setActive(false);
  menuContainer.setActive(false);
  menuBench.setActive(false);
  menuOrders.setActive(false);
  menuTasker.setActive(false);
  menuReciept.setActive(false);
  menuDevelop.setActive(false);
  menuCompany.setActive(false);
  mainList.setActive(false);
  secondList.setActive(false);
  tasks.setActive(false);
  selectButton(menuMain.select);
  menuMain.control();
  if (world.pause) {
    buttonStart.setActive(true);
    buttonPause.setActive(false);
  } else {
    buttonStart.setActive(false);
    buttonPause.setActive(true);
  }
  fill(white);
  if (menuMain.select.event.equals("showObjects")) {
    world.room.setActiveLabels(true);
    world.setActive(true);
    WorkObject object = (WorkObject) world.room.currentObject;
    String event = "";
    if (object!=null) {
      if (object instanceof Terminal) {
        if (object instanceof Workbench && !(object instanceof DevelopBench)) {
          selectRadioButton(menuBench);
          Workbench workbench = (Workbench) object;
          menuBench.control();
          event= menuBench.select.event;
          if (event.equals("getInfo")) 
            infoControl(objectInfo, workbench.getDescript());
          if (event.equals("getMaintenance")) 
            maintenanceControl(workbench);
          else if (event.equals("getCargo"))
            cargoControl(workbench.components);
          else if (event.equals("getTasks"))  //если выбрана вкладка задачи
            taskMainControl(workbench);
        } else {
          selectRadioButton(menuTasker);
          Terminal terminal = (Terminal)object;
          menuTasker.control();
          event= menuTasker.select.event;

          if (event.equals("getInfo")) 
            infoControl(objectInfo, terminal.getDescript());
          if (event.equals("getMaintenance")) 
            maintenanceControl(terminal);
          else if (event.equals("getTasks"))  //если выбрана вкладка задачи
            taskMainControl(terminal);
        }
      } else if (object instanceof Container) {
        selectRadioButton(menuContainer);
        menuContainer.control();
        event= menuContainer.select.event;
        Container container = (Container) object;
        if (event.equals("getInfo")) 
          infoControl(objectInfo, container.getDescript());
        else if (event.equals("getCargo"))
          cargoControl(container.items);
      } else if (object instanceof Worker) {
        selectRadioButton(menuWorker);
        menuWorker.control();
        event= menuWorker.select.event;
        Worker worker = (Worker) object;
        if (event.equals("getInfo"))
          infoControl(objectInfo, worker.getDescript());
        else if (event.equals("getCargo"))
          cargoControl(worker.items);
      } else if (object instanceof ItemMap) {
        ItemMap itemMap = (ItemMap) object;
        infoControl(objectInfo, d.getName("items", itemMap.item)+" ("+itemMap.count+")\n"+
          "вес: "+d.getItem(itemMap.item).weight+itemMap.getIsJobLock());
      }
      if (event.equals("getManager")) {
        if (object.job==null) {
          buttonRemoveObject.setActive(true);
          if (!(object instanceof ItemMap))
            buttonRenameObject.setActive(true);
          if (object instanceof Terminal)
            buttonRotateObject.setActive(true);
        } else 
        infoControl(objectInfo, "объект заблокирован "+object.job.worker.name+", действия невозможны");
      }
    } else 
    infoControl(objectInfo, "выберите объект");
  } else if (menuMain.select.event.equals("showMenuCompany")) {
    world.setActive(true);
    world.room.setActiveLabels(false);
    selectRadioButton(menuCompany);
    menuCompany.control();
    if (menuCompany.select.event.equals("getInfo")) {
      infoControl(objectInfo, company.getInfo());
      buttonRenameCompany.setActive(true);
    } else if (menuCompany.select.event.equals("getWorkers")) {
      mainList.loadWorkers(company.workers); 
      mainList.setActive(true); 
      buttonRecrutAdd.setActive(true);
      showScaleText("рабочие:", 524, 90);
      if (mainList.select!=null) {
        infoControl(listInfo, company.workers.getWorkerIsId(mainList.select.id).getDescriptList());
        buttonRecrutRemove.setActive(true);
        buttonProfSet.setActive(true);
      }
    } else if (menuCompany.select.event.equals("getProfessions")) {
      mainList.loadProfessions(company.professions); 
      mainList.setActive(true); 
      buttonProfAdd.setActive(true);
      showScaleText("должности:", 524, 90);
      if (mainList.select!=null) {
        tasks.setActive(true);
        Profession profession = company.professions.getProfessionIsName(mainList.select.label);
        tasks.synhronizedProfession(profession);
        buttonProfRename.setActive(true);
        if (company.professions.indexOf(profession)>0)
          buttonProfRemove.setActive(true);
      }
    }
  } else if (menuMain.select.event.equals("showOrders")) {
    selectRadioButton(menuOrders);
    menuOrders.control();
    world.setActive(true);
    world.room.setActiveLabels(false);
    mainList.setActive(true);
    if (menuOrders.select.event.equals("showAllOrders")) {
      mainList.loadNewOrders(world.orders);
      showScaleText("заказы (новые):", 524, 90);
    } else  if (menuOrders.select.event.equals("showOpenOrders")) {
      mainList.loadNewOrders(company.opened);
      showScaleText("заказы (открытые):", 524, 90);
    } else  if (menuOrders.select.event.equals("showCloseOrders")) {
      mainList.loadOrders(company.closed);
      showScaleText("заказы (закрытые):", 524, 90);
    } else  if (menuOrders.select.event.equals("showFailOrders")) {
      mainList.loadOrders(company.failed);
      showScaleText("заказы (отмененные):", 524, 90);
    }
    if (mainList.select!=null) {
      if (menuOrders.select.event.equals("showAllOrders")) {
        infoControl(listInfo, world.orders.getOrder(mainList.select.id).getDescriptNew());
        buttonOpenOrder.setActive(true);
      } else if (menuOrders.select.event.equals("showOpenOrders")) {
        infoControl(listInfo, company.opened.getOrder(mainList.select.id).getDescriptOpen());
        buttonCloseOrder.setActive(true);
        buttonCancelOrder.setActive(true);
      } else if (menuOrders.select.event.equals("showCloseOrders")) 
        infoControl(listInfo, company.closed.getOrder(mainList.select.id).getDescriptClose());
      else if (menuOrders.select.event.equals("showFailOrders")) 
        infoControl(listInfo, company.failed.getOrder(mainList.select.id).getDescriptFail());
    }
  } else if (menuMain.select.event.equals("showItems")) {
    world.room.setActiveLabels(true);
    world.setActive(true);
    mainList.loadItems(world.room.getItemsIsContainers());
    if (mainList.select!=null) {
      buttonRemoveItem.setActive(true);
      buttonRemoveAllItem.setActive(true);
      showScaleText("применяемость:", 524, 312);
      secondList.setActive(true);
      secondList.loadDevelopComponents(d.getComponentsIsComponent(mainList.select.id));
      showScaleText("вес: "+d.getItem(mainList.select.id).weight, 518, 476);
    } 
    mainList.setActive(true);
    showScaleText("склад:", 524, 90);
  } else if (menuMain.select.event.equals("showBuildings")) {
    world.room.setActiveLabels(false);
    world.room.currentObject=null;
    world.setActive(true);  
    mainList.setActive(true);
    mainList.loadObjects(d.objects);
    if (mainList.select!=null) {
      infoControl(listInfo, "цена: "+d.objects.getId(mainList.select.id).cost+" $");
      if (world.hover)
        world.newObj = d.objects.getId(mainList.select.id);
    }
    showScaleText("постройки: "+world.room.getAllObjects().getNoItemMap().size()+"/"+company.buildingLimited, 524, 90);
  } else if (menuMain.select.event.equals("showSettings")) {
    buttonSave.setActive(true);
    buttonLoad.setActive(true);
  }
  buttonsSpeed.control();  //контроль скорости
  world.speed=int(map(buttonsSpeed.select()+1, 1, 4, world.maxSpeed, world.minSpeed)); 

  showScaleText("$: "+str(company.money), 16, 25);
  showScaleText(world.date.getDate(), 112, 25);
}
class ScaleActiveObject extends ActiveElement {
  boolean lock;

  ScaleActiveObject(float xx, float yy, float ww, float hh) {
    super(xx, yy, ww, hh);
    lock=false;
  }
  ScaleActiveObject(float xx, float yy, float ww, float hh, boolean lock) {
    this(xx, yy, ww, hh);
    this.lock=lock;
  }
  boolean isInside(float xx, float yy) {
    if (lock)
      return false;
    if ((xx>x*getScaleX() && xx<x*getScaleX()+width*getScaleX()) &&
      (yy>y*getScaleY() && yy<y*getScaleY()+height*getScaleY()))
      return true;
    else 
    return false;
  }
}

class RadioButton extends ScaleActiveObject {
  int orientation;
  SimpleRadioButton select;
  ArrayList <SimpleRadioButton> buttons= new ArrayList <SimpleRadioButton>();
  final static int HORIZONTAL = 0, VERTICAL = 1;

  RadioButton  (int x, int y, int widthObj, int  heightObj, int orientation) {
    super(x, y, widthObj, heightObj);
    this.orientation = constrain(orientation, 0, 1);
    select=null;
  }
  public void addButton(SimpleRadioButton button) {
    buttons.add(button);
    update();
  }
  public void control () {
    setActive(true); 
    for (SimpleRadioButton button : buttons) {
      if (button.pressed) 
        setSelect(button);
    }
  }
  void resetSelect() {
    setSelect(buttons.get(0));
  }
  void setActive(boolean active) {
    super.setActive(active);
    for (SimpleRadioButton button : buttons)
      button.setActive(active);
  }
  void addButtons(SimpleRadioButton [] buttons) {
    this.buttons.clear();
    for (SimpleRadioButton button : buttons)
      this.buttons.add(button);
    update();
  }
  private void update() {
    for (int i=0; i<buttons.size(); i++) {
      SimpleRadioButton button = buttons.get(i);
      if (orientation==HORIZONTAL) {
        int widthButton = (int)width/buttons.size();
        button.width=widthButton;
        button.height=height;
        button.y=y;
        button.x=x+i*(widthButton+1);
      } else if (orientation==VERTICAL) {
        int heightButton =  (int)height/buttons.size();
        button.height=heightButton;
        button.width=width;
        button.x=x;
        button.y=y+i*(heightButton+1);
      }
    }
    setSelect(buttons.get(0));
  }
  int select() {
    return buttons.indexOf(select);
  }
  void setSelect(SimpleRadioButton button) {
    select=button;
    for (SimpleRadioButton part : buttons) {
      if (part.equals(select)) 
        part.on=true;
      else 
      part.on=false;
    }
  }
}


class SimpleButton extends ScaleActiveObject {
  boolean on;
  String text;
  Runnable script;
  PImage sprite;

  SimpleButton (float x, float y, float w, float h, String text, Runnable script) {
    super(x, y, w, h);
    this.text=text;
    this.script=script;
    sprite=null;
  }

  SimpleButton (float x, float y, float w, float h, PImage sprite, Runnable script) {
    this(x, y, w, h, "", script);
    this.sprite=sprite;
  }
  void mousePressed () {
    if (script!=null)
      script.run();
  }
  void draw () {
    pushMatrix();
    scale(getScaleX(), getScaleY());
    pushStyle();  
    if (sprite!=null) {
      if (hover && mousePressed) 
        image(sprite, x-2, y-2, width+4, height+4);
      else 
      image(sprite, x, y);
      if (on) {
        noFill();
        stroke( white );
        rect(x+2, y+2, width-4, height-4);
      }
    } else {
      if (on) fill(white);
      else fill(black);
      noStroke();
      rect(x, y, width, height);
      if (hover)
        if (mousePressed) 
          stroke(color(90));
        else 
        stroke(white);
      else noStroke();
      rect(x+2, y+2, width-4, height-4);
      strokeWeight(1);
      textAlign(CENTER, CENTER);
      if ( on ) fill(black);
      else fill(white);
      text(text, x+this.width/2, y+this.height/2-textDescent());
    }
    popStyle();
    popMatrix();
  }
}

class SimpleRadioButton extends SimpleButton {
  String event;

  SimpleRadioButton (String text, String event, PImage sprite, Runnable script) {
    this(text, event);
    this.script=script;
    this.sprite=sprite;
  }
  SimpleRadioButton (String event, PImage sprite) {
    this("", event);
    this.sprite=sprite;
  }
  SimpleRadioButton (String event, PImage sprite, Runnable script) {
    this("", event);
    this.script=script;
    this.sprite=sprite;
  }
  SimpleRadioButton (String text, String event) {
    super(-600, -600, 1, 1, text, null);  
    this.event=event;
  }
  void mouseClicked () {
    if (mouseButton==LEFT)
      on=!on;
  }
  public SimpleRadioButton clone() {
    return new SimpleRadioButton (text, event, sprite, script);
  }
}
class Listbox extends ScaleActiveObject {
  ArrayList <ListItem> items;
  float itemHeight = 32;
  int listStartAt = 0;
  int hoverItem = -1;
  ListItem select=null;
  float valueY = 0;
  boolean hasSlider = false;

  Listbox (float x, float y, float w, float h) {
    super(x, y, w, h);
    valueY =y;
    items = new ArrayList <ListItem> ();
  }

  Listbox (float x, float y, float w, float h, boolean lock) {
    this(x, y, w, h);
    this.lock=lock;
  }
  class ListItem {
    int id;
    String label;
    PImage sprite;
    color _color;
    ListItem (int id, String label, PImage sprite, color _color) {
      this(id, label, _color);
      this.sprite=sprite;
    }
    ListItem (int id, String label, color _color) {
      this.id=id;
      this.label=label;
      this._color=_color;
      sprite=null;
    }
  }

  private int getPrevSelect() {
    int prev_select = 0;
    if (items!=null) {
      if (select!=null)
        prev_select=constrain(items.indexOf(select), 0, items.size()-1);
      else 
      prev_select=-1;
      items.clear();
    }
    return prev_select;
  }

  private void setPrevSelect(int prev_select) {
    if (prev_select==-1 || items.isEmpty()) 
      select=null;
    else
      select= items.get(constrain(prev_select, 0, items.size()-1));
    update();
  }
  void loadHelpMessages(StringDict list) {
    int prev_select = getPrevSelect();  
    for (String part : list.keyArray()) {
      addItem(part, list.index(part), null, white);
    }
    setPrevSelect(prev_select);
  }
  void loadOrders(OrderList list) {
    int prev_select = getPrevSelect();
    for (Order part : list) 
      addItem("№"+part.id+": "+d.getName("items", part.product)+" ("+part.count+")", part.id, d.getItem(part.product).sprite, white);
    setPrevSelect(prev_select);
  }
  void loadNewOrders(OrderList list) {
    int prev_select = getPrevSelect();
    for (Order part : list) {
      color _color = white;
      if (!world.room.getItemsIsDeveloped().hasValue(part.product))
        _color=red;
      else if (world.room.getItemsIsContainers().calculationItem(part.product)>=part.count)
        _color=green;
      addItem("№"+part.id+": "+d.getName("items", part.product)+" ("+part.count+")", part.id, d.getItem(part.product).sprite, _color);
    }
    setPrevSelect(prev_select);
  }
  void loadObjects(Database.DatabaseObjectList objects) {
    int prev_select = getPrevSelect();
    for (Database.DataObject part : objects)
      addItem(objects, d.getName("objects", part.id), part.id, white);
    setPrevSelect(prev_select);
  }
  void loadTaskComponents(Workbench bench) {   //загружает список компонентов с учетом уже имеющихся 
    //в наличие на складе/в объекте(белый/зеленый), не в наличии (красный)
    int prev_select = getPrevSelect();
    ComponentList components = d.getReciept(bench.product);
    for (int part : components.sortItem()) {
      color isItem=white;
      int needItem = components.calculationItem(part)*bench.count_operation;
      if (bench.components.calculationItem(part)<needItem) {
        if (world.room.getItemsAll().calculationItem(part)>0) 
          isItem=gray;
        else 
        isItem=red;
      } else
        isItem=green;
      addItem(d.items, d.getName("items", part)+" ("+bench.components.calculationItem(part)+"/"+
        components.getMult(bench.count_operation).calculationItem(part)+")", part, isItem);
    }
    setPrevSelect(prev_select);
  }
  void loadDevelopComponents(ComponentList list) {   //загружает список с учетом уже разработанных чертежей (уникальный)
    int prev_select = getPrevSelect();
    ComponentList projects = world.room.getItemsIsDeveloped();  //все объекты доступные для создания 
    for (int p : list) {
      color isItem=white;
      if (!projects.hasValue(p)) 
        isItem=red;
      addItem(d.items, d.getName("items", p), p, isItem);
    }
    setPrevSelect(prev_select);
  }
  void loadItems(ComponentList list) {
    int prev_select = getPrevSelect();
    for (int part : list.sortItem()) 
      addItem(d.items, d.getName("items", part)+" ("+list.calculationItem(part)+")", part, white);
    setPrevSelect(prev_select);
  }
  void loadComponents(ComponentList list) {
    int prev_select = getPrevSelect();
    for (int part : list.sortItem()) 
      addItem(d.items, d.getName("items", part), part, white);
    setPrevSelect(prev_select);
  }
  void loadWorkers(ArrayList <Worker> workers) {
    int prev_select = getPrevSelect();
    for (Worker worker : workers) 
      addItem(worker.name, worker.id, worker.sprite, white);
    setPrevSelect(prev_select);
  }
  void loadProfessions(ArrayList <Profession> professions) {
    int prev_select = getPrevSelect();
    for (Profession profession : professions) 
      addItem(profession.name, 0, null, white);
    setPrevSelect(prev_select);
  }
  void loadReciept(ComponentList list) {
    int prev_select = getPrevSelect();
    for (int part : list.sortItem()) 
      addItem(d.items, "("+list.calculationItem(part)+") "+d.getName("items", part), part, white);
    setPrevSelect(prev_select);
  }

  public void addItem (Database.DatabaseObjectList data, String item, int id, color _color) {
    items.add(new ListItem (id, item, data.getId(id).sprite, _color));
    hasSlider = items.size() * itemHeight*getScaleY() > this.height*getScaleY();
  }
  public void addItem (String item, int id, PImage sprite, color _color) {
    items.add(new ListItem (id, item, sprite, _color));
    hasSlider = items.size() * itemHeight*getScaleY() > this.height*getScaleY();
  }
  public void addItem (String item, int id, color _color) {
    items.add(new ListItem (id, item, null, _color));
    hasSlider = items.size() * itemHeight*getScaleY() > this.height*getScaleY();
  }
  public void mouseMoved ( float mx, float my ) {
    if ((hasSlider && mx > (x+this.width-20)*getScaleX())) return;
    if (hover)
      hoverItem = listStartAt + int((my-y*getScaleY()) / (itemHeight*getScaleY()));
  }
  public void mouseExited ( float mx, float my ) {
    hoverItem = -1;
  }
  void mouseDragged (float mx, float my) {
    if (!hasSlider) return;
    if (mx < x+this.width-20) return;
    valueY = my-itemHeight;
    valueY = constrain(valueY, y, y+this.height-itemHeight);
    update();
  }
  void mouseScrolled (float step) {
    if (items.size()*itemHeight>height && hover) {
      float heightScroll = items.size()*itemHeight-this.height; 
      float hS = heightScroll/itemHeight;
      valueY += constrain(step, -1, 1)*((items.size()*itemHeight)/hS);
      valueY = constrain(valueY, y, y+this.height-itemHeight);
      update();
    }
  }
  void resetScroll() {
    valueY=y;
    update();
  }
  void update () {
    float totalHeight = items.size() * itemHeight;
    float listOffset = (map(valueY, y, y+this.height-itemHeight, 0, totalHeight-this.height));
    listStartAt = int( listOffset / itemHeight );
    listStartAt = constrain(listStartAt, 0, listStartAt);
  }
  public void mousePressed ( float mx, float my ) { 
    if (this.items==null) return;
    if (this.items.isEmpty()) return;
    if (hasSlider && mx > (x+this.width-20)*getScaleX()) return;
    int pressed=listStartAt + int((my-y*getScaleY())/(itemHeight*getScaleY()));
    if (pressed<this.items.size())
      select = items.get(constrain(pressed, 0, items.size()-1));
    else 
    select=null;
  }
  boolean hoverNoSlider() {
    if (mouseX<(x+width-20)*getScaleX())
      return true;
    else 
    return false;
  }
  void draw () { 
    pushMatrix();
    scale(getScaleX(), getScaleY());
    stroke(white);
    noFill();
    rect(x, y, this.width, this.height);
    if (items != null) {
      for (int i = 0; i<int(this.height/itemHeight) && i <items.size(); i++) {
        color _color= items.get(constrain(i+listStartAt, 0, items.size()-1))._color;
        stroke(white);
        if (i+listStartAt==items.indexOf(select))
          fill(white);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider() && !lock) ? white : black);
        rect(x, y + (i*itemHeight), this.width, itemHeight);
        noStroke();
        if (i+listStartAt==items.indexOf(select))
          fill(black);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider() && !lock) ? black : _color);
        PImage image = items.get(constrain(i+listStartAt, 0, items.size()-1)).sprite;
        int h=5;
        if (image!=null) {
          image(image, x+1, y+(i+1)*itemHeight-32);
          h+=32;
        }
        text(items.get(constrain(i+listStartAt, 0, items.size()-1)).label, x+h, y+(i+1)*itemHeight-5 );
      }
    }
    if (hasSlider) {
      stroke(white);
      fill(black);
      rect(x+this.width-20, y, 20, this.height);
      fill(white);
      rect(x+this.width-20, valueY, 20, 20);
    }
    popMatrix();
  }
}
class Text extends ActiveElement {
  String text;
  color text_color, background_color;
  float yT, grid_size;
  StringList texts = new StringList ();

  Text (float x, float y, int widthObj, int  heightObj, color text_color, color background_color) {
    super(x, y, widthObj, heightObj);
    this.text=null;
    this.background_color=background_color;
    this.text_color=text_color;
    yT=0;
    grid_size=30;
  }
  public void clear() {
    text=null;
    texts.clear();
  }
  public void loadText(String text) {
    this.text=text;
    texts.clear();
    text+=" ";
    String [] str= split(text, " ");
    if (str.length==1) 
      texts.append(text);
    int current_str=0;
    for (int i=0; i<str.length-1; i++) {
      String part = str[i], current, newStr;
      if (texts.size()>0 && current_str<texts.size()) {
        current = texts.get(current_str);
        newStr = current+" "+part;
      } else {
        current = "";
        newStr = part;
      }
      if (textWidth(newStr)<width) 
        texts.set(current_str, newStr);
      else {
        texts.append(part);
        current_str++;
      }
    }
  }
  protected float getTextHeight() {
    return getTextNumStr()*grid_size*getScaleY();
  }
  protected int getTextNumStr() {
    return texts.size();
  }
  public void draw() {
    pushMatrix();
    scale(getScaleX(), getScaleY());
    pushStyle(); 
    fill(text_color);
    textLeading(grid_size);
    if (text!=null) {
      if (getTextHeight()>height) 
        rect(x+width-3, y-map(yT, 0, getTextHeight(), 0, height), 3, map(height/getTextNumStr(), 0, getTextHeight(), 0, height)*getTextNumStr());
      int yt=int(y+grid_size+yT );
      for (int i=0; i<texts.size(); i++) {
        String current = texts.get(i);
        if (current!=null) {       
          text(current, (x+8), yt);
          yt+=grid_size;
        }
      }
    }
    popStyle();
    popMatrix();
  }
  void mouseScrolled(float step) {
    if (step==-1) {
      if (getTextHeight()>=height*getScaleY())
        yT=constrain(yT+=10, -getTextHeight(), 0);
    } else if (step==1) {
      if (getTextHeight()>=height*getScaleY())
        yT=int(constrain(yT-=10, -(getTextHeight()-height*getScaleY())-10, 0));
    }
  }
}
class CheckList extends ScaleActiveObject {
  ArrayList <CheckBox> list; 
  CheckList (float xx, float yy, float ww, float hh ) {
    super(xx, yy, ww, hh);
    list = new ArrayList <CheckBox>();
  }
  public void add(CheckBox [] list) {
    for (CheckBox part : list)
      this.list.add(part);
  }
  public void setActive(boolean active) {
    for (CheckBox part : list) 
      part.setActive(active);
  }
  void mouseReleased () {
    if (menuCompany.select.event.equals("getProfessions")) {
      if (mainList.select!=null) {
        Profession profession = company.professions.getProfessionIsName(mainList.select.label);
        if (profession!=null) {
          profession.jobs.clear();
          for (CheckBox part : list) {
            if (part.pressed)
              part.mouseReleased();
            if (part.checked) 
              profession.jobs.append(part.id);
          }
          synhronizedProfession(profession);
        }
      }
    }
  }
  public void synhronizedProfession(Profession profession) {
    for (CheckBox part : list) {
      part.checked=false;
      part.value=-1;
      for (int i : profession.jobs) {   
        if (part.id==i) {
          part.checked=true;
          break;
        }
      }
    }
  }
}
class CheckBox extends ScaleActiveObject {
  int id, value;
  boolean checked;
  float x, y, width, height;
  String label;
  float padx = 7;

  CheckBox (String l, float xx, float yy, float ww, float hh, int id) {
    super(xx, yy, ww, hh);
    label = l;
    x = xx; 
    y = yy; 
    width = ww; 
    height = hh;
    this.id=id;
    value= -1;
    Interactive.add( this );
  }
  void mouseReleased () {
    checked = !checked;
  }
  void draw () {
    noStroke();
    fill( 200 );
    rect(x*getScaleX(), y*getScaleY(), width, height);
    if ( checked ) {
      fill(black);
      rect(x*getScaleX()+2, y*getScaleY()+2, width-4, height-4);
    } 
    if (hover)
      fill(gray);
    else
      fill(white);
    textAlign( LEFT );
    if (value!=-1)
      text(label+" ("+value+")", (x+width+padx)*getScaleX(), y*getScaleY()+height);
    else
      text(label, (x+width+padx)*getScaleX(), y*getScaleY()+height);
  }
  boolean isInside ( float mx, float my ) {
    return Interactive.insideRect(x*getScaleX(), y*getScaleY(), (width+padx+textWidth(label))*getScaleX(), height*getScaleY(), mx, my);
  }
}
void showScaleText(String text, float x, float y) {
  pushStyle();
  textLeading(16);
  textSize(16);
  pushMatrix(); 
  fill(white);
  translate(x*getScaleX(), y*getScaleY());
  scale(getScaleX(), getScaleY());
  text(text, 0, 0);
  popMatrix();
  popStyle();
}

float getScaleX() {
  return (context.width/float(_sizeX));
}
float getScaleY() {
  return (context.height/float(_sizeY));
}
