# gCent
The gCent (geodetic Centroid) package is an open-source package for downsampling and inverting InSAR observations rapidly for the finite source mechanism of an earthquake. gCent is Matlab scripts and functions that will take a processed interferogram from ISCE (https://github.com/isce-framework/isce2), downsample the interferogram, and then invert the downsampled observations for the location, geometry, dimensions, and slip magnitude of a single fault plane embedded in an elastic halfspace. 

This package is a modified and updated amalgamation of several packages that have been developed and published in multiple papers. Specifically, this package uses the variable data downsampling approach of Lohman & Simons (2005) that is available as the InSamp package (https://github.com/williamBarnhart/InSamp) to downsample data. The inversions are conducted using the Neighbourhood Algorithm (Sambridge 1999), as described in multiple publications (Barnhart, 2017; Barnhart et al., 2019, 2015, 2013, and others). 

This is research code that is provided to you "as is" with no warranties of correctness. Use at your own risk.

## 1. Pre-requisites
  - MATLAB (tested on version R2014a) and higher)
  - MATLAB Optimization Toolbox
  - MATLAB Mapping Toolbox
  - gCent (this package)
  - A processed interferogram in ISCE format: unwrapped, geocoded interferogram, appropriate look files, a coherence map for masking, and a DEM clipped to the interferogram area (dem.crop in the merged directory of Sentinel interferograms. Only used if you wish to mask water).

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

```
% gCent_in.m
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
waterElev           = [-30]; %Leave this empty if there's no water to mask
```

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

### 3.4 Example Tutorial
I have provided a set of processed interferograms and an example _gCent_in.m_ file that can be used as a test and tutorial. Download the file package from: https://drive.google.com/file/d/1PDbklumZJIqntwnP65i0cbMxr8GsZwCK/view?usp=sharing

Place the zip file somewhere you like and unpack it. Then in Matlab, navigate to the directory and do the following:

`addpath(genpath(/path/to/matlabfiles/gCent/v0.2)) % just to ensure that everything is in your path, skip otherwise
runGCent('all',['./gCent_in.m']);`

This will run through all the downsampling and inversions. Depending on your processor and other things going on on your computer, allow for ~1-2 hours of time to go through all the steps (there are 3 interferograms that will be downsampled).

## 4. Conventions
### 4.1 Interferogram conventions
gCent works with co-seismic interferograms. It expects that the interferograms are processed with the older (pre-seismic) date as the reference date, and the youger (post-seismic) date as the secondary date. In this reference frame, negative LOS motion indicates motion toward the satellite (LOS decrease, typical of uplift), and positive LOS motion indicates motion away from the satellite (LOS increase, typical of subsidence). 
### 4.2 Inversion conventions
gCent is set-up to use a right-hand rule referene frame for defining strike direction and dip. Rake values are based on the same conventions of the W-phase moment tensor reported by the USGS. 

## 5. Hints, Tricks, and Code Hacks
  1. *Variance vs. Covariance Matrics:* 
  
  gCent's default is to estimate a variance matrix for the resampled data, simply because it's fast to do so. However, a full covariance matrix will likely lead to better inversions, but it takes longer to accomplish. To force gCent to estimate a full covariance matrix when resampling data, open _writeResampIn.m_ and change the very last line _frpintf(fid,'getcov     = 1\n');_ to _frpintf(fid,'getcov     = 2\n');_
  
  2. *Water Masking:* 
  
  Water masking can be very useful in regions where you have unwrapped phase over water (as happens when using SNAPHU). To set the water masking threshold, change the _waterElev_ variable in _gCent_in.m_ to a value chosen from the dem.crop file. Use mdx.py to click around and choose a value.
  
  3. *Your own start fault:* 
  
  gCent creates a start fault when doing the resampling using values you provide it the _gCent_in.m_ file and earthquake scaling relationships. Before doing this, it looks for WORKDIR/RESAMP/fault.mat. If fault.mat exists, it skips this step. In some cases, the starting location and geometry for a fault may be inappropriate due to mislocation or rupture propagation characteristics (the latter becomes more important with larger earthquakes). gCent includes a tool _faultMaker.m_ that will allow you to manually create your own single or multi-segment fault file. Execute _faultMaker_ on the command line, and this will launch a GUI that will allow you to create your own fault plane from an interferogram.
  
  4. *Changing inversion parameters manually:* 
  
  You may find that inversions aren't fitting the data well, or that the inversion prefers model values that the Neighbourhood Algorithm isn't searching (i.e. strike is too constrained). There are two ways to changes these values. First, you can adjust the start location and geometry in the _gCent_in.m_ file to test alternate start models. Second, you can navigate to the inversion directory (WORKDIR/NA). If you've already run the inversion step, there will be a file _run_na_params.m_ that has the different ranges for model values that are tested in the inversion. You can manually change these, then re-run the inversion by executing the following on the command line:
  
  `clear all; NA_EQ_inverter`
  
  It's important to clear your workspace each time you change _run_na_params_ run NA_EQ_inverter; otherwise, it won't recognize the changes you made.
  
  5. *Hacking into scripts and functions:*
  
  Many of the utilities and sub-utilities of gCent should be fairly easy to follow if you know Matlab programming. There are many aspects of the core functionality that you can run independently or in parts to tune to your needs. 
  
  At the same time, this software is an amalgamation of many utilities, many of which were edited or updated on the fly to solve a particular earthquake problem. So the codes are not "clean" and there are aspects of the codes that no longer have any functionality. Don't be suprised if you find lines of code that go no where...
  
  ## 6. References and Citing
  ### 6.1 References from ReadMe
  
Barnhart, W.D., 2017. Fault creep rates of the Chaman fault (Afghanistan and Pakistan) inferred from InSAR. J. Geophys. Res. Solid Earth 122, 2016JB013656. https://doi.org/10.1002/2016JB013656

Barnhart, W.D., Hayes, G.P., Wald, D.J., 2019. Global Earthquake Response with Imaging Geodesy: Recent Examples from the USGS NEIC. Remote Sens. 11, 1357. https://doi.org/10.3390/rs11111357

Barnhart, W.D., Lohman, R.B., Mellors, R.J., 2013. Active accommodation of plate convergence in Southern Iran: Earthquake locations, triggered aseismic slip, and regional strain rates. J. Geophys. Res. Solid Earth 118, 5699–5711. https://doi.org/10.1002/jgrb.50380

Barnhart, W.D., Murray, J.R., Yun, S.-H., Svarc, J.L., Samsonov, S.V., Fielding, E.J., Brooks, B.A., Milillo, P., 2015. Geodetic Constraints on the 2014 M 6.0 South Napa Earthquake. Seismol. Res. Lett. 86, 335–343. https://doi.org/10.1785/0220140210

Lohman, R.B., Simons, M., 2005. Some thoughts on the use of InSAR data to constrain models of surface deformation: Noise structure and data downsampling. Geochem. Geophys. Geosystems 6, n/a–n/a. https://doi.org/10.1029/2004GC000841

Sambridge, M., 1999. Geophysical inversion with a neighbourhood algorithm—I. Searching a parameter space. Geophys. J. Int. 138, 479–494. https://doi.org/10.1046/j.1365-246X.1999.00876.x

### 6.2 Referencing algorithms
For referencing InSamp and the InSAR downsampling routines:

Lohman, R.B., Simons, M., 2005. Some thoughts on the use of InSAR data to constrain models of surface deformation: Noise structure and data downsampling. Geochem. Geophys. Geosystems 6, n/a–n/a. https://doi.org/10.1029/2004GC000841

For referecing the general Neighbourhood Algorithm:

Sambridge, M., 1999. Geophysical inversion with a neighbourhood algorithm—I. Searching a parameter space. Geophys. J. Int. 138, 479–494. https://doi.org/10.1046/j.1365-246X.1999.00876.x

For referecing the entire workflow, use the two references above AND this one:

Barnhart, W.D., Hayes, G.P., Wald, D.J., 2019. Global Earthquake Response with Imaging Geodesy: Recent Examples from the USGS NEIC. Remote Sens. 11, 1357. https://doi.org/10.3390/rs11111357
