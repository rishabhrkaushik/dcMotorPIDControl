// interrupt using hall effect or IR sensor on pin number 2 of Arduino
#define interruptPin 2

// interrupts per rotation. Number of magnets in this case
int n = 1;

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

void setup(){
  pinMode(interruptPin, INPUT);
  attachInterrupt(0, countInc, FALLING);
  Serial.begin(9600);
  Serial.setTimeout(10);
  delay(1000);  
}

void loop(){
  if(micros() - lastTime >= minSpeedTime){
    speedM = 0;
  }
  else{
   speedM = 60000000/(timePassed*n);
  }
  Serial.print("Current Measured Speed: ");
  Serial.println(speedM);
  
  delay(100);
}