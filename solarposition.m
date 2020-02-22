%function: solarposition.m
%computes the apparent right ascension and declination of the sun at a given input
%date
%These times are set to not separate by more than .9 second 
%Source: https://eclipse.gsfc.nasa.gov/SEhelp/TimeZone.html)
%
%references: Algorithms from Chapters 25 & 32 of Astronomical
%Algorithms, 2nd Edition, by Jean Meeus
%
%
%inputs:
%year
%month
%day 
%hours
%minutes
%seconds
%calendar: 1 for Gregorian Calendar; 2 for Julian Calendar
%timezone: 0 if UTC; input time difference from UTC
%
%outputs
%righta = apparent right ascension of the sun at the input time, in degrees
%dec = apparent declination of the sun at the input time, in degrees

%updated 2/22/2020

function [righta, dec] = solarposition(year, month, day, hours, minutes, seconds, calendar, timezone)

%check for valid user inputs
numdays=[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];  %number of days in each month
numdaysleap=[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

if mod(year,1) ~= 0
    error("Year should be an integer.")
end
if month > 12 || month < 1 || mod(month,1) ~= 0
    error("Month should be an integer within 1-12.")
end
if day < 1 || mod(day,1) ~= 0
    error("Invalid day input. The day should be a whole number starting with one.")
end
if calendar ~= 1 && calendar ~= 2 %invalid calendar specification
    error("Invalid calendar specification. Input 1 for Gregorian Calendar and 2 for Julian")
end
if isleapyear(year,calendar) == 1 %is a leap year
    if day > numdaysleap(month)
        error("Day exceeds the number of days possible in the input month.")
    end
else  %common day
    if day > numdays(month)
        error("Day exceeds the number of days possible in the input month.")
    end
end
if hours >= 24 || hours < 0 || mod(hours,1) ~= 0
    error("Hour should be a whole number within 0-24, excluding 24.")
end
if minutes >= 60 || minutes < 0 || mod(minutes,1) ~= 0
    error("Minutes should be a whole number within 0-60, excluding 60.")
end
if seconds >= 60 || seconds
    error("Seconds should be within 0-60, excluding 60.")
end

%convert input date to UTC if necessary
if timezone ~= 0
    hours = hours - timezone;
end
%adjust other time parameters if necessary
if hours >= 24
    day = day + 1;
    hours = hours - 24;
elseif hours < 0
    day = day - 1;
    hours = hours + 24;
end
if isleapyear(year,calendar) == 1
    if day > numdaysleap(month)
        day = 1;
        month = month + 1;
    elseif day <= 0
        month = month - 1;
        day = numdaysleap(month);
    end
else
    if day > numdays(month)
        day = 1;
        month = month + 1;
    elseif day <= 0
        month = month - 1;
        day = numdays(month);
    end
end
if month > 12
    month = 1;
    year = year + 1;
elseif month <= 0
    month = 12;
    year = year - 1;
end

%load terms to compute heliocentric longitude, heliocentric latitude, and
%distance between Earth and the Sun
earthLfile = "earthL.txt";
earthL = readtable(earthLfile);
elA = earthL.(1);
elB = earthL.(2);
elC = earthL.(3);
earthRfile = "earthR.txt";
earthR = readtable(earthRfile);
erA = earthR.(1);
erB = earthR.(2);
erC = earthR.(3);
earthBfile = "earthB.txt";
earthB = readtable(earthBfile);
ebA = earthB.(1);
ebB = earthB.(2);
ebC = earthB.(3);

%convert input UTC date into TD
[~,dtyear,dtmonth,dtday,~,dthr,dtmin,dtsec] = todyntimenasa(year,month,day,hours,minutes,seconds,calendar);
jdeday = meeusjulian(dtyear,dtmonth,dtday,dthr,dtmin,dtsec,calendar);  %convert to Julian Ephemeris Days

%compute Julian Ephemeris Millennia from J2000.0
tau = (jdeday - 2451545)/365250;

%compute heliocentric longitude using VSOP87 method described in Chapter 32
%earthL.txt contains all 6 longitude series, L0-L5, with each series
%separated by a negative integer (i.e. L0 and L1 separated by -1, L1 and L2
%by -2, and so on)
idL01 = find(elA == -1);
idL12 = find(elA == -2);
idL23 = find(elA == -3);
idL34 = find(elA == -4);
idL45 = find(elA == -5);
sizeL = size(elA);
sizeL = sizeL(1);

%compute L0 term
l0term = 0;
for i = 1:idL01-1
    term = (elA(i))*cos(elB(i)+tau*elC(i));
    l0term = l0term + term;
end

%compute L1 term
l1term = 0;
for i = idL01+1:idL12-1
    term = (elA(i))*cos(elB(i)+tau*elC(i));
    l1term = l1term + term;
end
l1term = l1term * tau;

%compute L2 term
l2term = 0;
for i = idL12+1:idL23-1
    term = (elA(i))*cos(elB(i)+tau*elC(i));
    l2term = l2term + term;
end
l2term = l2term*tau*tau;

%compute L3 term
l3term = 0;
for i = idL23+1:idL34-1
    term = (elA(i))*cos(elB(i)+tau*elC(i));
    l3term = l3term + term;
end
l3term = l3term*(tau^3);

%compute L4 term
l4term = 0;
for i = idL34+1:idL45-1
    term = (elA(i))*cos(elB(i)+tau*elC(i));
    l4term = l4term + term;
end
l4term = l4term*(tau^4);

%compute L5 term
l5term = 0;
for i = idL45+1:sizeL
    term = (elA(i))*cos(elB(i)+tau*elC(i));
    l5term = l5term + term;
end
l5term = l5term*(tau^5);

%compute heliocentric longitude, in radians, and convert to degrees
heliolon = (l0term + l1term + l2term + l3term + l4term + l5term)/(1e8);
if abs(heliolon*(180/pi)) > 360
    heliolon = mod((heliolon*180)/pi,360);
else
    heliolon = heliolon*(180/pi);
end


%compute heliocentric latitude using a similar algorithm as above (Ch. 32)
idB01 = find(ebA == -1);
sizeB = size(ebA);
sizeB = sizeB(1);

%compute B0 term
b0term = 0;
for i = 1:idB01-1
    term = (ebA(i))*cos(ebB(i)+tau*ebC(i));
    b0term = b0term + term;
end

%compute B1 term
b1term = 0;
for i = idB01+1:sizeB
    term = (ebA(i))*cos(ebB(i)+tau*ebC(i));
    b1term = b1term + term;
end
b1term = b1term*tau;

%compute heliocentric latitude, in radians, and convert to degrees
heliolat = (b0term + b1term)/(1e8);
if abs(heliolat*(180/pi)) > 360
    heliolat = mod((heliolat*180)/pi,360);
else
    heliolat = heliolat*(180/pi);
end


%compute Earth-Sun radius vector using a similar algorithm as above (Ch.
%32)
idR01 = find(erA == -1);
idR12 = find(erA == -2);
idR23 = find(erA == -3);
idR34 = find(erA == -4);
sizeR = size(erA);
sizeR = sizeR(1);

%compute R0 term
r0term = 0;
for i = 1:idR01-1
    term = (erA(i))*cos(erB(i)+tau*erC(i));
    r0term = r0term + term;
end

%compute R1 term
r1term = 0;
for i = idR01+1:idR12-1
    term = (erA(i))*cos(erB(i)+tau*erC(i));
    r1term = r1term + term;
end
r1term = r1term*tau;

%compute R2 term
r2term = 0;
for i = idR12+1:idR23-1
    term = (erA(i))*cos(erB(i)+tau*erC(i));
    r2term = r2term + term;
end
r2term = r2term*tau*tau;

%compute R3 term
r3term = 0;
for i = idR23+1:idR34-1
    term = (erA(i))*cos(erB(i)+tau*erC(i));
    r3term = r3term + term;
end
r3term = r3term*(tau^3);

%compute R4 term
r4term = 0;
for i = idR34+1:sizeR
    term = (erA(i))*cos(erB(i)+tau*erC(i));
    r4term = r4term + term;
end
r4term = r4term*(tau^4);

%compute earth-sun radius vector, in radians
earthsun = (r0term + r1term + r2term + r3term + r4term)/(1e8);


%convert to geocentric longitude and latitude
geolon = heliolon + 180;
geolat = heliolat * -1;

%convert geocentric longitude and latitude of the sun to FK5 (Ch. 25)
%and compute the corrections to geocentric lon & lat
geolonprime = geolon - (1.397*10*tau) - (.00031*(10*tau)^2);
loncorr = -.09033/3600;
latcorr = (.03916/3600)*(cosd(geolonprime) - sind(geolonprime));
geolon = geolon + loncorr;
geolat = geolat + latcorr;


%compute nutation and aberration corrections, in degrees
abcorr = -20.4898/(3600*earthsun);  %aberration correction

%compute nutations in longitude and obliquity, and obliquity
%and correct for longitude
[deltalon, ~, obliquity] = nutations_comp(jdeday);  
applon = geolon + deltalon + abcorr;  %apparent longitude of the sun

%compute right ascension and declination (Ch. 13 Meeus)
num_righta = sind(applon)*cosd(obliquity)-tand(geolat)*sind(obliquity);
denom_righta = cosd(applon);
if denom_righta == 0 && num_righta > 0
    righta = 90;
elseif denom_righta == 0 && num_righta < 0
    righta = 270;
elseif denom_righta > 0 && num_righta == 0
    righta = 0;
elseif denom_righta < 0 && num_righta == 0
    righta = 180;
elseif denom_righta > 0 && num_righta < 0
    righta = atand(num_righta/denom_righta) + 360;
elseif denom_righta < 0 && num_righta < 0
    righta = atand(num_righta/denom_righta) + 180;
elseif denom_righta < 0 && num_righta > 0
    righta = atand(num_righta/denom_righta) + 180;
else
    righta = atand(num_righta/denom_righta);
end

dec = sind(geolat)*cosd(obliquity)+cosd(geolat)*sind(obliquity)*sind(applon);
dec = asind(dec);

end

