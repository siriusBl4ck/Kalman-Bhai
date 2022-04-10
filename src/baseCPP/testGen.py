# script to generate data files for the least squares assignment
from pylab import *
import scipy.special as sp
N=101                           # no of data points
k=9                             # no of sets of data with varying noise

# generate the data points and add noise
t = linspace(0,10,N)              # t vector
y = 10 * t + 2      # f(t) vector
n = 2*randn(N)
yy = y + n                          # add noise to signal

# shadow plot
plot(t,yy)
xlabel(r'$t$',size=20)
ylabel(r'$f(t)+n$',size=20)
title(r'Plot of the data to be fitted')
grid(True)
savetxt("measurements.dat",yy) # write out matrix to file
show()