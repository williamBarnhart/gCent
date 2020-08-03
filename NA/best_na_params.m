%datafiles={'../T435/051124-051229.mat','../T242/040708-051215.mat'};
datafiles={'../T435/051124-051229.mat'};
%datafiles={'../T242/040708-051215.mat'};

%na params
ns       = 500; %initial # samples
niter    = 5;   % # iterations
nr       = 50;  % # resamples 
nn       = 10;  % # new ones in each resampled cell 

Lp       = 1;
Wp       = 1;
xytype   = 1;    %1 = radius & angle, 2=x,y

drake   = 0;    %allow range of rake values. 0 fixes rake, 0 if Npatch=1
smoo    = 0.1; %only used if Lp*Wp>1 

%search ranges: 2 values or empty
p.radius = [0 4e3];
p.angle  = [-60 180]; % 0 is north
p.strike = [40 90];   %[69 77]; % usgs to cmt usgs to nissen [69 87]
p.dip    = [20 60];   %[39 45]; %cmt to usgs, cmt-nissen [39 50]
p.rake   = [-180 -80]; %[-91 -83];%usgs to cmt nissen-cmg = [-105 -83] (or180-?)
p.L      = [2e3 10e3];%[2e3 10e3];
p.W      = [0 5e3];%[2e3 10e3];
p.zs     = [4e3 8e3]; %[10e3 12e3];
p.Zrange = [4e3 10e3];
%xytype values set one of these pairs
p.xref   = [ 392000];
p.yref   = [2964200];
%p.xs     = [3.9e5 3.94e5];
%p.ys     = [2.964e6 2.948e6];
