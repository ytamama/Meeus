%function: compdeltatnasa.m
%computes deltat, the difference between Universal Time (UT, approximated
%with Coordinated Universal Time (UTC)) and Dynamical Time (TD))
%in seconds

%inputs:
%year
%month

%output:
%deltat, in seconds

%references: algorithms from https://eclipse.gsfc.nasa.gov/SEcat5/deltatpoly.html,
%which cite Espenak and Meeus (Five Millennium Canon of Lunar Eclipses: 
%-1999 to +3000)

%updated 2-21-2020

function deltat = compdeltatnasa(year, month) 

%check for valid user inputs
if mod(year,1) ~= 0
    error("Year should be an integer.")
end
if month > 12 || month < 1 || mod(month,1) ~= 0
    error("Month should be an integer within 1-12.")
end

%compute decimal year, specified for these algorithms
decy = year + (month - .5)/12;

%compute deltat (in seconds) and dynamical time
if year < -500
    decu = (decy - 1820)/100;
    deltat = -20 + 32*decu*decu;
elseif year >= 500 && year < 500
    decu = decy/100;
    deltat = 10583.6 - 1014.41*decu + 33.78311*decu*decu - 5.952053*(decu^3) - .1798452*(decu^4) + .022174192*(decu^5) + .0090316521*(decu^6);
elseif year >= 500 && year < 1600
    decu = (decy-1000)/100;
    deltat = 1574.2 - 556.01*decu + 71.23472*decu*decu + .319718*(decu^3) - .8503463*(decu^4) - .005050998*(decu^5) + .0083572073*(decu^6);
elseif year >= 1600 && year < 1700
    dect = decy - 1600;
    deltat = 120 - .9808*dect - .01532*dect*dect + ((dect^3) / 7129);
elseif year >= 1700 && year < 1800
    dect = decy - 1700;
    deltat = 8.83 + .1603*dect - .0059285*dect*dect + .00013336*(dect^3) - ((dect^4)/1174000);
elseif year >= 1800 && year < 1860
    dect = decy - 1800;
    deltat = 13.72 - .332447*dect + .0068612*dect*dect + .0041116*(dect^3) - .00037436*(dect^4) + .0000121272*(dect^5) - (1.699e-7)*(dect^6) + (8.75e-10)*(dect^7);
elseif year >= 1860 && year < 1900
    dect = decy - 1860;
    deltat = 7.62 + .5737*dect - .251754*dect*dect + .01680668*(dect^3) - .0004473624*(dect^4) + ((dect^5)/233174);
elseif year >= 1900 && year < 1920
    dect = decy - 1900;
    deltat = -2.79 + 1.494119*dect - .0598939*dect*dect + .0061966*(dect^3) - .000197*(dect^4);
elseif year >= 1920 && year < 1941
    dect = decy - 1920;
    deltat = 21.2 + .84493*dect - .0761*dect*dect + .0020936*(dect^3); 
elseif year >= 1941 && year < 1961
    dect = decy - 1950;
    deltat = 29.07 + .407*dect - (dect*dect)/233 + (dect^3)/2547;
elseif year >= 1961 && year < 1986
    dect = decy - 1975;
    deltat = 45.45 + 1.067*dect - (dect*dect)/260 - (dect^3)/718;
elseif year >= 1986 && year < 2005
    dect = decy - 2000;
    deltat = 63.86 + .3345*dect - .060374*(dect*dect) + .0017275*(dect^3) + .000651814*(dect^4) + (2.373599e-5)*(dect^5);
elseif year >= 2005 && year < 2050
    dect = decy - 2000;
    deltat = 62.92 + .32217*dect + .005589*dect*dect;
elseif year > 2050 && year < 2150
    deltat = -20 + 32*(((decy - 1820)/100)^2) - .5628*(2150-decy);
else  %after year 2150
    decu = (decy-1820)/100;
    deltat = -20 + 32*(decu^2);
end

end



