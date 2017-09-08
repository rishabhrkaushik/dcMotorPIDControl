// interrupt using hall effect or IR sensor on pin number 2 of Arduino
#define interruptPin 2

// direction pin and pwm pin of motor driver
#define dirPin 5
#define pwmPin 10

// interrupts per rotation. Number of magnets in this case
int n = 1;

// value of pwm signal
double pwmValue = 100;

// time for measuring speed
unsigned long lastTime;
unsigned long timePassed;

unsigned long lastLoopTime = millis();

// min time between two interrupt else speed will be made zero
unsigned long minSpeedTime = 500000;

// measured speed
float speedM = 0;

void countInc(){
  timePassed = micros() - lastTime;
  lastTime = micros();  
}

// read commands
void serialRead(){
  // pwm read as
  //P:100
  if(Serial.available()){
    String rec  = Serial.readStringUntil('\n');
    if(rec.charAt(0) == 'P'){
      pwmValue = rec.substring(rec.indexOf(':')+1, rec.indexOf('\n')).toInt();     
      Serial.print("PWM: ");Serial.println(pwmValue);       
    }
  }
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
  analogWrite(pwmPin, pwmValue);
  Serial.print("Current Measured Speed(rpm): ");
  Serial.println(speedM);

  delay(100);
}