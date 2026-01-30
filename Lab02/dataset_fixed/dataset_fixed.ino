/*
  Dataset 1: Fixed-Rate Sampling
  Interval: 100 ms
  Samples: 100
*/

#include <Arduino.h>

// Counter to track the number of samples collected
int sampleCount = 0;

void setup() {
  // Initialize serial communication at 9600 bits per second
  Serial.begin(9600);
}

void loop() {
  // Check if we have collected fewer than 100 samples
  if (sampleCount < 100) {
    // Read the analog value from pin A0 and print it to the Serial Monitor
    Serial.println(analogRead(A0));
    
    // Increment the sample counter
    sampleCount++;
    
    // Wait for 100 milliseconds before the next sample (Fixed Rate)
    delay(100);
  }
}