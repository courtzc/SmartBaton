# Data Analysis
Now that we've made a template 'source of truth', we can compare datasets to it and see what we come up with.

## Method
Registration is the method of moving (and sometimes warping) one point cloud to be on top of another. Since the aspect ratio of conducting is important, we need to use **rigid registration** instead of normal registration. Since the size of the conducting isn't as important for technique, we can use scaling to give us the best chance of overlapping.

This code gets us a great match. I haven't checked if it works on things with different numbers of points or different starting places, but I think pctransform() is pretty powerful!

'fixed' is the reference dataset `C:\Users\Courtney\source\repos\ThesisProject\Data\Session01_ManipulatedData\SavedCycles_Resampled\Session01_ExpA1_All_Resampled_Average.mat`.
'moving' is whatever dataset you're comparing to the reference.
```
% get in data
moving = tXYZ(:,2:4);
fixed = tXYZ_Average(:,2:4);

% Perform rigid registration comparison on those 3D arrays
tform = pcregistericp(pointCloud(moving),pointCloud(fixed));

% Scale the 'moving' points to the size of the 'fixed' points
scaleFactor = mean(sqrt(sum(fixed.^2,2))) / mean(sqrt(sum(moving.^2,2)));
moving = moving * scaleFactor;

% transform the 'moving' points
movingReg = pctransform(pointCloud(moving),tform);
movingRegScaled = movingReg.Location * scaleFactor;
```

We then visualise by plotting the reference (fixed) and the dataset (moving) on top of eachother (you can split this by beats, but we need to make sure we get beat 1 in the right place i.e. the top)

Then we can do a normal point to point distance (this is where we need the resampling to be around)
`dists = vecnorm(fixed - movingRegScaled, 2, 2);`

And then can plot it below!