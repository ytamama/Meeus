%function: interpolate()
%interpolates three values and outputs the result of the interpolation

%input:
%val1, val2, val3: 3 different values to be interpolated
%ip_factor: interpolation factor 

%output:
%val_ip: value as a result of the interpolation

%reference:
%Chapter 3 of Astronomical Algorithms, 2nd Edition, by Jean Meeus

%updated 2/21/2020

function val_ip = interpolate(val1,val2,val3,ip_factor)
%algorithms given in pages 23-24 of Astronomical Algorithms

a_val = val2 - val1;
b_val = val3 - val2;
c_val = b_val - a_val;
val_ip = val2 + (ip_factor/2)*(a_val + b_val + ip_factor*c_val);


end