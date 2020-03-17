%function: todyntimenasa.m
%computes the corresponding dynamical time of an input universal time, as
%well as the time difference between those two times
%
%references: algorithms from https://eclipse.gsfc.nasa.gov/SEcat5/deltatpoly.html,
%which cite Espenak and Meeus (Five Millennium Canon of Lunar Eclipses: 
%-1999 to +3000); and Chapter 10 (pp. 77-80) of Astronomical
%Algorithms, 2nd Edition, by Jean Meeus
%
%inputs:
%year 
%month
%day
%hours
%minutes
%seconds
%calendar: 1 if Gregorian Calendar; 2 if Julian Calendar
%
%outputs:
%deltat: time difference between universal and dynamical time, in seconds
%dtyear: year in Dynamical Time
%dtmonth
%dtday
%dtdecday: decimal day in Dynamical Time
%dthr
%dtmin
%dtsec

%Note: Universal Time will be approximated by Coordinated Universal Time,
%as these times are set to not separate by more than .9 second 
%Source: https://eclipse.gsfc.nasa.gov/SEhelp/TimeZone.html

%updated 2-23-2020

function [deltat,tdyear,tdmonth,tdday,tddecday,tdhr,tdmin,tdsec] = todyntimenasa(year,month,day,hours,minutes,seconds,calendar)

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
if seconds >= 60
    error("Seconds should be within 0-60, excluding 60.")
end


%compute deltat (in seconds) and dynamical time
deltat = compdeltatnasa(year, month);
deltatday = deltat/(3600*24); %convert deltat to decimal days
utjday = meeusjulian(year,month,day,hours,minutes,seconds,calendar); %convert input to julian date
tdjday = utjday + deltatday;  %derive julian (ephemeris) day in dynamical time
[tdyear,tdmonth,tdday,tddecday,tdhr,tdmin,tdsec] = juliantodate(tdjday); %convert into calendar date in dynamical time

    
end


