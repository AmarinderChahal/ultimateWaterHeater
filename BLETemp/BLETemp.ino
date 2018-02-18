#include <OneWire.h>
#include <DallasTemperature.h>
#include <CurieBLE.h>

const int ledPin = 13;
 
// Data wire is plugged into pin 2 on the Arduino
#define ONE_WIRE_BUS 2
 
// Setup a oneWire instance to communicate with any OneWire devices 
// (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
 
// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);

BLEService tempService("19B10010-E8F2-537E-4F6C-D104768A1214"); // create service
BLECharCharacteristic ledCharacteristic("19B10011-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);
BLECharCharacteristic tempCharacteristic("19B10012-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify);
 
void setup(void)
{
  // start serial port
  Serial.begin(9600);
  Serial.println("Temperature BT Comm");

  // Start up the library
  sensors.begin();

  // Do bt
  BLE.begin();
  BLE.setLocalName("BtnLED");
  BLE.setAdvertisedService(tempService);
  tempService.addCharacteristic(ledCharacteristic);
  tempService.addCharacteristic(tempCharacteristic);

  BLE.addService(tempService);
  ledCharacteristic.setValue(0);
  tempCharacteristic.setValue(0);
  BLE.advertise();
}
 
int counter = 0;
float alttemp = 71.6;
int tempVer = 1;

void loop(void)
{
  BLE.poll();
  // call sensors.requestTemperatures() to issue a global temperature
  // request to all devices on the bus
  if(tempVer)getTemps();
  else alternateTemp();
  //Serial.println(temp);

  int data = -1;
  while(Serial.available() > 0){
    int c = Serial.read();
    Serial.println(c);
    if(c=='\n'){
      break;
    }
    data = c;
  }

  if (data=='3') {
    // setting 3 means normal temp mode
    tempVer = 1;
  } else if (data=='2') {
    // setting 2 means manual temp mode
    tempVer = 0;
  } else if (data=='1') {
    //setting 1 means heating up
    ledCharacteristic.setValue(data-48);
    digitalWrite(ledPin, HIGH);
  } else if (data=='0') {
    //setting 0 means cooling off
    ledCharacteristic.setValue(data-48);
    digitalWrite(ledPin, LOW);
  }
  
  delay(1);
}

void getTemps(void){
  counter++;
  if(counter<1000)return;
  counter = 0;
  sensors.requestTemperatures(); // Send the command to get temperatures
  //Serial.print(sensors.getTempCByIndex(0));
  //Serial.print(" ");
  alttemp = sensors.getTempFByIndex(0);
  Serial.println(alttemp);
  uint8_t temp = (uint8_t) alttemp;
  tempCharacteristic.setValue(temp);
}

void alternateTemp(void){
  counter++;
  if(counter<1000)return;
  counter = 0;
  if(alttemp<76.5 && ledCharacteristic.value())alttemp+=.01;
  //else if(alttemp>71.1 && !ledCharacteristic.value())alttemp-=.05;
  Serial.println(alttemp);
  tempCharacteristic.setValue((uint8_t) alttemp);
}



