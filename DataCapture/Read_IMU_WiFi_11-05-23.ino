#include <ICM_20948.h>
#include <ESP8266WiFi.h>

/****************************************************************
 * Example1_Basics.ino
 * ICM 20948 Arduino Library Demo
 * Use the default configuration to stream 9-axis IMU data
 * Owen Lyke @ SparkFun Electronics
 * Original Creation Date: April 17 2019
 *
 * Please see License.md for the license information.
 *
 * Distributed as-is; no warranty is given.
 ***************************************************************/
#include "ICM_20948.h" // Click here to get the library: http://librarymanager/All#SparkFun_ICM_20948_IMU


#define SERIAL_PORT Serial
#define STACK_PROTECTOR 512  // bytes
#define WIRE_PORT Wire // Your desired Wire port.      Used when "USE_SPI" is not defined
// The value of the last bit of the I2C address.
// On the SparkFun 9DoF IMU breakout the default is 1, and when the ADR jumper is closed the value becomes 0
#define AD0_VAL 0


ICM_20948_I2C myICM; // Otherwise create an ICM_20948_I2C object

char data[150];

// wifi setup ----------
const char* ssid = "WiFi-CAFB";
const char* password = "EpsieAxii1";
const int port = 23;

WiFiServer server(port);
WiFiClient serverClients[2]; // accept two people

IPAddress local_IP(192, 168, 1, 199);
IPAddress gateway(192, 168, 1, 1);
IPAddress subnet(255, 255, 0, 0);
IPAddress primaryDNS(8, 8, 8, 8); // optional
IPAddress secondaryDNS(8, 8, 4, 4); // toptional
// ----------------------


void setup()
{

  SERIAL_PORT.begin(115200);
  
  while (!SERIAL_PORT)
  {
  };

  // WiFi setup ------------
  if (!WiFi.config(local_IP, gateway, subnet, primaryDNS, secondaryDNS)) {
    Serial.println("STA Failed to configure");
  }
  else
  {
    Serial.println("WiFi configured successfully!");
  }
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
  //------------------------
  
  // server setup -------------
  server.begin();
  server.setNoDelay(true);
  Serial.print("server ready! Use 'telnet ");
  Serial.print(WiFi.localIP());
  Serial.printf(" %d' to connect\n", port);
  // --------------------------
  
  WIRE_PORT.begin();
  WIRE_PORT.setClock(400000);


  myICM.enableDebugging(); // Uncomment this line to enable helpful debug messages on Serial

  bool initialized = false;
  while (!initialized)
  {
    myICM.begin(WIRE_PORT, AD0_VAL);

    SERIAL_PORT.print(F("Initialization of the sensor returned: "));
    SERIAL_PORT.println(myICM.statusString());
    if (myICM.status != ICM_20948_Stat_Ok)
    {
      SERIAL_PORT.println("Trying again...");
      delay(500);
    }
    else
    {
      initialized = true;
    }
  }
  
}

void loop()
{
  if (server.hasClient()) {
    Serial.println("oh my gosh we have a client!!");    
    serverClients[1] = server.accept(); // assuming first connection for now
    Serial.println("Client accepted.");    
    
    int maxToTcp = serverClients[1].availableForWrite();
    Serial.printf("max to tcp is: %d.\n", maxToTcp);    

    // get all data available, up to the tcp max
    // size_t len = std::min(Serial.available(), maxToTcp);
    // Serial.printf("len is: %d.\n", len);  
    // Serial.printf("because Serial.avaiable is : %d.\n", Serial.available());  
    // len = std::min(len, (size_t)STACK_PROTECTOR);
        
    while (serverClients[1].availableForWrite() > 0) 
    {
      // get data - values are updated through 'getAGMT'
      myICM.getAGMT(); 
      // put into data
      sprintf(data, "%.2f %.2f %.2f; %.2f %.2f %.2f; %.2f %.2f %.2f \0", (myICM.accX()), (myICM.accY()), (myICM.accZ()), (myICM.gyrX()), (myICM.gyrY()), (myICM.gyrZ()), (myICM.magX()), (myICM.magY()), (myICM.magZ()));
      size_t len = strlen(data);
      
      // if the pointer is real (not null) but starts with '\0', it's an empty string.
      if ((data != NULL) && (data[0] != '\0')) {
        Serial.print("server: ");
        Serial.print(serverClients[1]);
        Serial.print(" | sending:");       
        Serial.println(data);  
 
        // push data to connected client
        if (serverClients[1].availableForWrite() >= 0) {
          size_t tcp_sent = serverClients[1].write(data, len);
        }
        else
        {
          Serial.println("couldn't send, client not available.");
        }
      }
      else
      {
        Serial.println("nothing to send.");  
      }
      delay(10);
    }
    
  }

  // if (myICM.dataReady())
  // {
  //   myICM.getAGMT();         // The values are only updated when you call 'getAGMT'
  //                            //    printRawAGMT( myICM.agmt );     // Uncomment this to see the raw values, taken directly from the agmt structure
  //   printScaledAGMT(&myICM); // This function takes into account the scale settings from when the measurement was made to calculate the values with units
  //   delay(30);
  // }
  // else
  // {
  //   SERIAL_PORT.println("Waiting for data");
  //   delay(500);
  // }
}

// Below here are some helper functions to print the data nicely!

void printPaddedInt16b(int16_t val)
{
  if (val > 0)
  {
    SERIAL_PORT.print(" ");
    if (val < 10000)
    {
      SERIAL_PORT.print("0");
    }
    if (val < 1000)
    {
      SERIAL_PORT.print("0");
    }
    if (val < 100)
    {
      SERIAL_PORT.print("0");
    }
    if (val < 10)
    {
      SERIAL_PORT.print("0");
    }
  }
  else
  {
    SERIAL_PORT.print("-");
    if (abs(val) < 10000)
    {
      SERIAL_PORT.print("0");
    }
    if (abs(val) < 1000)
    {
      SERIAL_PORT.print("0");
    }
    if (abs(val) < 100)
    {
      SERIAL_PORT.print("0");
    }
    if (abs(val) < 10)
    {
      SERIAL_PORT.print("0");
    }
  }
  SERIAL_PORT.print(abs(val));
}

void printRawAGMT(ICM_20948_AGMT_t agmt)
{
  SERIAL_PORT.print("RAW. Acc [ ");
  printPaddedInt16b(agmt.acc.axes.x);
  SERIAL_PORT.print(", ");
  printPaddedInt16b(agmt.acc.axes.y);
  SERIAL_PORT.print(", ");
  printPaddedInt16b(agmt.acc.axes.z);
  SERIAL_PORT.print(" ], Gyr [ ");
  printPaddedInt16b(agmt.gyr.axes.x);
  SERIAL_PORT.print(", ");
  printPaddedInt16b(agmt.gyr.axes.y);
  SERIAL_PORT.print(", ");
  printPaddedInt16b(agmt.gyr.axes.z);
  SERIAL_PORT.print(" ], Mag [ ");
  printPaddedInt16b(agmt.mag.axes.x);
  SERIAL_PORT.print(", ");
  printPaddedInt16b(agmt.mag.axes.y);
  SERIAL_PORT.print(", ");
  printPaddedInt16b(agmt.mag.axes.z);
  SERIAL_PORT.print(" ], Tmp [ ");
  printPaddedInt16b(agmt.tmp.val);
  SERIAL_PORT.print(" ]");
  SERIAL_PORT.println();
}

void printFormattedFloat(float val, uint8_t leading, uint8_t decimals)
{
  float aval = abs(val);
  if (val < 0)
  {
    SERIAL_PORT.print("-");
  }
  else
  {
    SERIAL_PORT.print(" ");
  }
  for (uint8_t indi = 0; indi < leading; indi++)
  {
    uint32_t tenpow = 0;
    if (indi < (leading - 1))
    {
      tenpow = 1;
    }
    for (uint8_t c = 0; c < (leading - 1 - indi); c++)
    {
      tenpow *= 10;
    }
    if (aval < tenpow)
    {
      SERIAL_PORT.print("0");
    }
    else
    {
      break;
    }
  }
  if (val < 0)
  {
    SERIAL_PORT.print(-val, decimals);
  }
  else
  {
    SERIAL_PORT.print(val, decimals);
  }
}



void printScaledAGMT(ICM_20948_I2C *sensor, char** data)
{
  // float valAccX = sensor->accX();
  
  // float valAccY = sensor->accY();

  // char strValAccX[10];
  // char strValAccY[10];

  // dtostrf(valAccX, 8, 2, strValAccX);
  // dtostrf(valAccY, 8, 2, strValAccY);

  // Serial.print("strValAccX: ");
  // Serial.println(strValAccX);
  // Serial.print("strValAccY: ");
  // Serial.println(strValAccY);
  char valData[150];
  
  sprintf(valData, "%.2f %.2f %.2f; %.2f %.2f %.2f; %.2f %.2f %.2f", (sensor->accX()), (sensor->accY()), (sensor->accZ()), (sensor->gyrX()), (sensor->gyrY()), (sensor->gyrZ()), (sensor->magX()), (sensor->magY()), (sensor->magZ()));
  // sprintf(valData, "%s %s %s; %s %s %s; %s %s %s", valAccX, strValAccY);
  // Serial.print("valData: ");
  // Serial.println(valData);  
  *data = valData;
  // return data;
  // printFormattedFloat(sensor->accX(), 5, 2);
  // SERIAL_PORT.print(" ");
  // printFormattedFloat(sensor->accY(), 5, 2);
  // SERIAL_PORT.print(" ");
  // printFormattedFloat(sensor->accZ(), 5, 2);
  // SERIAL_PORT.print("; ");
  // printFormattedFloat(sensor->gyrX(), 5, 2);
  // SERIAL_PORT.print(" ");
  // printFormattedFloat(sensor->gyrY(), 5, 2);
  // SERIAL_PORT.print(" ");
  // printFormattedFloat(sensor->gyrZ(), 5, 2);
  // SERIAL_PORT.print("; ");
  // printFormattedFloat(sensor->magX(), 5, 2);
  // SERIAL_PORT.print(" ");
  // printFormattedFloat(sensor->magY(), 5, 2);
  // SERIAL_PORT.print(" ");
  // printFormattedFloat(sensor->magZ(), 5, 2);
  // SERIAL_PORT.println();
}