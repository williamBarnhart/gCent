function doInSARResample(gCentFile)
run(gCentFile);   

toResample      = checkInSAR(gCentFile);

%Check if starting fault (fault.mat) exists
if(isfile([WORKDIR '/RESAMP/fault.mat']))
    display('Fault file exists, skipping...');
    pause(3);
else
    display('Generating start fault from scaling relationships ... ');
    generateStartFault(gCentFile);
    pause(3);
end

for j = 1:length(toResample)
    writeResampIn(toResample{j}, gCentFile);
    resampInSARgCent(gCentFile);
end
