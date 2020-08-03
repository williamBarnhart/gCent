global Lp Wp smoo
alldatafiles={'../T435/051124-051229.mat','../T242/040708-051215.mat','../T328/050105-051221.mat','../T328/050525-060125.mat'};
%datafiles={'../T328/050105-051221.mat','../T328/050105-060125.mat','../T328/050525-060125.mat','../T328/050525-051221.mat','../T328/050525-060614.mat','../T435/051124-051229.mat','../T242/040708-051215.mat'};
smoo=1;
Ls=[10];
for Lid=1:length(Ls)
for dataid=1:length(alldatafiles)
    datafiles={alldatafiles{dataid}};
Lp       = Ls(Lid);
Wp       = Ls(Lid);
%smoo    = 5e7; %only used if Lp*Wp>1 
ns       = 500; %initial # samples
niter    = 5;   % # iterations
nr       = 100;  % # resamples 
nn       = 10;  % # new ones in each resampled cell 
NA_EQ_inverter
niter    = 5;   % # iterations
nr       = 100;  % # resamples 
nn       = 10;  % # new ones in each resampled cell 
NA_EQ_inverter
newimprovemod

filename=['a' num2str(dataid) '.mat'];

savemod242
clear models misfit
end
end

