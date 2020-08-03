function generateStartFault(gCentFile);

run(gCentFile);
resampDir   = [WORKDIR '/RESAMP'];
if(isfolder(resampDir)==0)
    mkdir(resampDir);
end


[Xc,Yc,zone]       = my_utm2ll(eventLoc(1), eventLoc(2),2);
strike      = eventSDR(1);
dip         = eventSDR(2);
mag         = eventMag;
zt          = eventLoc(3);

% Get fault dimensions
L           = 10.^(-1.8362+.4951*mag)*1e3;
W           = 10.^(-1.3355+.4261*mag)*1e3;

% Make fault structure
% zt          = zc-((W/2).*sind(dip))
xt          = Xc-W/2.*cosd(dip).*cosd(strike);
yt          = Yc+W/2.*cosd(dip).*sind(strike);
%

vertices                = [xt-sind(strike).*L/2 xt+sind(strike).*L/2; yt- cosd(strike).*L/2 yt+cosd(strike).*L/2];

faultstruct.vertices    = vertices;
faultstruct.strike      = strike;
faultstruct.dip         = dip;
faultstruct.L           = L;
faultstruct.W           = W;
faultstruct.zt          = zt;
faultstruct.zone        = zone;

save([resampDir '/fault.mat'],'faultstruct');
