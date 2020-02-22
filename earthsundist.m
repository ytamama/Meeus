%earthsundist.m
%computes the distance between the Earth and Sun at any given date,
%inputted as UTC

%inputs:
%year
%month
%day
%hours
%minutes
%seconds
%calendar: 1 for Gregorian; 2 for Julian

%output
%es_dist: distance from Earth to Sun at that time, in AU

%references: Algorithms from Chapter 32 of Astronomical
%Algorithms, 2nd Edition, by Jean Meeus

%updated 2-22-2020

function es_dist = earthsundist(year,month,day,hours,minutes,seconds,calendar)

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


%convert input date into TD 
[~,dtyear,dtmonth,dtday,~,dthr,dtmin,dtsec] = todyntimenasa(year, month, day, hours, minutes, seconds, calendar);
jdeday = meeusjulian(dtyear,dtmonth,dtday,dthr,dtmin,dtsec,calendar);  %convert to Julian Ephemeris Days


%compute Julian Ephemeris Millennia from J2000.0
tau = (jdeday - 2451545)/365250;


%load file to compute distance from Earth to Sun
earthRfile = "earthR.txt";
earthR = readtable(earthRfile);
erA = earthR.(1);
erB = earthR.(2);
erC = earthR.(3);


%compute earth-sun distance using algorithms described in Chapter 32
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

%compute earth-sun radius vector, in AU
es_dist = (r0term + r1term + r2term + r3term + r4term)/(1e8);


end