%function: nutations_comp.m
%computes the nutations in longitude and obliquity, as well as the obliquity, 
%in degrees for a given Julian Ephemeris Day 

%inputs:
%Julian Ephemeris Day (Julian Date of Dynamical Time)

%outputs:
%deltalon: nutation in longitude, degrees
%deltaob: nutation in obliquity, degrees
%obliquity: obliquity after correction with deltaob, degrees

%references:
%Chapter 22 of Astronomical Algorithms, 2nd Edition, by Jean Meeus

%updated 2-21-2020

function [deltalon, deltaobl, obliquity] = nutations_comp(jdeday)
    jcen = (jdeday - 2451545)/36525;  %Julian century
    ascnode = 125.04452 - 1934.136261*jcen;  %longitude of ascending node
    mlonsun = 280.4665 + 36000.7698*jcen;    %mean longitude of the sun
    mlonmoon = 218.3165 + 481267.8813*jcen;  %mean longitude of the moon
    
    lon1 = (-17.20/3600)*sind(ascnode);  %terms to compute nutation in longitude
    lon2 = (1.32/3600)*sind(2*mlonsun);
    lon3 = (.23/3600)*sind(2*mlonmoon);
    lon4 = (.21/3600)*sind(2*ascnode);
    
    obl1 = (9.2/3600)*cosd(ascnode);     %terms to compute nutation in obliquity
    obl2 = (.57/3600)*cosd(2*mlonsun);
    obl3 = (.10/3600)*cosd(2*mlonmoon);
    obl4 = (.09/3600)*cosd(2*ascnode);
    
    deltalon = lon1 - lon2 - lon3 + lon4;  %nutation in longitude
    deltaobl = obl1 + obl2 + obl3 - obl4;  %nutation in obliquity
    
    %obliquity of the ecliptic in degrees
    u = (jdeday-2451545)/3652500;
    e0 = 23+(26/60)+(21.448/3600);
    ucoeff1 = -4680.93/3600;
    ucoeff2 = -1.55/3600;
    ucoeff3 = 1999.25/3600;
    ucoeff4 = -51.38/3600;
    ucoeff5 = -249.67/3600;
    ucoeff6 = -39.05/3600;
    ucoeff7 = 7.12/3600;
    ucoeff8 = 27.87/3600;
    ucoeff9 = 5.79/3600;
    ucoeff10 = 2.45/3600;
    
    e0 = e0 + ucoeff1*u + ucoeff2*(u^2) + ucoeff3*(u^3) + ucoeff4*(u^4) + ucoeff5*(u^5) + ucoeff6*(u^6) + ucoeff7*(u^7) + ucoeff8*(u^8) + ucoeff9*(u^9) + ucoeff10*(u^10);
    obliquity = e0 + deltaobl;

end