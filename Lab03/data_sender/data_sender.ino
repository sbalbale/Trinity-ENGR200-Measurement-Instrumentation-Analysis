/*
 * File: data_sender.ino
 * Purpose: Send analog voltage data from Pin A0 to MATLAB via Serial
 * Sampling Interval: 10 ms
 * Author: Sean Balbale
 * Date: 02/06/2026
 */
#include <Arduino.h>
const int analogPin = A0;
const int sampleInterval = 10; // 10 ms interval
unsigned long previousMillis = 0;

void setup()
{
  Serial.begin(9600);                   // Baud rate must match MATLAB
  Serial.println("Time(ms),ADC_Value"); // Print CSV header
}

void loop()
{
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= sampleInterval)
  {
    previousMillis = currentMillis;

    int sensorValue = analogRead(analogPin);

    // Print in CSV format: Time,Value
    Serial.print(currentMillis);
    Serial.print(",");
    Serial.println(sensorValue);
  }
}