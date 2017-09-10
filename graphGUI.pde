import processing.serial.*;

Serial arduino;
String portName = "/dev/ttyUSB0";
int baud = 9600;

String bookName = "data/Book3.csv";

String receivedString;

import controlP5.*;

ControlP5 cp5;

int maxSpeed = 10000;
int maxPWM = 300;

int windowHeight = 700;
int windowWidth = 1100;

int leftPanelWidth = 50;

int rightPanelWidth = 150;

int speedHeight = 400;
int speedWidth = windowWidth - leftPanelWidth - rightPanelWidth;
int speedStartX = leftPanelWidth;
int speedStartY = 20 + speedHeight;

int pwmHeight = 250;
int pwmWidth = speedWidth;
int pwmStartX = leftPanelWidth;
int pwmStartY = windowHeight;

int frameLength = 60;
int delayTime = 1000;

int framesCount = frameLength*1000/delayTime;

float[] speedValues;
float[] pwmValues;
float[] setpointValues;

float speedPtX;
float speedPtY;

float speedLastPtX;
float speedLastPtY;

float pwmPtX;
float pwmPtY;

float pwmLastPtX;
float pwmLastPtY;

float setpointPtX;
float setpointPtY;

float setpointLastPtX;
float setpointLastPtY;

//float received[] = {100, 105, 110, 115, 120, 123, 136, 150, 200, 255, 250, 250, 254, 255, 254};

CheckBox checkbox;
void setup(){
  //create window
  size(1100, 700);
  background(102);

  //load csv file
  Table table;
  table = loadTable(bookName, "header");
  TableRow newRow = table.addRow();  
  saveTable(table, bookName);
  
  //open serial port
  arduino = new Serial(this, portName, baud);
 
  //cp5 for form input
  PFont font = createFont("arial",20);
  
  cp5 = new ControlP5(this);
  
  checkbox = cp5.addCheckBox("checkBox")
                .setPosition(windowWidth - rightPanelWidth + 10, 10)
                .setColorForeground(color(20))
                .setColorActive(color(255))
                .setColorLabel(color(255))
                .setSize(10, 10)
                .setItemsPerRow(3)
                .setSpacingColumn(30)
                .setSpacingRow(20)
                .addItem("Edit", 0)
                ;
                
  cp5.addTextfield("Kp")
     .setPosition(windowWidth - rightPanelWidth + 10, 30)
     .setSize(rightPanelWidth - 15, 30)
     .setFont(font)
     .setColor(color(0, 0, 0))
     ;
     
  cp5.addTextfield("Kd")
     .setPosition(windowWidth - rightPanelWidth + 10, 100)
     .setSize(rightPanelWidth - 15, 30)
     .setFont(font)
     .setColor(color(0, 0, 0))
     ;
     
  cp5.addTextfield("Ki")
     .setPosition(windowWidth - rightPanelWidth + 10, 170)
     .setSize(rightPanelWidth - 15, 30)
     .setFont(font)
     .setColor(color(0, 0, 0))
     ;

  cp5.addTextfield("time")
     .setPosition(windowWidth - rightPanelWidth + 10, 170 + 70)
     .setSize(rightPanelWidth - 15, 30)
     .setFont(font)
     .setColor(color(0, 0, 0))
     ;
     
  cp5.addButton("sendK")
    .setPosition(windowWidth - rightPanelWidth + 10, 250 + 70)
    .setSize(rightPanelWidth - 15,40)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
     
  cp5.addTextfield("setpoint")
     .setPosition(windowWidth - rightPanelWidth + 10, 320 + 70)
     .setSize(rightPanelWidth - 15, 30)
     .setFont(font)
     .setFocus(true)
     .setColor(color(0, 0, 0))
     ;
 
  cp5.addButton("sendSetpoint")
    .setPosition(windowWidth - rightPanelWidth + 10, 390 + 70)
    .setSize(rightPanelWidth - 15,40)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
    ;
     
  cp5.addTextfield("PWM")
     .setPosition(windowWidth - rightPanelWidth + 10, 460 + 70)
     .setSize(rightPanelWidth - 15, 30)
     .setFont(font)
     .setColor(color(0, 0, 0))
     ;
  cp5.addButton("sendPWM")
    .setPosition(windowWidth - rightPanelWidth + 10, 530 + 70)
    .setSize(rightPanelWidth - 15,40)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
  
  //seperation line pwm and speed
  stroke(255, 255, 255);
  strokeWeight(3);
  line(0, speedStartY, speedStartX + speedWidth - 2, speedStartY);
  
  //text labels
  fill(255, 255, 0);
  text("Speed", leftPanelWidth + 10, speedStartY - speedHeight - 2);
  
  fill(0, 255, 0);
  text("Setpoint", leftPanelWidth + 50, speedStartY - speedHeight - 2);

  fill(0, 0, 255);
  text("PWM", leftPanelWidth + 10, pwmStartY - pwmHeight);
  
  //ruler
  fill(0, 0, 0);
  for(int i = 0; i < 10; i++){
    text(i*maxSpeed/10, 10, (speedStartY - (i*speedStartY/10) - 5));
  }

  for(int i = 0; i < 5; i++){
    text(i*maxPWM/5, 10, (pwmStartY - (i*(pwmHeight)/5))-5);
  }
  
  //ruler border
  stroke(0, 0, 0);
  strokeWeight(1);
  line(leftPanelWidth - 2, 0, leftPanelWidth - 2, windowHeight);

  //right panel border
  strokeWeight(2);
  line(windowWidth - rightPanelWidth, 0, windowWidth - rightPanelWidth, windowHeight);

  //initial values
  speedValues = new float[framesCount];
  pwmValues = new float[framesCount];
  setpointValues = new float[framesCount];
  for(int i = 0; i < framesCount; i++){
    speedValues[i] = 0;
    pwmValues[i] = 0;
    setpointValues[i] = 0;
  }
  //for(int i = 0; i < 15; i++){
  // drawPWMPoint(received[i]);
  // drawUpperGraph(received[i], 255);
  //}
}

void drawUpperGraph(float speedValue, float setpointValue){
  stroke(102);
  fill(102);
  rect(speedStartX, speedStartY - speedHeight + 2, speedWidth - 3, speedHeight - 5);

  strokeWeight(1);

  for(int i = 0; i < framesCount - 1; i++){
    speedValues[i] = speedValues[i+1];
    setpointValues[i] = setpointValues[i+1];
  }
  speedValues[framesCount - 1] = speedValue;
  setpointValues[framesCount - 1] = setpointValue;

  speedLastPtX = speedStartX;
  speedLastPtY = speedHeight - map(speedValues[0], 0, maxSpeed, 0, speedHeight);

  setpointLastPtX = speedStartX;
  setpointLastPtY = speedHeight - map(setpointValues[0], 0, maxSpeed, 0, speedHeight);

  for(int i = 0; i < framesCount; i++){
    speedPtX = speedStartX + i*(speedWidth/framesCount);
    speedPtY = speedStartY - map(speedValues[i], 0, maxSpeed, 0, speedHeight) - 5;
    
    setpointPtX = speedStartX + i*(speedWidth/framesCount);
    setpointPtY = speedStartY - map(setpointValues[i], 0, maxSpeed, 0, speedHeight) - 5;

    stroke(255, 255, 0);
    line(speedLastPtX, speedLastPtY, speedPtX, speedPtY);

    stroke(0, 255, 0);
    line(setpointLastPtX, setpointLastPtY, setpointPtX, setpointPtY);

    speedLastPtX = speedPtX;
    speedLastPtY = speedPtY;

    setpointLastPtX = setpointPtX;
    setpointLastPtY = setpointPtY;
  }

}

void drawPWMPoint(float pwmValue){
  stroke(102);
  fill(102);
  rect(pwmStartX, pwmStartY - pwmHeight + 2, pwmWidth - 3, speedHeight - 5);

  strokeWeight(1);

  for(int i = 0; i < framesCount - 1; i++){
    pwmValues[i] = pwmValues[i+1];
  }
  pwmValues[framesCount - 1] = pwmValue;

  pwmLastPtX = pwmStartX;
  pwmLastPtY = pwmHeight - map(pwmValues[0], 0, maxPWM, 0, pwmHeight);

  for(int i = 0; i < framesCount; i++){
    pwmPtX = pwmStartX + i*(pwmWidth/framesCount);
    pwmPtY = pwmStartY - map(pwmValues[i], 0, maxPWM, 0, pwmHeight) - 5;

    stroke(0, 0, 255);
    line(pwmLastPtX, pwmLastPtY, pwmPtX, pwmPtY);

    pwmLastPtX = pwmPtX;
    pwmLastPtY = pwmPtY;
  }
}

public void sendK() {
  println("a button event from sendK");
  String Kp = cp5.get(Textfield.class,"Kp").getText();
  String Kd = cp5.get(Textfield.class,"Kd").getText();
  String Ki = cp5.get(Textfield.class,"Ki").getText();
  String time = cp5.get(Textfield.class,"time").getText();
  //println("Kp: ", Kp, "Kd: ", Kd, "Ki: ", Ki);
  String sendK = "K:p"+Kp+"d"+Kd+"i"+Ki+"t"+time;
  arduino.write(sendK);
  println(sendK);
  checkbox.toggle(0);
  Table table;
  table = loadTable(bookName, "header");
  TableRow newRow = table.addRow(); 
  saveTable(table, bookName);
  
}

public void sendSetpoint() {
  println("a button event from sendSetpoint");
  String setpoint = cp5.get(Textfield.class,"setpoint").getText();
  String sendSetpoint = "S:"+setpoint;
  arduino.write(sendSetpoint);
  println(sendSetpoint);
  checkbox.toggle(0);
  Table table;
  table = loadTable(bookName, "header");
  TableRow newRow = table.addRow(); 
  saveTable(table, bookName);
}

public void sendPWM() {
  println("a button event from sendPWM");
  String pwm = cp5.get(Textfield.class,"PWM").getText();
  String sendPwm = "P:"+pwm;
  arduino.write(sendPwm);
  println(sendPwm);
  checkbox.toggle(0);
  Table table;
  table = loadTable(bookName, "header");
  TableRow newRow = table.addRow(); 
  saveTable(table, bookName);}


void draw(){
  if (arduino.available() > 0){
    Table table;
    table = loadTable(bookName, "header");
    TableRow newRow = table.addRow();  
    
    receivedString = arduino.readStringUntil('\n');
    if(receivedString != null){
      //speed setpoint pwm contraintPWM error lastError errorD errorI Kp Kd Ki
      //println(receivedString);
      float[] nums = float(split(receivedString, ' '));
      println("Setpoint: ", nums[1], " Speed: ", nums[0], " PWM: ", nums[3], "error: ", nums[4], "lastError: ", nums[5], "errorD: ", nums[6], "errorI: ", nums[7], "Kp: ", nums[8], "Kd: ", nums[9], "Ki: ", nums[10]);
      drawUpperGraph(nums[0], nums[1]);
      drawPWMPoint(nums[3]);
      if(!checkbox.getState(0)){
        cp5.get(Textfield.class,"Kp").setText(str(nums[8]));
        cp5.get(Textfield.class,"Kd").setText(str(nums[9]));
        cp5.get(Textfield.class,"Ki").setText(str(nums[10]));
        cp5.get(Textfield.class,"setpoint").setText(str(nums[1]));
        cp5.get(Textfield.class,"PWM").setText(str(nums[3]));
        // cp5.get(Textfield.class,"time").setText(str(nums[11]));
      }
      stroke(102);
      fill(102);
      rect(leftPanelWidth + 150, speedStartY - speedHeight - 20, windowWidth - rightPanelWidth - 2, 20);
      stroke(0,0,0);
      fill(0, 0, 0);
      text("Setpoint: " + nums[1] + "  Speed: " + nums[0] + " PWM: " + nums[3] + " error: " + nums[4] + " lastError: " + nums[5] + " errorD: " + nums[6] + " errorI: " + nums[7] + " Kp: " + nums[8] + " Kd: " + nums[9] + " Ki: " + nums[10] + " t: " +  nums[11], leftPanelWidth + 100, speedStartY - speedHeight - 2);   
      text("error: "+nums[4], 800, 55);
      text("lastError: "+nums[5], 800, 75);
      text("errorD: "+nums[6], 800, 95);
      text("errorI: "+nums[7], 800, 115);
      text("Speed: "+nums[0], 800, 35);
      
      newRow.setFloat("setpoint", nums[1]);
      newRow.setFloat("speed", nums[0]);
      newRow.setFloat("error", nums[4]);
      newRow.setFloat("lastError", nums[5]);
      newRow.setFloat("errorD", nums[6]);
      newRow.setFloat("errorI", nums[7]);
      newRow.setFloat("Kp", nums[8]);
      newRow.setFloat("Kd", nums[9]);
      newRow.setFloat("Ki", nums[10]);
      newRow.setFloat("pwm", nums[3]);
      newRow.setFloat("loopTime", nums[11]);
      newRow.setFloat("time", nums[12]);
      saveTable(table, bookName);
      //text(str(checkbox.getState(0)), windowWidth - rightPanelWidth + 30, 30);
    }
  }
}