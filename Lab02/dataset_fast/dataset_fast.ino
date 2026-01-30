/*
  Dataset 2: High-Rate Sampling (Time-Limited)
  Interval: 10 ms
  Max Duration: 20 seconds
  Max Samples: 300
*/

#include <Arduino.h>

// Variable to store the program start time in milliseconds
unsigned long startTime;
// Counter to track the number of samples collected
int sampleCount = 0;

void setup() {
  // Initialize serial communication at 9600 bits per second
  Serial.begin(9600);
  
  // Record the time when the setup finishes
  startTime = millis();
}

void loop() {
  // Checks if time is under 20s AND samples are under 300
  // millis() returns the number of milliseconds since the board started
  if ((millis() - startTime <= 20000) && (sampleCount < 300)) {
    // Read the analog value from pin A0 and print it to the Serial Monitor
    Serial.println(analogRead(A0));
    
    // Increment the sample counter
    sampleCount++;
    
    // Wait for 10 milliseconds (High Rate)
    delay(10);
  }
}