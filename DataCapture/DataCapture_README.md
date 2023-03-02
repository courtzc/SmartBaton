# IMU setup
## Hardware
If given the CJMCU-20948, you need to solder the pins to the pins to the board.

## Connecting to arduino
you need 4 wires from the IMU to the arduino. 

#### IMU -> Arduino
VCC     -> 3.3V
GND     -> GND
SCLK    -> D15/SCL (on D1, just look for SCL pin)
SDI     -> D14/SDA (on D1, just look for SDA pin)

note: SDI is SDA on the other side of the IMU. same for SCL and SCLK. Idk why they're like that.


# Computer setup

## Arduino IDE
follow this guide: https://www.instructables.com/Arduino-WeMos-D1-WiFi-UNO-ESP-8266-IoT-IDE-Compati/ which is essentially
- download arduino IDE. 
- add this board manager: http://arduino.esp8266.com/stable/package_esp8266com_index.json
- download the sparkfun 9DOF library https://github.com/sparkfun/SparkFun_ICM-20948_ArduinoLibrary

(not required) Run WiFiConfigurationArduino.ino to set up wifi connection on the device.

### troubleshooting
only one program can read the serial port at a time. try closing the serial monitor in arduino IDE if attempting to access it elsewhere, and vice versa.

## Matlab
This only works when reading in the serial output of arduino code. 

Upload the sketch `Read_IMU.ino` to the arduino. (you're going to want to change this to data friendly output)

run Read_IMU.m on the computer. Notes: doesn't plot the right stuff yet. instrfindall will be discontinued soon.