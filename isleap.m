function isleap = isleap(year, calendar)
% Returns whether a given year is a leap year or not
%
% Inputs:
% year
% calendar: 1 for Gregorian; 2 for Julian
%
% Outputs:
% isleap: 1 if leap year; 0 if not a leap year
%
% References: Chapter 7, page 62 of Astronomical Algorithms, 2nd Edition by
% Jean Meeus
%
% Last Modified May 23, 2020 by Yuri Tamama

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

