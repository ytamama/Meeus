%dyntoutcnasa
%computes the equivalent universal time (UT) from an input dynamical time (TD)

%references: algorithms from https://eclipse.gsfc.nasa.gov/SEcat5/deltatpoly.html,
%which cite Espenak and Meeus (Five Millennium Canon of Lunar Eclipses: 
%-1999 to +3000); and Chapter 10 (pp. 77-80) of Astronomical
%Algorithms, 2nd Edition, by Jean Meeus

%inputs:
%dtyear: year in TD
%dtmonth
%dtday
%dthr
%dtmin
%dtsec
%calendar: 1 if Gregorian Calendar; 2 if Julian Calendar

%outputs:
%deltat: time difference between universal and dynamical time, in seconds
%year 
%month
%day
%decday: decimal day 
%hours
%minutes
%seconds

%Note: Universal Time will be approximated by Coordinated Universal Time,
%as these times are set to not separate by more than .9 second 
%Source: https://eclipse.gsfc.nasa.gov/SEhelp/TimeZone.html

%updated 2-23-2020

function [deltat, year, month, day, decday, hours, minutes, seconds] = dyntoutcnasa(dtyear, dtmonth, dtday, dthr, dtmin, dtsec, calendar)

%check for valid user inputs
numdays=[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];  %number of days in each month
numdaysleap=[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

if mod(dtyear,1) ~= 0
    error("Year should be an integer.")
end
if dtmonth > 12 || dtmonth < 1 || mod(dtmonth,1) ~= 0
    error("Month should be an integer within 1-12.")
end
if dtday < 1 || mod(dtday,1) ~= 0
    error("Invalid day input. The day should be a whole number starting with one.")
end
if calendar ~= 1 && calendar ~= 2 %invalid calendar specification
    error("Invalid calendar specification. Input 1 for Gregorian Calendar and 2 for Julian")
end
if isleapyear(dtyear,calendar) == 1 %is a leap year
    if dtday > numdaysleap(dtmonth)
        error("Day exceeds the number of days possible in the input month.")
    end
else  %common day
    if dtday > numdays(dtmonth)
        error("Day exceeds the number of days possible in the input month.")
    end
end
if dthr >= 24 || dthr < 0 || mod(dthr,1) ~= 0
    error("Hour should be a whole number within 0-24, excluding 24.")
end
if dtmin >= 60 || dtmin < 0 || mod(dtmin,1) ~= 0
    error("Minutes should be a whole number within 0-60, excluding 60.")
end
if dtsec >= 60
    error("Seconds should be within 0-60, excluding 60.")
end



%compute deltat (in seconds) and UTC
deltat = compdeltatnasa(dtyear, dtmonth);
deltatday = deltat/(3600*24); %convert deltat to decimal days
tdjday = meeusjulian(dtyear,dtmonth,dtday,dthr,dtmin,dtsec,calendar); %convert input to julian date
utcjday = tdjday - deltatday;  %derive julian day in UTC
[year,month,day,decday,hours,minutes,seconds] = juliantodate(utcjday); %convert into calendar date in UTC

end

