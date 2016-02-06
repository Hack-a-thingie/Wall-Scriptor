/*
Reads the values from a0-a3 and writes them as binary to the serial interface.

MIT LICENSE 2016
*/

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication
  Serial.begin(115200); // bits per second
  analogReference(INTERNAL);
}

// the loop routine runs over and over again forever:
void loop() {
  
  // read the input on analog pin 0:
  unsigned long time = micros(); // time since program start.
                                 // Overflows after 40 minutes

  // It takes about 100 microseconds (0.0001 s) to read an analog input,
  // so the maximum reading rate is about 10,000 times a second.
  int a0 = analogRead(A0);
  int a1 = analogRead(A1);
  int a2 = analogRead(A2);
  // int a3 = analogRead(A3);

  // print out the value you read:
  Serial.print(time);
  Serial.print(", ");
  Serial.print(a0);
  Serial.print(", ");
  Serial.print(a1);
  Serial.print(", ");
  Serial.print(a2);
  Serial.print("\n");
  //Serial.print(", ");
  //Serial.println(a3);
}
