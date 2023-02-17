DistanceCheckingVariable = pointDistances
top_500 = maxk(pointDistances, 500)
bottom_500 = mink(pointDistances, 500)

figure
plot(top_500)
figure
plot(bottom_500)