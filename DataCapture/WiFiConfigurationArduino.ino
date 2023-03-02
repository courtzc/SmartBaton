/*
    This sketch sends a string to a TCP server, and prints a one-line response.
    You must run a TCP server in your local network.
    For example, on Linux you can use this command: nc -v -l 3000
*/

#include <ESP8266WiFi.h>

const char* ssid = ${WIFI_SSID};
const char* password = ${WIFI_PASSWORD};


WiFiClient client;

void setup() {

    Serial.begin(115200);

    Serial.println();
    Serial.println();
    Serial.print("Connecting to WiFi");
    Serial.println("...");
    WiFi.begin(ssid, password);
    int retries = 0;

    while ((WiFi.status() != WL_CONNECTED) && (retries < 15)) {
      retries++;
      delay(500);
      Serial.print(".");
    }

    if (retries > 14) {
        Serial.println(F("WiFi connection FAILED"));
    }

    if (WiFi.status() == WL_CONNECTED) {
        Serial.println(F("WiFi connected!"));
        Serial.println("IP address: ");
        Serial.println(WiFi.localIP());
    }

    Serial.println(F("Setup ready"));
  
}


void loop() {
  
}
