% gCent_in.m
% Input script for driving gCent

%Event parameters
eventID             = 'Nevada_20200515';
eventID2            = 'nn00725272'
eventLoc            = [-117.875 38.159 0];       %Lon, lat, depth
eventSDR            = [73 78 -24];                %Event Strike, dip, rake
eventMag            = 7;                           %Event magnitude
eventDate           = [2020 05 15];             % Event date, year, month, day
% Datafiles, split between InSAR, GPS, and optical sensors. 
% Include all data files that you wish to include in the inversion, even if they've already been resampled.
% Give full paths to processed directories
%
% InSAR data files: give path to filt_topophase.unw.geo and los.rdr.geo
% files
%
% Optical data: give full path to EW and NS displacements files
% (displacements in meters)
%
% GPS data: give full path to a .mat file

insarDataFiles      = {'/Users/wbarnhart/Work_local/EQmonitoring/Nevada_20200515/p144/200510-200516/merged','/Users/wbarnhart/Work_local/EQmonitoring/Nevada_20200515/p64/200511-200517/merged'};
opticalDataFilesEW  = {};
opticalDataFilesNS  = {};
gpsTimeSeriesDir    = {};


WORKDIR             = ['/Users/wbarnhart/Work_local/EQmonitoring/' eventID];

%Elevation of water in dem.crop file. Used to crop out water areas. To skip
%water masking, set waterElev = [];
waterElev           = [];
