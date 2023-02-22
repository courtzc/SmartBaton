import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation
from matplotlib.colors import LinearSegmentedColormap

import serial

serial_port = '/dev/ttyACM0';
baud_rate = 9600; #In arduino, Serial.begin(baud_rate)
write_to_file_path = "output.txt";

output_file = open(write_to_file_path, "w+");
ser = serial.Serial('COM10', baud_rate)


fig, ax = plt.subplots()
ax.set_xlabel('X Axis', size = 12)
ax.set_ylabel('Y Axis', size = 12)
ax.axis([-100,100,-100,100])
x_vals = []
y_vals = []
intensity = []
iterations = 1000

t_vals = np.linspace(0,1, iterations)

colors = [[0,0,1,0],[0,0,1,0.5],[0,0.2,0.4,1]]
cmap = LinearSegmentedColormap.from_list("", colors)
scatter = ax.scatter(x_vals,y_vals, c=[], cmap=cmap, vmin=0,vmax=1)
# ax.plot(x_vals,y_vals)
# line = ax.plot(x_vals,y_vals, c=[], cmap=cmap, vmin=0,vmax=1)

def get_new_vals():
    
    xtemp = []
    ytemp = []
    
    for i in range(1, 5):
        
        serialline = ser.readline();
        serialline = serialline.decode("utf-8") #ser.readline returns a binary, convert to string
        xyz = serialline.split(",")
        xtemp.append(float(xyz[0]))
        ytemp.append(float(xyz[1]))
    
    # split into x, y, z array
    
    return list(xtemp), list(ytemp)
    


def update(t):
    global x_vals, y_vals, intensity
    # Get intermediate points
    new_xvals, new_yvals = get_new_vals()
    x_vals.extend(new_xvals)
    y_vals.extend(new_yvals)

    # Put new values in your plot
    scatter.set_offsets(np.c_[x_vals,y_vals])
    # line.set_offsets(np.c_[x_vals,y_vals])

    #calculate new color values
    intensity = np.concatenate((np.array(intensity)*0.96, np.ones(len(new_xvals))))
    scatter.set_array(intensity)
    # line.set_array(intensity)

    # Set title
    ax.set_title('Time: %0.3f' %t)

ani = matplotlib.animation.FuncAnimation(fig, update, frames=t_vals,interval=10)

plt.show()