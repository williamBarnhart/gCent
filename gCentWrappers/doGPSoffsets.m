function doGPSoffsets(gCentFile);
run(gCentFile);

if(isfile([WORKDIR '/RESAMP/fault.mat']))
    display('Fault file exists, skipping...');
    pause(3);
else
    display('Generating start fault from scaling relationships ... ');
    generateStartFault(gCentFile);
    pause(3);
end


files   = dir([gpsTimeSeriesDir '/*tenv3']);
ot      = eventDate(1)+((datenum(eventDate(1),eventDate(2),eventDate(3))-datenum(eventDate(1),1,1))/365.25);

for k=1:length(files)
    out(k) = calcGPSoffset(files(k).name,ot);
end

faultstruct = load([WORKDIR '/RESAMP/fault.mat']);
zone        = faultstruct.zone;
savestruct  = convertGPSoffsets(out, zone);

save([WORKDIR '/RESAMP/gpsOffsets.mat'],'savestruct');


    