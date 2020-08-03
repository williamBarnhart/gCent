function datastruct = cropWater(datastruct,waterElev,resampInFile)

run(resampInFile);

dem     = loadISCE(demfilename);
% id      = find([dem.data]<=waterElev);
data    = [datastruct.data];
demMask = ones(size(data));
demMask([dem.data]<=waterElev|isnan([dem.data]))=NaN;
data = data.*demMask;
datastruct.data = data;
end
