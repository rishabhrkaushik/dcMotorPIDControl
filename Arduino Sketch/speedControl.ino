// interrupt using hall effect or IR sensor on pin number 2 of Arduino
#define interruptPin 2

// direction pin and pwm pin of motor driver
#define dirPin 5
#define pwmPin 10

// interrupts per rotation. Number of magnets in this case
int n = 1;

// loop time
int t = 100;

// value of pwm signal
double pwmValue = 100;

// time for measuring speed
unsigned long lastTime;
unsigned long timePassed;

unsigned long lastLoopTime = millis();
unsigned long loopTime;

// min time between two interrupt else speed will be made zero
unsigned long minSpeedTime = 500000;

// measured speed
float speedM = 0;

float desiredSpeed = 3500;

// errors
double error = 0;
double lastError = 0;
double errorD = 0;
double errorI = 0;

// feedback loop constants
float kp = 0.02;
float kd = 20;
float ki = 0;

// closed loop or open loop configurations flags
bool pFlag = false;
bool kFlag = true;
int kCount = 0;

void countInc(){
  timePassed = micros() - lastTime;
  lastTime = micros();  
}

// read commands
void serialRead(){
  //K:p100i0.2d10
  //P:100
  //S:100
  if(Serial.available()){
    String rec  = Serial.readStringUntil('\n');
    if(rec.charAt(0) == 'K'){
      kFlag = true; 
      kCount = 50;
      pFlag = false; 
      kp = rec.substring(rec.indexOf('p')+1, rec.indexOf('d')).toFloat();
      kd = rec.substring(rec.indexOf('d')+1, rec.indexOf('i')).toFloat();
      ki = rec.substring(rec.indexOf('i')+1, rec.indexOf('t')).toFloat(); 
      t =  rec.substring(rec.indexOf('t')+1, rec.indexOf('\n')).toFloat(); 
    }
    else if(rec.charAt(0) == 'S'){
      kFlag = false;
      pFlag = false;
      desiredSpeed = rec.substring(rec.indexOf(':')+1, rec.indexOf('\n')).toInt();    
      error = 0;
      lastError = 0;
      errorD = 0;
      errorI = 0;
      // Serial.print("Setpoint: ");Serial.println(desiredSpeed); 
    }
    else if(rec.charAt(0) == 'P'){
      kFlag = false;
      pFlag = true;
      pwmValue = rec.substring(rec.indexOf(':')+1, rec.indexOf('\n')).toInt();    
      // Serial.print("PWM: ");Serial.println(pwmValue);       
    }
    else{
      // Serial.println("error in spliting");
      while(Serial.available()){
        Serial.read();  
      }
    }
    while(Serial.available()){
      Serial.read();  
    }
  }
}

// send data to serial to make graph via processing app
void processing(){
  //speed setpoint pwm contrainPWM error lastError errorD errorI Kp Kd Ki
  Serial.print(String(speedM, 8));
  Serial.print(" ");
  Serial.print(String(desiredSpeed, 8));
  Serial.print(" ");
  // two times pwmValue is a bug but processing is splitting data according to this index hence don't remove
  Serial.print(String(pwmValue, 8));
  Serial.print(" ");
  Serial.print(String(pwmValue, 8));
  Serial.print(" ");
  Serial.print(String(error, 8));
  Serial.print(" ");
  Serial.print(String(lastError, 8));
  Serial.print(" ");
  Serial.print(String(errorD, 8));
  Serial.print(" ");
  Serial.print(String(errorI, 8));
  Serial.print(" ");
  Serial.print(String(kp, 8));
  Serial.print(" ");
  Serial.print(String(kd, 8));
  Serial.print(" ");
  Serial.print(String(ki, 8));
  Serial.print(" ");
  Serial.print(String(loopTime));
  Serial.print(" ");
  Serial.print(String(millis()));
  Serial.println(" ");
}
void setup(){
  pinMode(interruptPin, INPUT);
  attachInterrupt(0, countInc, FALLING);
  Serial.begin(9600);
  Serial.setTimeout(10);
  pinMode(pwmPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  digitalWrite(dirPin, LOW);
  analogWrite(pwmPin, pwmValue);
  delay(1000);  
}

void loop(){
  serialRead();
  //speed measurement, if time passed = 0, speed = 0
  if(micros() - lastTime >= minSpeedTime){
    speedM = 0;
  }
  else{
    // speed = 1min in microseconds/time between subsequent interrupt times
    speedM = 60000000/(timePassed*n);
  }
  loopTime = millis() - lastLoopTime;
  
  error = desiredSpeed - speedM;
  errorI += (error*loopTime);
  errorD = (error - lastError)/loopTime;

  lastLoopTime = millis(); 

  if(kFlag){
    pwmValue = 0;
    error = 0;
    lastError = 0;
    errorD = 0;
    errorI = 0;
    if(kCount == 0)
      kFlag = false;
  }

  if(!pFlag && !kFlag){

    pwmValue+=(kp*error)+(kd*errorD)+(ki*errorI);

    pwmValue= constrain(pwmValue, 0, 255); 
  }

  analogWrite(pwmPin, pwmValue);
  processing();
  delay(t);
  lastError = error;
  kCount --;
}