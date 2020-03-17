%function isleapyear
%returns whether a given year is a leap year or not
%
%inputs:
%year
%calendar: 1 for Gregorian; 2 for Julian
%
%outputs:
%isleap: 1 if leap year; 0 if not a leap year

%references: Chapter 7, page 62 of Astronomical Algorithms, 2nd Edition by
%Jean Meeus

%updated 2-21-2020

function isleap = isleapyear(year, calendar)

if calendar == 1  %Gregorian: non-centurial year divisible by 4 or centurial year divisible by 400
    if (mod(year,100) > 0 && mod(year,4) == 0) || (mod(year,400) == 0)  
        isleap = 1;
    else %common day
        isleap = 0;
    end
elseif calendar == 2  %Julian (different leap year system than Gregorian)
    if mod(year,4) == 0  %any year divisible by 4 = leap year
        isleap = 1;
    else %common day
        isleap = 0;
    end
else %invalid calendar specification
    error("Invalid calendar specification. Input 1 for Gregorian Calendar and 2 for Julian")
end

end

