// interrupt using hall effect or IR sensor on pin number 2 of Arduino
#define interruptPin 2

void setup(){
  pinMode(interruptPin, INPUT);
  Serial.begin(9600);
  Serial.setTimeout(10);
  delay(1000);	
}

void loop(){
  Serial.print("read: ");
  Serial.println(digitalRead(interruptPin));
  delay(100);
}