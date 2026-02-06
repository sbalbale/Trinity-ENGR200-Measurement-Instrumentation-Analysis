/*
 * Engineering 200 - Lab 3: Uncertainty in Measurements
 * Purpose: Collect analog voltage data from Pin A0
 * Sampling Interval: 10 ms
 */

const int analogPin = A0; // The pin connected to the wire (antenna) or GND
const int sampleInterval = 10; // 10 ms sampling interval 
unsigned long previousMillis = 0;

void setup() {
  // Initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  
  // Print header for CSV format
  Serial.println("Time(ms),ADC_Value");
}

void loop() {
  unsigned long currentMillis = millis();

  // Non-blocking delay to maintain 10ms interval
  if (currentMillis - previousMillis >= sampleInterval) {
    previousMillis = currentMillis;

    // Read the input on analog pin 0:
    // Returns an integer between 0 and 1023
    int sensorValue = analogRead(analogPin);

    // Print time and value separated by comma (CSV format)
    Serial.print(currentMillis);
    Serial.print(",");
    Serial.println(sensorValue);
  }
}