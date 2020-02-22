%juliantodate
%convert from Julian date to a date in the Gregorian or Julian Calendar
%
%reference: algorithms provided in Chapter 7 (pages 63-64) of Astronomical
%Algorithms, 2nd Edition, by Jean Meeus
%
%inputs
%juldate: Julian Date
%calendar: 1 for Gregorian calendar output; 2 for Julian calendar
%
%output
%year
%month
%day
%decday: decimal days
%hours
%minutes
%seconds

%updated 2/22/2020

function [year,month,day,decday,hours,minutes,seconds] = juliantodate(juldate)

%method valid for only JD >= 0
if juldate < 0
    error("Method can only accept zero or positive Julian Days.")
end

%begin computations
juldate = juldate + .5;
z_var = floor(juldate);
f_var = mod(juldate,z_var);

if z_var < 2299161
    a_var = z_var;
else
    alpha = floor((z_var - 1867216.25)/36524.25);
    a_var = z_var + 1 + alpha - floor(alpha/4);
end

b_var = a_var + 1524;
c_var = floor((b_var - 122.1)/365.25);
d_var = floor(365.25*c_var);
e_var = floor((b_var - d_var)/30.6001);

%determine month
if e_var < 14
    month = e_var - 1;
else
    month = e_var - 13;
end

%determine year
if month > 2
    year = c_var - 4716;
else
    year = c_var - 4715;
end

%determine day
decday = b_var - d_var - floor(30.6001*e_var) + f_var;
day = floor(decday);

%determine hour, minutes,seconds
hourdec = (decday - day)*24;
hours = floor(hourdec);
mindec = (hourdec - hours)*60;
minutes = floor(mindec);
seconds = (mindec - minutes)*60;

end

