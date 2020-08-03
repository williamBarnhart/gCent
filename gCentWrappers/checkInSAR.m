function [toResample] = checkInSAR(gCentFile)

run(gCentFile);

numFiles        = length(insarDataFiles);
toResample      = [];
for k=1:numFiles
    filename    = insarDataFiles{k};
    topsTest    = strfind(filename,'merged');
    tokens      = strsplit(filename,'/');
    if(isempty(topsTest))
        datePair     = tokens{end};
        path         = tokens{end-1};
    else
        datePair     = tokens{end-1};
        path         = tokens{end-2};
    end
    
    checkName       = [datePair '_' path '.mat'];
    
    if isfile([WORKDIR '/RESAMP/' checkName]);
        display([WORKDIR '/RESAMP/' checkName ' exists, skipping']);
        pause(2);
    else
        display([WORKDIR '/RESAMP/' checkName ' missing,...']);
        display(['Resampling ' filename '/filt_topophase.unw.geo']);
        pause(2);
        toResample = [toResample {filename}];
    end
end

