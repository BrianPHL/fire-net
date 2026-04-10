#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

// WIFI CONFIG 
const char* WIFI_SSID = "GANAPIN";
const char* WIFI_PASSWORD = "ganapin2648";

// FIREBASE RTDB CONFIG
const char* FIREBASE_DB_URL = "https://firenet-ad9ab-default-rtdb.asia-southeast1.firebasedatabase.app/";
const char* SENSOR_PATH = "/sensor_nodes/esp32-node-1.json";

// SENSOR PINS (UPDATED)
#define DHT22_PIN 26
#define MQ2_PIN 34
#define MQ7_PIN 35

DHT dht22(DHT22_PIN, DHT22);

unsigned long lastPostMs = 0;
const unsigned long postIntervalMs = 5000;

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

bool postToFirebase(float temperature, float humidity, int mq2, int mq7, bool sensorError) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Firebase write skipped: WiFi disconnected");
    return false;
  }

  HTTPClient http;
  String endpoint = String(FIREBASE_DB_URL) + String(SENSOR_PATH);
  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");

  String payload = "{";
  payload += "\"name\":\"ESP32 Node 1\",";
  payload += "\"location\":\"Test Bench\",";
  payload += "\"temperature\":" + String(temperature, 2) + ",";
  payload += "\"humidity\":" + String(humidity, 2) + ",";
  payload += "\"mq2\":" + String(mq2) + ",";
  payload += "\"mq7\":" + String(mq7) + ",";
  payload += "\"sensorError\":" + String(sensorError ? "true" : "false") + ",";
  payload += "\"wifiConnected\":true,";
  payload += "\"timestamp\":" + String(millis());
  payload += "}";

  int code = http.PUT(payload);
  String response = http.getString();
  http.end();

  if (code > 0 && code < 300) {
    Serial.println("Firebase write success");
    return true;
  }

  Serial.print("Firebase write failed. HTTP code: ");
  Serial.println(code);
  Serial.print("Response: ");
  Serial.println(response);
  return false;
}

void setup() {
  Serial.begin(115200);
  dht22.begin();

  // ADC config for ESP32
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

  // Read sensors
  int mq2Value = analogRead(MQ2_PIN);
  int mq7Value = analogRead(MQ7_PIN);

  float humidity = dht22.readHumidity();
  float tempC = dht22.readTemperature();

  bool dhtError = isnan(tempC) || isnan(humidity);

  Serial.print("MQ2: ");
  Serial.print(mq2Value);
  Serial.print(" | MQ7: ");
  Serial.print(mq7Value);
  Serial.print(" | ");

  if (dhtError) {
    Serial.println("Failed to read from DHT22");
    postToFirebase(0, 0, mq2Value, mq7Value, true);
    return;
  }

  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print("% | Temp: ");
  Serial.print(tempC);
  Serial.println(" C");

  postToFirebase(tempC, humidity, mq2Value, mq7Value, false);
}