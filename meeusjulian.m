%function: converts an input date into Julian Date
%
%reference: algorithms provided in Chapter 7 (pages 59-64) of Astronomical
%Algorithms, 2nd Edition, by Jean Meeus
%
%inputs:
%year
%month (1 = January, 2 = February... 12 = December)
%day (inputted as a decimal to account for hours, minutes, and seconds)
%calendar: 1 for Gregorian Calendar; or 2 for Julian
%
%output:
%date in Julian days

function jday = meeusjulian(year, month, day, calendar)

%check for valid user inputs and fix where possible
numdays=[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];  %number of days in each month
numdaysleap=[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

if month > 12 || month < 1 || mod(month,1) ~= 0
    error("Month should be within 1-12.")
end
if day < 1
    error("Invalid day input. The days in a month start with one!")
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
    
%adjust month and year if January or February
if month == 1 || month == 2
    year = year - 1;
    month = month + 12;
elseif month > 12
    error("Invalid input for month!")
end

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