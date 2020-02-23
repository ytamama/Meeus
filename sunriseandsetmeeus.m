%function: sunriseandsetmeeus.m
%calculates the time of the sun rising and setting for any given day and
%location

%inputs:
%obslong: longitude of the observer's location, in degrees (west =
%positive; east = negative... )
%obslat: latitude of the observer's location, in degrees (north = positive,
%south = negative)
%year: year of date for computation
%month:
%day: 
%calendar: 1 for Gregorian, 2 for Julian Calendar

%outputs:
%risetime: time the sun rises, expressed as a fraction of the day
%settime: time the sun sets, expressed as a fraction of the day
%suntime: duration the sun is above the horizon, as a fraction of the day

%references:
%Chapters 13, 15 of Astronomical Algorithms, 2nd Edition, by Jean Meeus
%test cases checked with NOAA Solar Calculator: https://www.esrl.noaa.gov/gmd/grad/solcalc/

%updated 2-23-2020

function [risetime, settime, suntime] = sunriseandsetmeeus(obslong, obslat, year, month, day, calendar)

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

%compute apparent sidereal time at the given date at 00:00:00 UT in
%Greenwich, in degrees
appsdgreen0 = appgreen(year,month,day,0,0,0,calendar);

%compute apparent right ascension (RA) and declination (dec) of the sun at 
%the day of, day before, and day after at 00:00:00 DT
[deltatnow,nowyear,nowmonth,nowday,~,nowhr,nowmin,nowsec] = dyntoutcnasa(year,month,day,0,0,0,calendar);  %compute 00:00:00 DT's equivalent value in UT
[rightanow, decnow] = solarposition(nowyear,nowmonth,nowday,nowhr,nowmin,nowsec,calendar,0);


%compute date parameters for day before and day after
%day before
if day == 1  %first day of the month
    if month == 3  %March 1
        if isleapyear(year,calendar) == 1  %check if leap year
            daybef = 29;   %day before: 2/29 
            monthbef = 2;
            yearbef = year; 
        else  %not a leap year 
            daybef = 28;   %day before: 2/28 
            monthbef = 2;
            yearbef = year;  
        end
    elseif month == 1  %January 1
        daybef = 31;
        monthbef = 12;
        yearbef = year-1;
    else  %all other months
        monthbef = month-1;
        daybef = numdays(monthbef); %change to last day of previous month
        yearbef = year; 
    end
else 
    daybef = day-1;  %only day changes
    monthbef = month;
    yearbef = year; 
end
    
%day after
if isleapyear(year,calendar) == 1  %if leap year
    if day == numdaysleap(month)  %end of the month
        if month == 12  %end of the year
            dayaft = 1;
            monthaft = 1;
            yearaft = year+1;
        else
            dayaft = 1;
            monthaft = month + 1;
            yearaft = year; 
        end
    else
        dayaft = day + 1;
        monthaft = month;
        yearaft = year;
    end
else  %not a leap year
    if day == numdays(month)  %end of the month
        if month == 12  %end of the year
            dayaft = 1;
            monthaft = 1;
            yearaft = year+1;
        else
            dayaft = 1;
            monthaft = month + 1;
            yearaft = year; 
        end
    else
        dayaft = day + 1;
        monthaft = month;
        yearaft = year;
    end
end

%compute 00:00:00 TD time parameters for day before and after
[~,yearbef,monthbef,daybef,~,hrbef,minbef,secbef] = dyntoutcnasa(yearbef,monthbef,daybef,0,0,0,calendar);
[~,yearaft,monthaft,dayaft,~,hraft,minaft,secaft] = dyntoutcnasa(yearaft,monthaft,dayaft,0,0,0,calendar);

%compute RA and Dec for day before and after at 00:00:00 TD
[rightabef, decbef] = solarposition(yearbef,monthbef,daybef,hrbef,minbef,secbef,calendar,0);
[rightaaft, decaft] = solarposition(yearaft,monthaft,dayaft,hraft,minaft,secaft,calendar,0);


%compute local hour angle of the sun at the day of at 00:00:00 TD
stdalt = -(50/60);  %standard altitude of the sun
hterm1 = sind(stdalt)/(cosd(obslat)*cosd(decnow));
hterm2 = -tand(obslat)*tand(decnow);
if hterm2 > 1 || hterm2 < -1  %absolute value of 2nd term is beyond 1
    error("The sun doesn't rise or set at this location!")
else
    hrang_0 = acosd(hterm1 - hterm2);  %degrees, between 0 and 180 degrees
end

%compute approximate rise and set times of the sun; fractions of a day
mtransit_app = (rightanow+obslong-appsdgreen0)/360;  %ensure all three values are between 0 and 1
while mtransit_app >= 1
    mtransit_app = mtransit_app - 1;
end
while mtransit_app < 0
    mtransit_app = mtransit_app + 1;
end

mrise_app = mtransit_app - (hrang_0/360);
mset_app = mtransit_app + (hrang_0/360);
while mrise_app >= 1
    mrise_app = mrise_app - 1;
end
while mrise_app < 0
    mrise_app = mrise_app + 1;
end
while mset_app >= 1
    mset_app = mset_app - 1;
end
while mset_app < 0
    mset_app = mset_app + 1;
end

%compute the correction in approximate rise and set times
%repeat following calculations until correction is between -.01 and .01
%rise time
small_risecorr = false;
risetime = mrise_app;
while small_risecorr == false
    %compute sidereal time (degrees) for approximate rise time
    srt_mrise = appsdgreen0 + 360.985647*risetime;
    
    %interpolate RA and DEC (degrees) for approximate rise and set times
    ip_rise = risetime + deltatnow/86400;
    ra_mrise = interpolate(rightabef, rightanow, rightaaft, ip_rise);
    dec_mrise = interpolate(decbef, decnow, decaft, ip_rise);
    
    %compute hour angles (degrees) for approximate times 
    ha_rise = srt_mrise - obslong - ra_mrise;
    
    %compute altitude (degrees) for approximate times (Chapter 13)
    argarise = sind(obslat)*sind(dec_mrise)+cosd(obslat)*cosd(dec_mrise)*cosd(ha_rise);
    alt_rise = asind(argarise);
    
    %compute corrections to approximate times
    corr_rise = (alt_rise - stdalt)/(360*cosd(dec_mrise)*cosd(obslat)*sind(ha_rise));
    
    %compute corrected approximate times (fractions of a day)
    risetime = risetime + corr_rise;
    
    %ensure risetime is within 0 and 1
    while risetime >= 1
        risetime = risetime - 1;
    end
    while risetime < 0
        risetime = risetime + 1;
    end
    
    %check if correction is small enough in magnitude to proceed
    if corr_rise >= -.01 && corr_rise <= .01
        small_risecorr = true;
    end    
    
end


%set time
small_setcorr = false;
settime = mset_app;
while small_setcorr == false
    %compute sidereal time (degrees) for approximate set time
    srt_mset = appsdgreen0 + 360.985647*settime;
    
    %interpolate RA and DEC (degrees) for approximate set time
    ip_set = settime + deltatnow/86400; 
    ra_mset = interpolate(rightabef, rightanow, rightaaft, ip_set);
    dec_mset = interpolate(decbef, decnow, decaft, ip_set);
    
    %compute hour angles (degrees) for approximate times 
    ha_set = srt_mset - obslong - ra_mset;
    
    %compute altitude (degrees) for approximate times (Chapter 13)
    argaset = sind(obslat)*sind(dec_mset)+cosd(obslat)*cosd(dec_mset)*cosd(ha_set);
    alt_set = asind(argaset);
    
    %compute corrections to approximate times
    corr_set = (alt_set - stdalt)/(360*cosd(dec_mset)*cosd(obslat)*sind(ha_set));
    
    %compute corrected approximate times (fractions of a day)
    settime = settime + corr_set;

    while settime >= 1
        settime = settime - 1;
    end
    while settime < 0
        settime = settime + 1;
    end
    
    %check if correction is small enough in magnitude to proceed
    if corr_set >= -.01 && corr_set <= .01
        small_setcorr = true;
    end

end

if settime > risetime
    suntime = settime - risetime;
else
    suntime = (1+settime) - risetime;  %account for sun "setting" the next day, in UTC
end


end


