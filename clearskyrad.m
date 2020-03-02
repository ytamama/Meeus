%clearskyrad.m
%rough approximation of the amount of solar radiation that strikes a 
%location on Earth's surface on a clear day

%Inputs
%etrad = extraterrestrial radiation of that location 
%elev = elevation of location above sea level, in meters

%Outputs
%clearsky = estimate of clear sky radiation

%references:
%Chapter 3 of FAO Irrigation and Drainage Paper, No. 56, Crop 
%Evapotranspiration by Richard G. Allen et al., 1998

%Updated 03/02/2020

function clearsky = clearskyrad(etrad, elev) 

a_coeff = .75;
b_coeff = 2*10^-5;

clearsky = (a_coeff + (b_coeff*elev))*etrad;

end


