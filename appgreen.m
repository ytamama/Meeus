%function: appgreen0
%computes the apparent sidereal time at Greenwich, UK for any given date
%inputted in UTC

%inputs:
%year: year of the date to be computed
%month:
%day:
%hours:
%minutes:
%seconds:
%calendar: 1 for Gregorian; 2 for Julian
%
%output:
%appsr: apparent sidereal time at Greenwich

%references: Chapters 12 and 22 of Astronomical Algorithms, 
%2nd Edition, by Jean Meeus

%updated 2-22-2020

function appsr = appgreen(year, month, day, hours, minutes, seconds, calendar) 

%check for valid user input
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

%compute the Julian Century of the given date
jday = meeusjulian(year, month, day, 0, 0, 0, calendar);
jcen = (jday - 2451545)/36525;

%compute mean sidereal time at Greenwich, in degrees
meansr_0 = 280.46061837 + 360.98564736629*jcen*36525 + .000387933*(jcen^2) - (jcen^3)/38710000;
meansr_0 = mod(meansr_0, 360);

%compute Dynamical Time (TD) corresponding to input UT
[~,tdyear,tdmonth,tdday,~,tdhr,tdmin,tdsec] = todyntimenasa(year,month,day,hours,minutes,seconds,calendar);
jde = meeusjulian(tdyear, tdmonth, tdday, tdhr, tdmin, tdsec, calendar);  %Julian Ephemeris Day

%compute nutations (degrees) to convert mean sidereal time to apparent
[deltalon,~,obliquity] = nutations_comp(jde);
timecorr = deltalon*cosd(obliquity);  %correction in degrees

appsr = meansr_0 + timecorr;  %time in degrees

end