
function runGCent(steps,gCentFile)
% runGCent(steps, gCentFile)
% Wrapper function for running the different steps of gCent to produce a
% single path source model of an earthquake from geodetic observations
%
%
% Inputs:
% steps
%   'all'           Run data resampling and inversion
%   'resample'      Run resampling only
%   'inversion'     Run inversion only
% gCentFile
%   Full or relative directory path location of the gCent_in.m defaults
%   file that has data and event paramaters
%
% Hints
% 1. For the sake of simplicity, most defaults are set in gCentFile. If
% your inversions are not turning out well, such as when the inversion
% wants solutions outside of the allowable search range, you can adjust
% starting locations, strikes, and dips in gCentFile.
%
% 2. The resampler creates a starting fault based on the event location in
% gCentFile. You can look at the interferograms a-priori and choose an
% event location based on the interferogram itself
%
% 3. For large earthquakes, NA may need a larger search distance to find
% the location of the event (the "location" is the center of the fault
% plane, not necessarily the hypocenter. A larger search distance can be
% achieved by changing the p.radius range in writeRunNAIn.m

run(gCentFile)


if(isfolder(WORKDIR)==0)
    mkdir(WORKDIR)
end

switch steps
    case 'all'
        if(isfolder([WORKDIR '/RESAMP'])==0)
            mkdir([WORKDIR '/RESAMP']);
        end
        
        if(isempty(insarDataFiles)~=1);
            doInSARResample(gCentFile);
        end
        
        
        if(isempty(gpsTimeSeriesDir)~=1);
            doGPSoffsets(gCentFile);
        end
        %         doOpticalResample(gCentFile);
        runNA(gCentFile);
    case 'resample'
        if(isfolder([WORKDIR '/RESAMP'])==0)
            mkdir([WORKDIR '/RESAMP']);
        end
        
        if(isempty(insarDataFiles)~=1);
            doInSARResample(gCentFile);
        end
        
        
        if(isempty(gpsTimeSeriesDir)~=1);
            doGPSoffsets(gCentFile);
        end
    case 'inversion'
        runNA(gCentFile);
end
