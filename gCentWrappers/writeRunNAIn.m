function writeRunNAIn(gCentFile);

run(gCentFile);
NADIR       = [WORKDIR '/NA'];
RESAMPDIR   = [WORKDIR '/RESAMP'];

if(isfolder(NADIR)==0)
    mkdir(NADIR)
end

fid         = fopen([NADIR '/run_na_params.m'],'w');



% allFiles    = [insarDataFiles opticalDataFilesEW opticalDataFilesNS gpsDataFiles];


load([RESAMPDIR '/fault.mat']);

strike      = eventSDR(1);
dip         = eventSDR(2);
rake        = eventSDR(3);
[startX, startY] = my_utm2ll(eventLoc(1), eventLoc(2),2);
startL      = faultstruct.L;
startW      = faultstruct.W;
mag         = eventMag;

for k=1:length(insarDataFiles)
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
    
    if(isfile([RESAMPDIR '/' datePair '_' path '.mat']));
    resampFiles{k}  = [RESAMPDIR '/' datePair '_' path '.mat'];
    else
        error(['Could not find resampled data for ' allFiles{k}]);
    end
    
end

if(isempty(gpsTimeSeriesDir)~=1);
    if(isempty(k))
        k=1;
    else
        k=k+1;
    end
    resampFiles{k} = [RESAMPDIR '/gpsOffsets.mat'];
end

    

%Get length and width ranges. Arbitrarily chosen, may need to be revised
if mag<5
    L = [10 5e3];
    W = [10 5e3];
elseif mag>=5&mag<6
    L=[100 20e3];
    W=[100 20e3];
elseif mag>=6&mag<=7
    L=[5e3 30e3];
    W=[5e3 30e3];
elseif mag>7&mag<=8
    L=[30e3 150e3];
    W=[5e3 50e3];
else
    L=[100e3 500e3];
    W=[20e3 75e3];
end


% Set rake ranges
if rake<=180&rake>=135
    rakes = [120 180]; %Right lateral Reverse
elseif rake<135&rake>=90;
    rakes = [80 145]; %Reverse righ lateral
elseif rake<90&rake>=45;
    rakes = [40 100]; %Reverse left-lateral
elseif rake<45 & rake >=0; 
    rakes = [0 60]; %Left-lateral reverse
elseif rake<0&rake>=-45;
    rakes = [-60 0]; %Left-lateral normal
elseif rake<-45 &rake>-90;
    rakes = [-100 -40]; %Normal left-lateral
elseif rake<-90&rake>=-135
    rakes = [-145 -80]; % Normal right-lateral
elseif rake<-135 & rake>=-180
    rakes=[-180 -120]; %Right-lateral normal
else
    rakes = [-180 180];
end



dips        = [dip-30 dip+30];




fprintf(fid,'datafiles      = {');
for k=1:length(resampFiles)
    if k~=length(resampFiles)
        fprintf(fid,'''%s'',' , resampFiles{k});
    elseif(k==length(resampFiles))
        fprintf(fid,'''%s''};\n',resampFiles{k});
    end
end



fprintf(fid,'%na params\n');
fprintf(fid,'ns       = 5000; \n');
fprintf(fid,'niter    = 15;    \n');
fprintf(fid,'nr       = 50;    \n');
fprintf(fid,'nn       = 50;    \n');

fprintf(fid,'Lp       = 1;\n');
fprintf(fid,'Wp       = 1;\n');
fprintf(fid,'xytype   = 1;    \n');

fprintf(fid,'drake   = 0;    \n');
fprintf(fid,'smoo    = 1; \n');


fprintf(fid,'p.radius = [0 25e3]; \n');
fprintf(fid,'p.angle  = [0 360];\n');
fprintf(fid,'p.strike = [%f %f];   \n',strike-20, strike+20);
fprintf(fid,'p.dip    = [%f %f];\n', dips(1), dips(2));
fprintf(fid,'p.rake   = [%f %f];\n', rakes(1), rakes(2));
fprintf(fid,'p.L      = [%f %f];\n', L(1), L(2));
fprintf(fid,'p.W      = [%f %f];\n', W(1), W(2));
fprintf(fid,'p.zs     = [0e3 50e3];\n');
fprintf(fid,'p.Zrange = [0e3 50e3];\n');
fprintf(fid,'p.area   = [0 10e9];\n');
fprintf(fid,'p.asp    = [-1 0]; \n');
fprintf(fid,'%xytype values set one of these pairs\n');
fprintf(fid,'p.xref   = [%f];\n', startX);
fprintf(fid,'p.yref   = [%f];\n', startY);