### Data Manipulation

#### Optical Capture Data

Step 1: who knows.


#### Mechanical Capture Data
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