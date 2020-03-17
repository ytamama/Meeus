%dailyetrad
%estimates daily total extraterrestrial radiation at any given location and day
%on Earth

%inputs:
%obslong: longitude of the observer's location, in degrees (west =
%positive; east = negative... )
%obslat: latitude of the observer's location, in degrees (north = positive,
%south = negative)
%year
%month
%day
%calendar: 1 if Gregorian; 2 if Julian
%timezone: timezone of location, inputted as offset from UTC

%output
%etrad: daily total extraterrestrial radiation, in MJ/m^2

%references:
%Chapter 3 of FAO Irrigation and Drainage Paper, No. 56, Crop 
%Evapotranspiration by Richard G. Allen et al., 1998
%
%Chapter 15 of Astronomical Algorithms, 2nd Edition, by Jean Meeus

%Updated 03/05/2020

function etrad = dailyetrad(obslong, obslat, year, month, day, calendar, timezone)

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

%compute time the sun rises and sets, and the time in between, midtime
[risetime, ~, suntime] = sunriseandsetmeeus(obslong, obslat, year, month, day, calendar);
midtime = risetime + (suntime/2);

midyr = year;
midmon = month;
midday = day;
if midtime >= 1  %if crossing into next day
    midtime = midtime - 1;
    midday = midday + 1;
    if isleapyear(year, calendar) == 1 && midday > numdaysleap(midmon)  %into next month, leap year
        midday = 1;
        midmon = midmon + 1;
    elseif isleapyear(year, calendar) == 0 && midday > numdays(midmon)  %into next month, not a leap year
        midday = 1;
        midmon = midmon + 1;
    end
    if midmon > 12   %crossing into next year
        midmon = 1;
        midyr = midyr + 1;
    end
end

midhr = midtime * 24;
midmin = 60*(midhr - floor(midhr));
midsec = 60*(midmin - floor(midmin));
midmin = floor(midmin);
midhr = floor(midhr);


%compute earth-sun distance at mid-time, in AU
esdist_mid = earthsundist(midyr, midmon, midday, midhr, midmin, midsec, calendar);

%compute declination at mid-time, in degrees
[~, decmid] = solarposition(midyr, midmon, midday, midhr, midmin, midsec, calendar, timezone);

%compute approximate sunset hour angle of the day, in degrees
%formula 15.1 from Meeus' Astronomical Algorithms, page 102
stdalt = -(50/60);  %standard altitude of the sun
hterm1 = sind(stdalt)/(cosd(obslat)*cosd(decmid));  %argument 1
hterm2 = -tand(obslat)*tand(decmid);                %argument 2
if hterm2 > 1 || hterm2 < -1  %absolute value of 2nd term is beyond 1
    error("The sun doesn't rise or set at this location!")
else
    set_ang = acosd(hterm1 - hterm2);  %degrees, between 0 and 180 degrees
end

%compute extraterrestrial radiation of the day
coeff = (24*60*.0820*esdist_mid)/pi;
term1 = (set_ang*pi/180)*sind(obslat)*sind(decmid);
term2 = cosd(obslat)*cosd(decmid)*sind(set_ang);
etrad = coeff*(term1+term2);  

end



