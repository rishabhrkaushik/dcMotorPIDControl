// interrupt using hall effect or IR sensor on pin number 2 of Arduino
#define interruptPin 2

unsigned long rotationsCount = 0;

void countInc(){
  rotationsCount++;
}

void setup(){
  pinMode(interruptPin, INPUT);
  attachInterrupt(0, countInc, FALLING);
  Serial.begin(9600);
  Serial.setTimeout(10);
  delay(1000);  
}

void loop(){
  Serial.print("Rotations: ");
  Serial.print(rotationsCount);
  Serial.print("    Time: ");
  Serial.println(millis());
  delay(100);
}