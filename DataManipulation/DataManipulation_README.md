# Data Manipulation

## OptiTrack Data - Raw to CSV
Essentially we get the centroid tracking data and save it in its own csv, as just numbers.

### Saving the Raw Data

Import the session files into 4 folders (motive takes, tracking data, screen capture, lab video)

Rename them all with the session number:

Powershell cd to directory and run:

`Get-ChildItem -Exclude "Session01\_\*"| rename-item -NewName { "Session01\_"+ $\_.Name }`
Get-ChildItem -Exclude "Session02\_\*" | rename-item -NewName { "Session02_"+ $_.Name }

Get-ChildItem D:\OneDrive\Documents\trackingdatarename -File | Rename-Item -NewName { "Session02_" + $_.Name }

_From \<_[_https://stackoverflow.com/questions/20874915/rename-multiple-files-in-a-folder-add-a-prefix-windows_](https://stackoverflow.com/questions/20874915/rename-multiple-files-in-a-folder-add-a-prefix-windows)_\>_



### Extracting the Useful Data

#### Get the centroid 3x? array

Copy the raw tracking data csvs into new folder

In bash, cd to directory.

Run this script. It does 4 things:
1. moves the raw files to a sub directory
2. extracts columns B, G, H, and I from each raw file
3. removes any lines that have a blank or lack data
4. removes the first 6 lines

```
mkdir Raw

for file in \*.csv

do
    mv ${file} Raw
done


mkdir CutColumns

for file in Raw/*.csv
do
    echo "$file"
    t=$(echo "$file" | sed 's/.*\///; s/.csv//')
    cut -f 2,7-9 -d ',' "$file" > "CutColumns/${t}_BBaton.csv"
done

mkdir BHand

for file in Raw/*.csv
do
    echo "$file"
    t=$(echo "$file" | sed 's/.*\///; s/.csv//')
    cut -f 2,31-33 -d ',' "$file" > "CutColumns/${t}_BHand.csv"
done


mkdir BlanksRemoved

for file in CutColumns/*.csv
do
    t=$(eval "echo \"$file\" | sed 's/.*\///; s/.csv//'")
    cat "$file" | sed -e '/,,/d' -e '/^,/d' -e '/,$/d' > "BlanksRemoved/${t}_BlanksRemoved.csv"
done


for file in BlanksRemoved/*.csv
do
    t=$(echo "$file" | sed 's/.*\///; s/.csv//')
    echo $file
    cat ${file} | sed '1,7d' ${file} > "${t}_SimpleCentroid.csv"
done


```


rm -rf Raw
rm -rf BGHI
rm -rf BlanksRemoved


how to get the rows of all 0 out (move them into a new folder i.e. rawZero):
for file in rawZero/*.csv
do
    t=$(eval "echo \"$file\" | sed 's/.*\///; s/.csv//'")
    sed -e '/^[0,]*$/d' "$file" > "${t}.csv"
done


## OptiTrack Data - CSV to single cycle (time split) resampled

### csv to mat
use `csvToMat.m` and point it to whatever file pattern you want.

### cycles (time split)
use `IndividualPathCyclesTimeThreshold.m` and point it to whatever file pattern you want.



## Leap Optical Data

get_leap_data pulls frames from the Leap Device and extracts the hand data from that. not sure yet how to differentiate between a right and left hand, or makke sure you're sticking with the same one. maybe when a seocnd hand enters the struct, we choose whichever is closest to the single hand in the previous frame.




## Mechanical Data

Required MATLAB toolboxes:
- Robotics System Toolbox
- Navigation Toolbox
- Sensor Fusion and Tracking Toolbox

Given the accelerometer and gyroscope readings (should we add the mag readings?) we can get an orientation quarternion for the IMU.
this is done by using the imufilter functionality in matlab. The maths exists.

Once we have an orientation quarternion, we can use that to find the 'baton tip' pose, assuming the IMU to be the base of the baton.
The baton base is essentially a spherical wrist link, in that it has 3 degrees of rotation (x, y, and z). The baton itself can be thought of as a one link robot. Forward kinematics can be used to find the pose of the 'next link' (in this case, the baton tip).

To find the pose of the baton tip, we can apply a homogeneous transform 3 times. the parameters of those tables are like this:
----------------------------------
 i | theta_i | d_i | a_i | alpha_i
----------------------------------
 1 |    xx   |  0  |  0  |  -90
----------------------------------
 2 |    xx   |  0  |  0  |   90
----------------------------------
 3 |    xx   |  d1 |  0  |   0
----------------------------------

where theta is the current rotation about that axis (x, y, and z).

The application gives us a 4x4 homogeneous matrix, where the resulting pose is the last column.

Note that this is just the position of the tip based on the *orientation* of the baton base. All calculation so far have been done assuming a translational base of [0,0,0]. It should be pretty simple to fuse in the translational data, and just have that as the starting point of the transformations.