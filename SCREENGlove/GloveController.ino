/*
Serial Monitor
*/

#include <ArduinoBLE.h>
#include <Arduino_LSM9DS1.h>
#include <Smoothed.h>

#define NUMBER_OF_SENSORS 10
#define RED 22     
#define BLUE 24     
#define GREEN 23
#define LED_PWR 25

//consts
const int SMOOTHING_WINDOW =   10;

//accel smooths
Smoothed <float> imu_xa_s;
Smoothed <float> imu_ya_s;
Smoothed <float> imu_za_s;

//gyroscope smooths
Smoothed <float> imu_xg_s;
Smoothed <float> imu_yg_s;
Smoothed <float> imu_zg_s;

//flex smooths
Smoothed <float> point;
Smoothed <float> m;
Smoothed <float> r;
Smoothed <float> pinky;

//data structure of the sensors
union MultiSensorData
{
  struct __attribute__( ( packed ) )
  {
    float values[NUMBER_OF_SENSORS];
  };
  uint8_t bytes[NUMBER_OF_SENSORS * sizeof( float )];
};

//initilize the data structure
union MultiSensorData multiSensorData;

 // BLE service for this glove
BLEService gloveService("a98662ad-6993-4143-8fa6-4fadfcba0574");

// BLE Characteristics
BLECharacteristic flexSensorChar("82d72018-f4dd-45e2-a3e3-c363a1e14ada",  BLEWrite | BLENotify, sizeof multiSensorData.bytes);
BLEByteCharacteristic buzzerChar("1cc868c0-4703-11ec-81d3-0242ac130003", BLERead | BLEWrite | BLENotify);

void powerLED(float red_light_value, float green_light_value, float blue_light_value);
int byteArrayToInt(const byte data[], int length);

int buzzerCount = 0;
int batteryCount = 0;
void setup() {
  Serial.begin(9600);    // initialize serial communication
  //while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin to indicate when a central is connected
  pinMode(RED, OUTPUT);
  pinMode(BLUE, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(LED_PWR, OUTPUT);
  pinMode(A4, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(2, INPUT);
  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");

    while (1);
  }

  /* Set a local name for the BLE device
     This name will appear in advertising packets
     and can be used by remote devices to identify this BLE device
     The name can be changed but maybe be truncated based on space left in advertisement packet
  */
  BLE.setDeviceName("S.C.R.E.E.N Glove");
  BLE.setLocalName("S.C.R.E.E.N Glove");

  // add the service UUID
  BLE.setAdvertisedService(gloveService); 
  
  //add all of the characteristics to the service
  gloveService.addCharacteristic(flexSensorChar); 
  gloveService.addCharacteristic(buzzerChar);
  buzzerChar.setValue(-1);
  buzzerChar.subscribe();
  //add the service to BLE
  BLE.addService(gloveService); 

  flexSensorChar.writeValue( multiSensorData.bytes, sizeof multiSensorData.bytes );


  //initialize IMU
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }
  
  //init smoothing structures
  imu_xa_s.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);
  imu_ya_s.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);
  imu_za_s.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);

  imu_xg_s.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);
  imu_yg_s.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);
  imu_zg_s.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);

  point.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);
  m.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);
  r.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);
  pinky.begin(SMOOTHED_AVERAGE, SMOOTHING_WINDOW);

  /* Start advertising BLE.  It will start continuously transmitting BLE
     advertising packets and will be visible to remote BLE central devices
     until it receives a new connection */

  // start advertising
  BLE.advertise(); 

  Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {

  if (analogRead(A2) < 775) {
       batteryCount = batteryCount + 1;
      if (batteryCount == 1) {
  
          digitalWrite(RED, LOW);          // will turn the LED on
          digitalWrite(GREEN, HIGH);        // will turn the LED off
          digitalWrite(BLUE, HIGH);         // will turn the LED off
      } else if (batteryCount == 1000) {
  
          digitalWrite(RED, HIGH);          // will turn the LED off
          digitalWrite(GREEN, HIGH);        // will turn the LED off
          digitalWrite(BLUE, HIGH);         // will turn the LED off
          batteryCount = -1000;
      }
    } else {
      batteryCount = 0;
      digitalWrite(RED, HIGH);          // will turn the LED off
      digitalWrite(GREEN, HIGH);        // will turn the LED off
      digitalWrite(BLUE, HIGH);         // will turn the LED off
    }
    //delay(1);
    Serial.println(batteryCount);
    Serial.println(analogRead(A2));
  // wait for a BLE central
  BLEDevice central = BLE.central();

  // if a central is connected to the peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's BT address:
    Serial.println(central.address());
    // turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);

    // get the readings every 200ms
    // while the central is connected:
    while (central.connected()) {
      updateSensorValues();
      
      if (buzzerChar.written()) {
        switch (buzzerChar.value()) {
          case 01:
            Serial.println("Green LED on");
            digitalWrite(RED, HIGH);         // will turn the LED off
            digitalWrite(GREEN, LOW);       // will turn the LED off
            digitalWrite(BLUE, HIGH);         // will turn the LED on
            
//            if (buzzerCount == 0) {
//              digitalWrite(9, HIGH);
//              //buzzerCount = buzzerCount + 1;
//              Serial.println("on");
//            }
//            } else if (buzzerCount == 50) {
//              digitalWrite(2, LOW);
//              buzzerCount = 0;
//            }
            break;
           case 02:
            Serial.println("Green LED on");
            digitalWrite(RED, LOW);         // will turn the LED off
            digitalWrite(GREEN, HIGH);       // will turn the LED off
            digitalWrite(BLUE, HIGH);         // will turn the LED on
            break;
          default:
            Serial.println(F("LEDs off"));
            digitalWrite(RED, HIGH);          // will turn the LED off
            digitalWrite(GREEN, HIGH);        // will turn the LED off
            digitalWrite(BLUE, HIGH);         // will turn the LED off
            break;
        }
      }
    }
    
    // when the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
  }
}

void updateSensorValues() {

  //read the IMU values
  float xa, ya, za; //raw accel values
  float xa_s, ya_s, za_s; //smoothed accel values
  
  float xg, yg, zg; //raw gyro
  float xg_s, yg_s, zg_s; //smooth gyro
  
  if (IMU.accelerationAvailable()) {
    IMU.readAcceleration(xa, ya, za);
    IMU.readGyroscope(xg,yg,zg);
    
    //smooth values
    imu_xa_s.add(xa);
    imu_ya_s.add(ya);
    imu_za_s.add(za);

    imu_xg_s.add(xg);
    imu_yg_s.add(yg);
    imu_zg_s.add(zg);
    
    //smooth accel
    xa_s = imu_xa_s.get();
    ya_s = imu_ya_s.get();
    za_s = imu_za_s.get();

    //smooth gyro
    xg_s = imu_xg_s.get();
    yg_s = imu_yg_s.get();
    zg_s = imu_zg_s.get();
    
    multiSensorData.values[1] = xa_s;
    multiSensorData.values[2] = ya_s;
    multiSensorData.values[3] = za_s;
    multiSensorData.values[4] = xg_s;
    multiSensorData.values[5] = yg_s;
    multiSensorData.values[6] = zg_s;

    //get the flex sensor values map them to the range 0..100
    float pointFlexSensorValue = map(float(analogRead(A7)), 0.0, 1023.0, 0.0, 100.0);
    float middleFlexSensorValue = map(float(analogRead(A6)), 0.0, 1023.0, 0.0, 100.0);
    float ringFlexSensorValue = map(float(analogRead(A5)), 0.0, 1023.0, 0.0, 100.0);
    float pinkieFlexSensorValue = map(float(analogRead(A0)), 0.0, 1023.0, 0.0, 100.0);
//    int thumbflexSensorValue = map(analogRead(A3), 0, 1023, 0, 100);
//    int wristFlexSensorValue = map(analogRead(A2), 0, 1023, 0, 100);

    //make smooth flex
    point.add(pointFlexSensorValue);
    m.add(middleFlexSensorValue);
    r.add(ringFlexSensorValue);
    pinky.add(pinkieFlexSensorValue);

    //get smoothed flex
    pointFlexSensorValue = point.get();
    middleFlexSensorValue = m.get();
    ringFlexSensorValue = r.get();
    pinkieFlexSensorValue = pinky.get();
    
    //add those to the data structure
    multiSensorData.values[0] = pointFlexSensorValue;
    multiSensorData.values[7] = middleFlexSensorValue;
    multiSensorData.values[8] = ringFlexSensorValue;
    multiSensorData.values[9] = pinkieFlexSensorValue;
//    multiSensorData.values[10] = thumbFlexSensorValue;
//    multiSensorData.values[11] = wristFlexSensorValue;


    if (buzzerCount > 0) {
  
      buzzerCount = buzzerCount + 1;
    }
  }
  
  //send sensor values to the app
  flexSensorChar.writeValue(multiSensorData.bytes, sizeof multiSensorData.bytes);           
}

void powerLED(float red_light_value, float green_light_value, float blue_light_value) {
  
  analogWrite(RED, red_light_value);
  analogWrite(GREEN, green_light_value);
  analogWrite(BLUE, blue_light_value);
  delay(1000);
  digitalWrite(RED, 0); 
  digitalWrite(GREEN, 0);
  digitalWrite(BLUE, 0);
}


//union ArrayToInteger {
//  byte array[4];
//  uint32_t integer;
//};
//int byteArrayToInt(const byte data[], int length) {
//  byte dataW[length];
//  for (int i = 0; i < length; i++) {
//       byte b = data[i]; 
//        dataW[i] = data[i];    
//  }
//  ArrayToInteger converter; //Create a converter
//  converter.array[0] = dataW[0];
//  converter.array[1] = dataW[1];
//  converter.array[2] = dataW[2];
//  converter.array[3] = dataW[3];
//  
//  
//   return converter.integer ;
//}
