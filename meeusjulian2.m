%function: converts an input date into Julian Date
%same algorithm as meeusjulian.m but allows for input of hours, minutes,
%and seconds
%
%reference: algorithms provided in Chapter 7 (pages 59-64) of Astronomical
%Algorithms, 2nd Edition, by Jean Meeus
%
%inputs:
%year
%month (1 = January; 2 = February)
%day
%hour (1 - 24)
%minutes (0-60)
%seconds (0-60)
%calendar: 1 if the input date is in the Gregorian Calendar; or 2 in the
%Julian Calendar
%
%output:
%date in Julian days

function jday = meeusjulian2(year, month, day, hours, minutes, seconds, calendar)

%check for valid user inputs
numdays=[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];  %number of days in each month
numdaysleap=[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

if month > 12 || month < 1 || mod(month,1) ~= 0
    error("Month should be an integer within 1-12.")
end
if day < 1 || mod(day,1) ~= 0
    error("Invalid day input. The day should be an integer starting with one.")
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
if hours >= 24 || hours < 0
    error("Hour should be within 0-24, excluding 24.")
end
if minutes >= 60 || minutes < 0
    error("Minutes should be within 0-60, excluding 60.")
end
if seconds >= 60 || seconds
    error("Seconds should be within 0-60, excluding 60.")
end
    
%adjust month and year if January or February
if month == 1 || month == 2
    year = year - 1;
    month = month + 12;
elseif month > 12
    error("Invalid input for month!")
end

%convert day, hour, minutes, and seconds to a decimal day
day = day + (hours/24) + (minutes/(24*60)) + (seconds/(24*60*60));

%convert to Julian Date
%Gregorian calendar
if calendar == 1
    a_var = floor(year/100);
    b_var = 2 - a_var + floor(a_var / 4);
%Julian Calendar
elseif calendar == 2
    a_var = floor(year/100);
    b_var = 0;
%Invalid calendar input
else
    error("Invalid calendar type input: indicate 1 for Gregorian, 2 for Julian.")
end

%convert to JD
jday = floor(365.25*(year+4716))+floor(30.6001*(month+1))+day+b_var-1524.5;

end
