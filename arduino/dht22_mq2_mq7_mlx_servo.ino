#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>
#include <Wire.h>
#include <Adafruit_MLX90614.h>
#include <ESP32Servo.h>

// WIFI CONFIG 
const char* WIFI_SSID = "SSID";
const char* WIFI_PASSWORD = "PASSWORD";

// FIREBASE RTDB CONFIG
const char* FIREBASE_DB_URL = "";
const char* SENSOR_PATH = "";

// SENSOR PINS
#define DHT22_PIN 27
#define MQ2_PIN 34
#define MQ7_PIN 35

// SERVO PINS
#define SERVO_PAN_PIN 12
#define SERVO_TILT_PIN 13

DHT dht22(DHT22_PIN, DHT22);
Adafruit_MLX90614 mlx = Adafruit_MLX90614();

Servo servoPan;
Servo servoTilt;

unsigned long lastPostMs = 0;
const unsigned long postIntervalMs = 5000;

float highestTemp = 0;
int bestPan = 90;
int bestTilt = 90;

void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;

  Serial.print("Connecting to WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < 30) {
    delay(500);
    Serial.print(".");
    retries++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi connected");
    Serial.print("IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWiFi connection failed");
  }
}

bool postToFirebase(float temperature, float humidity, int mq2, int mq7,
                    float mlxAmbient, float mlxObject,
                    bool fireDetected) {

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Firebase write skipped: WiFi disconnected");
    return false;
  }

  HTTPClient http;
  String endpoint = String(FIREBASE_DB_URL) + String(SENSOR_PATH);
  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");

  String payload = "{";
  payload += "\"temperature\":" + String(temperature, 2) + ",";
  payload += "\"humidity\":" + String(humidity, 2) + ",";
  payload += "\"mq2\":" + String(mq2) + ",";
  payload += "\"mq7\":" + String(mq7) + ",";
  payload += "\"mlxAmbient\":" + String(mlxAmbient, 2) + ",";
  payload += "\"mlxObject\":" + String(mlxObject, 2) + ",";
  payload += "\"maxTemp\":" + String(highestTemp, 2) + ",";
  payload += "\"pan\":" + String(bestPan) + ",";
  payload += "\"tilt\":" + String(bestTilt) + ",";
  payload += "\"fireDetected\":" + String(fireDetected ? "true" : "false") + ",";
  payload += "\"timestamp\":" + String(millis());
  payload += "}";

  int code = http.PUT(payload);
  String response = http.getString();
  http.end();

  Serial.print("Firebase HTTP Code: ");
  Serial.println(code);

  return (code > 0 && code < 300);
}

// Scan area and find hottest point
void scanForFire() {
  highestTemp = 0;

  for (int tilt = 0; tilt <= 75; tilt += 30) {
    servoTilt.write(tilt);
    delay(400);

    for (int pan = 30; pan <= 150; pan += 30) {
      servoPan.write(pan);
      delay(300);

      float temp = mlx.readObjectTempC();

      if (isnan(temp)) continue;

      if (temp > highestTemp) {
        highestTemp = temp;
        bestPan = pan;
        bestTilt = tilt;
      }
    }
  }

  // Move to hottest location
  servoPan.write(bestPan);
  servoTilt.write(bestTilt);
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  Wire.begin(25, 26);
  delay(1000);

  if (!mlx.begin()) {
    Serial.println("MLX90614 not detected!");
  }

  dht22.begin();

  servoPan.attach(SERVO_PAN_PIN);
  servoTilt.attach(SERVO_TILT_PIN);

  servoPan.write(90);
  servoTilt.write(90);

  analogReadResolution(12);
  analogSetAttenuation(ADC_11db);

  connectWiFi();
}

void loop() {
  connectWiFi();

  if (millis() - lastPostMs < postIntervalMs) {
    delay(100);
    return;
  }
  lastPostMs = millis();

  // Read gas sensors
  int mq2Value = analogRead(MQ2_PIN);
  int mq7Value = analogRead(MQ7_PIN);

  // Read DHT22
  float humidity = dht22.readHumidity();
  float tempC = dht22.readTemperature();

  // Scan area using MLX + Servos
  scanForFire();

  float mlxAmbient = mlx.readAmbientTempC();
  float mlxObject = mlx.readObjectTempC();

  // Fire detection logic (sensor fusion)
  bool fireDetected = (
    highestTemp > 60 &&
    (mq2Value > 1500 || mq7Value > 1000)
  );

  // Serial Monitor Output
  Serial.println("===== SENSOR DATA =====");
  Serial.print("MQ2: "); Serial.println(mq2Value);
  Serial.print("MQ7: "); Serial.println(mq7Value);
  Serial.print("Temp: "); Serial.println(tempC);
  Serial.print("Humidity: "); Serial.println(humidity);
  Serial.print("MLX Ambient: "); Serial.println(mlxAmbient);
  Serial.print("MLX Object: "); Serial.println(mlxObject);
  Serial.print("Max Temp Found: "); Serial.println(highestTemp);
  Serial.print("Pan Position: "); Serial.println(bestPan);
  Serial.print("Tilt Position: "); Serial.println(bestTilt);
  Serial.print("Fire Detected: "); Serial.println(fireDetected);
  Serial.println("=======================");

  // Send to Firebase
  postToFirebase(tempC, humidity, mq2Value, mq7Value,
                 mlxAmbient, mlxObject, fireDetected);
}