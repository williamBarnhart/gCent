# gCent
The gCent (geodetic Centroid) package is an open-source package for downsampling and inverting InSAR observations rapidly for the finite source mechanism of an earthquake. gCent is Matlab scripts and functions that will take a processed interferogram from ISCE (https://github.com/isce-framework/isce2), downsample the interferogram, and then invert the downsampled observations for the location, geometry, dimensions, and slip magnitude of a single fault plane embedded in an elastic halfspace. 

This package is a modified and updated amalgamation of several packages that have been developed and published in multiple papers. Specifically, this package uses the variable data downsampling approach of Lohman & Simons (2004) that is available as the InSamp package (https://github.com/williamBarnhart/InSamp) to downsample data. The inversions are conducted using the Neighbourhood Algorithm (Sambridge 1997), as described in multiple publications (add refs...). 

This is research code that is provided to you "as is" with no warranties of correctness. Use at your own risk.

## 1. Pre-requisites
  - MATLAB (tested on version R2014a) and higher)
  - MATLAB Optimization Toolbox
  - MATLAB Mapping Toolbox
  - gCent (this package)
  - A processed interferogram in ISCE format
  - An unwrapped, geocoded interferogram, appropriate look files, a coherence map for masking, and a DEM clipped to the interferogram area (dem.crop in the merged directory of Sentinel interferograms. Only used if you wish to mask water).

## 2. Installation
  - Download the gCent package and place it in a directory where you save Matlab function/scripts
  - Launch Matlab and execute the following on the command line:
  
      addpath(genpath(/path/to/matlabfiles/gCent/v0.2))
    
## 3. Running gCent
  - gCent can be run in three different modes: do everything, just resample, or just invert. 
  - Before undertaking these steps, though, you will need to edit the gCent_in.m file located in your gCent/v0.2 directory:
### 3.0 Edit the gCent_in.m file
1. You can either edit gCent_in.m in the gCent/v0.2 directory, or you can copy it to a working directory of your choice.
2. gCent_in.m has the following structure:

<```% gCent_in.m
% Input script for driving gCent

%Event parameters
eventID             = 'Pakistan_20190924';      % An event ID for identifying the event
eventLoc            = [73.766 33.106, 0];       %Lon, lat, depth of the event
eventSDR            = [276 17 92];                %Event Strike, dip, rake of focal mechanism you wish to test
eventMag            = 5.6;                           %Event magnitude, for scaling dimensions

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

insarDataFiles      = {'/Users/wbarnhart/Work_local/EQmonitoring/Pakistan_20190924/p100/190916_190928/merged'};
opticalDataFilesEW  = {};
opticalDataFilesNS  = {};
gpsDataFiles        = {};


WORKDIR             = ['/Users/wbarnhart/Work_local/EQmonitoring/' eventID];

%Elevation of water in dem.crop file. Used to crop out water areas. To skip
%water masking, set waterElev = [];
corThresh           = 0.6;
waterElev           = [-30]; %Leave this empty if there's no water to mask```>

The eventID, eventLoc, eventSDR and eventMag are used to estimate a starting fault that is used for downsampling data, and then they are used to select appropriate ranges for the starting location, strike, dip, and rake, and dimensions (length and width) of the fault plane for the inversions. The insarDaraFiles, opticalDataFiles, and gpsDataFiles are directory paths to where data files are located. The example here is for inverting a single Sentinel-1 TOPS Mode interferogram (note, it only points to the location where the files are stored, not their filenames). You can add multiple interferograms by adding another file into the brackets and bookended by apostrophes.

Edit all of these values as necessary for your particular event. I typically define location and geometry based on the USGS W-Phase solution, but you an use whatever you like.

### 3.1 Running everything
If you decide to run all steps in gCent, the following steps will occur in the directory WORKDIR defined in your gCent_in.m file:
1. Check if resampled interferograms and a start fault exist
2. Create a starting fault (fault.mat' in the directory WORKDIR/RESAMP) that is used as the spatial reference for resampling. This is done using earthquake scaling relationships and the input parameters of gCent_in.m
3. Downsample each of the interferograms for which no resampled interferogram exists in WORKDIR/RESAMP. If a resampled interferogram already exists for a given interferogram, gCent will skip that scene (so delete scenes that you want to re-resampe).
4. Estimate the variance structure of the resampled interferogram (see the Hints section below on how to change this to the full covariance matrix).
5. Invert the resampled interferograms for the best fitting geometry (strike, dip), dimensions (length, width), location (depth, longitude, latitude), and slip characteristics (rake, slip magnitude) of a single fault patch.
6. Generate a series of figures and saved information in WORKDIR/NA

To run everything, execute the following on the Matlab command line:

`runGCent('all','/path/to/your/gCentfile/gCent_in.m')`

### 3.2 Just resample
To just do the data resampling (steps 1-4 in the section 3.1), execute the following:

`runGCent('resample','/path/to/your/gCentfile/gCent_in.m')`

This can be useful if you're just prepping interferograms, or if you want to resample based on a new starting fault model.

### 3.3 Just invert
To just do the inversion and plotting (steps 5-6 in the section 3.1), execute the following:

`runGCent('inversion','/path/to/your/gCentfile/gCent_in.m')`

This can be useful if you want to test alternate start models, different focal planes, or if you're adding a pre-existing resampled interferogram

