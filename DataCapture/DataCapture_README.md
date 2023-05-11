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


## Software

### Arduino IDE
follow this guide: https://www.instructables.com/Arduino-WeMos-D1-WiFi-UNO-ESP-8266-IoT-IDE-Compati/ which is essentially
- download arduino IDE. 
- add this board manager: http://arduino.esp8266.com/stable/package_esp8266com_index.json
- download the sparkfun 9DOF library https://github.com/sparkfun/SparkFun_ICM-20948_ArduinoLibrary

(not required) Run WiFiConfigurationArduino.ino to set up wifi connection on the device.

Upload the sketch `Read_IMU.ino` to the arduino.

#### Input data (serial output)
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


#### troubleshooting
only one program can read the serial port at a time. 
If going to matlab, close the serial monitor in arduino IDE if attempting to access it elsewhere, and vice versa.
If going to arduino, run `fclose(instrfindall);` and `delete(instrfindall);` to close and remove the port in matlab.
    if the ports are already closed, doing this in matlab will give an error. you can just proceed normally if that happens.

### Matlab
This  works by reading in the serial output of arduino code. 
run Read_IMU.m (or whatever script we're using now) on the computer. note: instrfindall will be discontinued soon.

#### Reading in the IMU
The matlab code in read_imu then uses str2num to turn it into a 3x3 array

```
out = fscanf(s);
out_array = str2num(out);
```

#### getting plot vectors 
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
## One time Setup
Download ORION (that's the compatible sdk with this leap device) from `https://developer.leapmotion.com/releases/leap-motion-orion-410-99fe5-crpgl`. Unzip `LeapDeveloperKit_4.1.0+52211_win.zip` and install `Leap_Motion_Installer_v4-2020-release-updates_public_win_x64_4.1.0+52211_ah1889.exe`. You should then see a thing in the icons on your taskbar called "Leap Motion Controller", and if you right click you can open the Visualiser to see everything that's happening.

clone the git repo `https://github.com/tomh4/matleap` (but unlink the repo, so basically copy the files) into DataCapture. follow the instructions in that README, and:  
- copy **LeapSDK** folder from the orion download into the matleap folder
- **COPY `LeapC.dll` INTO THE MATLEAP DIRECTORY**!!
- you should be able to then run the other stuff.

## Every time setup
In matlab, run  `mex -setup C++`
    ```
    >> mex -setup
    MEX configured to use 'Microsoft Visual C++ 2022 (C)' for C language compilation.

    To choose a different language, select one from the following:
    mex -setup C++ % click this one
    mex -setup FORTRAN
    MEX configured to use 'Microsoft Visual C++ 2022' for C++ language compilation.
    ```


# Data Capture
## Orientation data (IMU)
There needs to be a calibration rotation matrix, which will divide through everything else. rotm0 - you can make it the rotm that comes out of the first quarternion. In order to get a good transform, your axes need to be aligned, so your first rotm should be taken when your imu is pointing straight up (and leap axes and imu axes are aligned, see picture on 17/03/23).

The sample rate of the IMU is very important. your FUSE = imufilter() needs to have an argument with the sample rate, and it needs to be exactly what your reading speed is. If it isn't, the data will be wildly wrong. this still isn't perfect on 17/03. #TOCHANGE please fix this.

UPDATE this is mostly done
    the sample rate won't be fixed until we fix our little friend drawnow. The overall loop is taking a lot longer than the sample rate or fps (we're trying at a delay of 20ms so 50Hz), so things aren't working out. we need our loop to be well below 20ms so that we can start it again at exactly after. see `Read_IMU_and_leap_times_tictoc_240323.jpg` for an example of what I mean. Apparently updating the data using set(), rather than calling plot() each time, will drastically reduce this. https://stackoverflow.com/questions/50093938/how-to-speed-up-a-very-slow-animated-plot-in-matlab. 


In the meantime, I've put a very slow sample rate (delay 200 in ardunio) and loop time (each loop taking 200ms), so at least I'm getting exactly what I'm asking for.

Suspiciously, bring the loop duration down to 20ms, but leaving high delay in arduino and 5000 in the imufilter sample rate is getting me very good data. hmmm.

## Fused Capture Data
use Read_IMU_And_LeapDevice  to get in both elements of data.

I am transforming the baton tip (add the leap translation) assuming axes are lined up?: x y z -> x y z
i think they are (for right hands found in leap), based on: 
this pic https://littlebirdelectronics.com.au/products/9-axis-compass-module-cjmcu-mpu9150
and this pic https://developer.unigine.com/en/docs/latest/code/plugins/leapmotion/?rlang=cpp
so the baton tip is:
    transformed_baton_tip_pos = [baton_tip_pos(1) + palm_pos(1); baton_tip_pos(2) + palm_pos(2); baton_tip_pos(3) + palm_pos(3)];