#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <WebSocketsServer_Generic.h>
#include "config.h"

WebSocketsServer webSocket = WebSocketsServer(SOCKET_PORT);
ESP8266WebServer server(WEB_PORT);
// Rotary Encoder Inputs
#define CLK 16
#define DT 12
#define SW 13
// Notify pin output
#define BUZZER 0

int weight = 0;
int currentStateCLK;
int lastStateCLK;
String DIRECTION  = "";
unsigned long lastButtonPress = 0;
unsigned long last_10sec = 0;
unsigned int counter = 0;
void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t lenght) {

  switch (type) {
    case WStype_DISCONNECTED:
      break;
    case WStype_CONNECTED: {
      IPAddress connectedIp = webSocket.remoteIP(num);
      Serial.print("connected:");
      Serial.println(connectedIp);
    }
    break;
    case WStype_TEXT: {
      String text = String((char *) &payload[0]);
        Serial.println(text);
    }
     break;
   default:
    Serial.println("WAITING COMMANDS");
    break;
  }

}

void setup() {
  Serial.begin(115200);
  pinMode(CLK,INPUT);
	pinMode(DT,INPUT);
  pinMode(BUZZER, OUTPUT);
	pinMode(SW, INPUT_PULLUP);
  lastStateCLK = digitalRead(CLK);

  WiFi.config(ip, dns, gateway, subnet);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(". ");
    delay(100);
  }
  printSerialInfo();

  webSocket.begin();
  server.begin();
  server.on("/ping", []() {
    notifyAlarm();
    server.send(200, "text/plain", "pong");
  });
  webSocket.onEvent(webSocketEvent);
}

void loop() { 
  webSocket.loop();
  server.handleClient();
  encoderEvent();
  unsigned long t = millis();
if ((t - last_10sec) > 10 * 1000)
  {
    counter++;
    bool ping = (counter % 2);
    int i = webSocket.connectedClients(ping);
    Serial.printf("%d Connected websocket clients ping: %d\n", i, ping);
    last_10sec = millis();
  }
}

void printSerialInfo(){
  Serial.println();
  Serial.print("MAC: ");
  Serial.println(WiFi.macAddress());
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());
}

void encoderEvent(){
	currentStateCLK = digitalRead(CLK);
	if (currentStateCLK != lastStateCLK  && currentStateCLK == 1){
    uint currentValue = digitalRead(DT);
    if (currentValue != currentStateCLK && weight > 0){
      weight--;
			DIRECTION ="CCW";
      return;
    }
    weight++;
    DIRECTION ="CW";
    Serial.println(weight);
	}
	lastStateCLK = currentStateCLK;
	int btnState = digitalRead(SW);
	if (btnState == LOW) {
		if (millis() - lastButtonPress > 50) {
			Serial.println("Button pressed!");
      webSocket.broadcastTXT("{}");
		}
		lastButtonPress = millis();
	}
	delay(1);
}

void notifyAlarm(){
    digitalWrite(BUZZER, HIGH);
    delay(100);
    digitalWrite(BUZZER, LOW);
}