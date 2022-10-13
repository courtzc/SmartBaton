# %matplotlib notebook
import matplotlib.pyplot as plt
import numpy as np
from celluloid import Camera # getting the camera
import matplotlib.animation as animation
from IPython import display
import time
from IPython.display import HTML
from matplotlib.animation import FuncAnimation

import warnings
# %matplotlib notebook
warnings.filterwarnings('ignore')
warnings.simplefilter('ignore')

fig, ax = plt.subplots()

ax.set_xlim([-100, 100])
ax.set_ylim([-100, 100])
x = []
y = []

if(len(x) > 20):
    line, = ax.plot(x[-20:], y[-20:])
else:
    line, = ax.plot(x, y)

### import the arduino stream
import serial

serial_port = '/dev/ttyACM0';
baud_rate = 9600; #In arduino, Serial.begin(baud_rate)
write_to_file_path = "output.txt";

output_file = open(write_to_file_path, "w+");
ser = serial.Serial('COM10', baud_rate)
###


def animate(i):
    # read in line from accelerometer
    serialline = ser.readline();
    serialline = serialline.decode("utf-8") #ser.readline returns a binary, convert to string
    
    # split into x, y, z array
    xyz = serialline.split(",")
    print(serialline);
    
    x.append(float(xyz[0]))
    y.append(float(xyz[1]))
    
    
    line.set_data(x, y)

    return line,



ani = animation.FuncAnimation(
    fig, animate, interval=20, blit=True, save_count=50)

# To save the animation, use e.g.
#
# ani.save("movie.mp4")
#
# or
#
# writer = animation.FFMpegWriter(
#     fps=15, metadata=dict(artist='Me'), bitrate=1800)
# ani.save("movie.mp4", writer=writer)

plt.show()