%datafiles={'../T435/051124-051229.mat','../T242/040708-051215.mat','../T328/050105-051221.mat','../T328/050525-060125.mat'};
%datafiles={'/home/wdb47/Qeshm/totar/050105-051221.mat'};
%datafiles= {'/m2/wdb47/Baja/Baja_Ints/Resamp/091229-100518_t306.mat', '/m2/wdb47/Baja/Baja_Ints/Resamp/100117-10052_t77.mat',...
 %  '/m2/wdb47/Baja/Baja_Ints/Resamp/100328-10052_t77.mat'};
%datafiles={'../T328/050105-060125.mat'};
%datafiles={'../T328/050525-060125.mat'};
%datafiles={'../T328/050525-051221.mat'};
datafiles={'/m2/wdb47/Baja/Models/Synthetics/rowenas_test.mat'};


%na params
ns       = 5000; %initial # samples
niter    = 5;   % # iterations
nr       = 50;  % # resamples 
nn       = 10;  % # new ones in each resampled cell 

Lp       = 1;
Wp       = 1;
xytype   = 1;    %1 = radius & angle, 2=x,y, 3=ra +aa

drake   = 0;    %allow range of rake values. 0 fixes rake, 0 if Npatch=1
smoo    = 1; %only used if Lp*Wp>1 

%search ranges: 2 values or empty
p.radius = []; 
p.angle  = []; % 0 is north
p.strike = [0 50];   %[69 77]; % usgs to cmt usgs to nissen [69 87]
p.dip    = [0 90];   %[39 45]; %cmt to usgs, cmt-nissen [39 50]
p.rake   = [-180 180]; %[-91 -83];%usgs to cmt nissen-cmg = [-105 -83] (or180-?)
p.L      = [10e3 100e3];%[2e3 10e3];
p.W      = [10e3 25e3];%[2e3 10e3];
p.zs     = [0e3 20e3]; %[10e3 12e3]; center of fault plane, mean of L and W
p.Zrange = [0e3 20e3]; %
p.area   = [0 10e9];% area
p.asp    = [-1 0]; % aspect
%xytype values set one of these pairs
p.xref   = [6.45e5];
p.yref   = [3.585e6];
%p.xs     = [3.9e5 3.94e5];
%p.ys     = [2.964e6 2.948e6];


%CMT: 
%051127 Lat 26.66 Lon 55.80 depth 12.0 Mw=5.9, M0=1.03e+25 strike 257 dip39 rake 83
%or 26.77 55.86 dep 10 Mw 5.9
