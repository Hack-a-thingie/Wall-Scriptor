/*
Reads the values from a0-a3 and writes them as binary to the serial interface.

MIT LICENSE 2016
*/
#define N 128

#define FASTADC 1

// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

typedef struct {
	unsigned long time; // 32bit
	unsigned long data; // 32bit
} __attribute__((__packed__)) Data;

Data MESSAGES[N];
size_t counter = 0;

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication
  Serial.begin(115200); // bits per second
  
  #if FASTADC
 // set prescale to 16
 sbi(ADCSRA,ADPS2) ;
 cbi(ADCSRA,ADPS1) ;
 cbi(ADCSRA,ADPS0) ;
 #endif
 
}

// the loop routine runs over and over again forever:
void loop() {
  
  // read the input on analog pin 0:
  unsigned long time = micros(); // time since program start.
                                 // Overflows after 40 minutes

  // It takes about 100 microseconds (0.0001 s) to read an analog input,
  // so the maximum reading rate is about 10,000 times a second.
  int a0 = analogRead(A0);
  int a2 = analogRead(A2);
  int a4 = analogRead(A4);

  unsigned long data = (((unsigned long) a0) << 20) | (((unsigned long) a2) << 10) | ((unsigned long) a4);
  
  // create msg
  Data msg = {time, data};
  
  if (counter < N) {
	  MESSAGES[counter] = msg;
	  counter++;
  }
  
  // send data over serial
  if (counter == N) {
	  counter = 0;
	  Serial.write("SSSSSSSS"); // Start tag 32bit zeros
	  Serial.write((uint8_t*) MESSAGES, N*sizeof(*MESSAGES));
  }
}
