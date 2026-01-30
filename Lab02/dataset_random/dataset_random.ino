/*
  Dataset 3: Random Sampling
  Interval: Random (50-300 ms)
  Samples: 30
*/

#include <Arduino.h>

// Counter to track the number of samples collected
int sampleCount = 0;

void setup() {
  // Initialize serial communication at 9600 bits per second
  Serial.begin(9600);
}

void loop() {
  // Check if we have collected fewer than 30 samples
  if (sampleCount < 30) {
    // Read the analog value from pin A0 and print it to the Serial Monitor
    Serial.println(analogRead(A0));
    
    // Increment the sample counter
    sampleCount++;
    
    // Generates a random delay between 50 and 300 ms
    delay(random(50, 300));
  }
}