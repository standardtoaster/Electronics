#include <avr/interrupt.h>

volatile int openDoor;

//#define DEBUG;

//PIN Declarations
int pinLED = 13;
int pinCommand = 2;
int pinOverride = 3;
int pinUnlock = 9;
int pinLock = 8; //long pin
int pinSonar = 6;
int pinBuzzer = 11;
int pinDetectorPower = 12;
int pinDetector = 0;

//END Pins
void setup() {
#ifdef DEBUG
  pinCommand = 13;
  pinOverride = 13;
  pinUnlock = 13;
  pinLock = 13;
  pinSonar = 13;
  pinDetectorPower = 13;
  pinDetector = 13;
  pinBuzzer = 13;
#endif
  
  //set all the pin modes
  pinMode(pinLED, OUTPUT);
  pinMode(pinCommand, INPUT);
  pinMode(pinOverride, INPUT);
  pinMode(pinUnlock, OUTPUT);  
  pinMode(pinLock, OUTPUT);  
  pinMode(pinSonar, INPUT);
  pinMode(pinBuzzer, OUTPUT);  
  // attach our interrupt pin to it's ISR
  attachInterrupt(0, tellOpenDoor, RISING);
  attachInterrupt(1, tellOpenDoor, RISING);   
  // we need to call this to enable interrupts
  interrupts();


  openDoor = false;

  // blinky blinky
  int state = LOW;
  for(int x = 0; x < 29; x++) {
    digitalWrite(pinLED, state);
    state = !state;
    delay(50);
  }
}

void loop() {
  if (openDoor) {
    processDoor();
  }
  
}

void tellOpenDoor()
{
  if (!openDoor) {
    openDoor = true;
  }
}

void processDoor() {

  //unlock the door, 4 pulses, 50 ms high, 100ms low
  for(int x = 0; x < 4; x++) {
    digitalWrite(pinLED, HIGH);
    digitalWrite(pinUnlock, HIGH);
    delay(200);
    digitalWrite(pinLED, LOW);
    digitalWrite(pinUnlock, LOW);
    delay(200);
  }
  
  //now the door is unlocked. fire up the sonar to see if it's closed
  
  //read the sonar values 30 times with a 1 second pause - 30 seconds to have the door open
  boolean doorClosed = false;
  int doorOpenDuration = 0;
 
  while(!doorClosed){
    digitalWrite(pinLED, HIGH);
    //if the door has been open for 30 seconds, sound the alarm
    if (doorOpenDuration == 30)
    {
      digitalWrite(pinBuzzer, HIGH);
    }
    
    //read the sensor
    int doorDistance = pulseIn(pinSonar, HIGH);
    //147uS per inch
    // 882uS ~= 6in
    if(doorDistance < 900)
    {
      //door appears to be closed. go on
      doorClosed = true;
      //ensure that buzzer is off
      digitalWrite(pinBuzzer, LOW);
    }
    delay(1000);
    digitalWrite(pinLED, LOW);
    doorOpenDuration++;
  }
  //send the lock pulse
  digitalWrite(pinLock, HIGH);
  delay(100);
  digitalWrite(pinLock, LOW);

  //turn off the LED
  digitalWrite(pinLED, LOW);
  //reset for WAIT
  openDoor = false;
    
}
