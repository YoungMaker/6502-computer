
// pin definitions
#define CLK_OUT 2
#define MODE_BT 6
#define STEP_BT 10

#define SINGLE_MODE 0
#define MAX_MODE 5

// debounce timeout
#define DB_TIMEOUT 50

// mode timeout
#define MODE_TIMEOUT 50

int modes[] = {0, 1000, 500, 200, 10, 2};
int mode = 0;

int clk = LOW;

unsigned long lastClkSet = 0;

unsigned long lastModeTime = 0;
int lastMode = LOW;

unsigned long lastStepTime = 0;
int lastStep = LOW;

void setup() {
  pinMode(STEP_BT, INPUT);
  pinMode(MODE_BT, INPUT);
  pinMode(CLK_OUT, OUTPUT);
  digitalWrite(CLK_OUT, LOW);
  Serial.begin(9600);
}

void loop() {
  // check if the mode button is rising edge
  // then change modes
  if(hasModeTripped()) {
    mode++;
    if( mode > MAX_MODE) {
      mode = 0;
    }
    Serial.print("Clk mode set to: ");
    Serial.print(mode[modes]);
    Serial.println(" ms");
  }

  // if in single mode set single pulse if single is depressed
  if(mode == SINGLE_MODE){
    clk = getStep();
    digitalWrite(CLK_OUT, clk);
    delay(100);
    return;
  }
  
  // we're not in SINGLE_MODE then,
  // see how long the clk has been in this state, if longer than mode setting/2,
  // flip the clock state
  unsigned long timeSinceClk = (millis() - lastClkSet);
  if(timeSinceClk > (modes[mode]/2) ) { // check timeout against mode length
    clk = !clk;
    lastClkSet = millis();
  }
  digitalWrite(CLK_OUT, clk); 
}

// captures rising edge 
bool hasModeTripped() {
  // capture the amount of time that has passed since we last read this
  unsigned long timeSinceLastRead = (millis() - lastModeTime);
  //read the pin
  int mode = digitalRead(MODE_BT);
  // if we're outside the last read and it flipped. 
  // return true if the button is down
  //Serial.print("Mode Time = ");
  //Serial.println(timeSinceLastRead);
  if(mode != lastMode && timeSinceLastRead > MODE_TIMEOUT) {
    lastModeTime = millis();
    lastMode = mode;
    return (mode == HIGH);
  }

  return false;
  
}

//captures rising edge
bool getStep() {
  // capture the amount of time that has passed since we last read this
  unsigned long timeSinceLastRead = (millis() - lastStepTime);
  //read the pin
  int stepState = digitalRead(STEP_BT);
  // if we're outside the last read and it flipped. 
  // return true if the button is down
  if(stepState != lastStep && timeSinceLastRead > DB_TIMEOUT) {
    lastStepTime = millis();
    lastStep = stepState;
    return (stepState == HIGH);
  }

  return false;
  
}
