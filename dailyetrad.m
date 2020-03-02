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

%Updated 03/02/2020

function etrad = dailyetrad(obslong, obslat, year, month, day, calendar, timezone)

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

%compute sunset hour angle at mid-time, in degrees
set_ang = acosd(-tand(obslat)*tand(decmid));

%compute extraterrestrial radiation of the day
coeff = (24*60*.0820*esdist_mid)/pi;
term1 = (set_ang*pi/180)*sind(obslat)*sind(decmid);
term2 = cosd(obslat)*cosd(decmid)*sind(set_ang);
etrad = coeff*(term1+term2);  

end









