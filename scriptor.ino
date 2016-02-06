/*
Reads the values from a0-a3 and writes them as binary to the serial interface.

MIT LICENSE 2016
*/

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication
  Serial.begin(115200); // bits per second
}

// the loop routine runs over and over again forever:
// TODO: Loop timing
void loop() {
  // read the input on analog pin 0:
  unsigned long time = micros(); // time since program start.
                                 // Overflows after 40 minutes

  // It takes about 100 microseconds (0.0001 s) to read an analog input,
  // so the maximum reading rate is about 10,000 times a second.
  int a0 = analogRead(A0);
  int a1 = analogRead(A1);
  int a2 = analogRead(A2);
  int a3 = analogRead(A3);

  int t0 = (int) (time >> 16);
  int t1 = (int) (time & 0x0000ffff);
  int values[7] = {t0, t1, a0, a1, a2, a3, 0xFFFF};
  // print out the value you read:
  Serial.write((uint8_t*) &values, 7*sizeof(*values));
}
