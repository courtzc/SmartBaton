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
only one program can read the serial port at a time. 
If going to matlab, close the serial monitor in arduino IDE if attempting to access it elsewhere, and vice versa.
If going to arduino, run `fclose(instrfindall);` and `delete(instrfindall);` to close and remove the port in matlab.
    if the ports are already closed, doing this in matlab will give an error. you can just proceed normally if that happens.

## Matlab
This only works when reading in the serial output of arduino code. 

Upload the sketch `Read_IMU.ino` to the arduino. (you're going to want to change this to data friendly output)

run Read_IMU.m on the computer. note: instrfindall will be discontinued soon.

# Plotting
## Input data (serial output)
each reading needs to end up in this format: 
`00544.43 -00259.77 -00820.31; 00000.85 00006.11 00004.44; -00032.55 00044.10 00070.20`

which can be achieved by this code in arduino loop:

```
printFormattedFloat(sensor->accX(), 5, 2);
SERIAL_PORT.print(" ");
printFormattedFloat(sensor->accY(), 5, 2);
SERIAL_PORT.print(" ");
printFormattedFloat(sensor->accZ(), 5, 2);
SERIAL_PORT.print("; ");
printFormattedFloat(sensor->gyrX(), 5, 2);
SERIAL_PORT.print(" ");
printFormattedFloat(sensor->gyrY(), 5, 2);
SERIAL_PORT.print(" ");
printFormattedFloat(sensor->gyrZ(), 5, 2);
SERIAL_PORT.print("; ");
printFormattedFloat(sensor->magX(), 5, 2);
SERIAL_PORT.print(" ");
printFormattedFloat(sensor->magY(), 5, 2);
SERIAL_PORT.print(" ");
printFormattedFloat(sensor->magZ(), 5, 2);
SERIAL_PORT.println();
```

I'm sure we can play around with the padding later. matlab strips it anyway.

The matlab code in read_imu then uses str2num to turn it into a 3x3 array

```
out = fscanf(s);
out_array = str2num(out);
```

## getting plot vectors 
we're reading it in as a 3D matrix, where each 'page' (3rd dimension) is a 3x3 matrix of the values. the matrix looks like this:
```
IMU_Data (:,:,i) = [accX, accY, accZ;
                    gyrX, gyrY, gyrZ;
                    magX, magY, magZ]
```
and then goes back however many rows for however many readings we take.

When plotting, we want to get all the accX values, etc etc. to do this, we can take
IMU_Data (1,1,:) for accX values. However, matlab still treats this as a 3D array which won't work. add `squeeze(IMU_Data(1,1,:))` to get the accX values in a 1D array.   


# Leap Setup

Download tracking software: https://developer.leapmotion.com/
The leap sdk downloads in ProgramFiles when you download the Windows latest leap.

Go to `C:\Program Files\Ultraleap\ControlPanel\UnityApp` and open `Ultraleap Control Panel.exe` to see the UI interface.


for code:
make an empty C++ project
add a .c file (you won't be able to do the next step til you do)

do this twice, once for debug and once for release:
follow these instructions (https://developer-archive.leapmotion.com/documentation/cpp/devguide/Project_Setup.html) to
- add the SDK include folder `C:\Program Files\Ultraleap\LeapSDK\include`
- add the lib x64 folder `C:\Program Files\Ultraleap\LeapSDK\lib\x64`
- (this isn't working) add a post build event command line `xcopy /yr "C:\Program Files\Ultraleap\LeapSDK\lib\x64\Leap.dll" "$(TargetDir)"` > try replacing `"$(TargetDir)"` with `"$(ProjectDir)\bin\Release"`
- add `"C:\Program Files\Ultraleap\LeapSDK\lib\x64\LeapC.lib";` to Linker > Input > Additional Dependencies

xcopy /yr "C:\Program Files\Ultraleap\LeapSDK\lib\x64\Leap.dll" 