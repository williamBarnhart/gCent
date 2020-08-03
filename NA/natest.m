nd     = 3;
ns     = 100; %initial sample size
nr     = 2;  %number cells resampled
nn     = 50; %number of new samples in each resampled

models = rand(nd,ns);
x      = models(1,:);
y      = models(2,:);
z      = models(3,:);
misfit = rand(1,ns); %random misfit function

no_na  = [];

%run one interation of NA
[allmod,resampmodid]=new_na(nr,nn,models,misfit,no_na);


%plot results to verify that new samples (black dots) are around
%the two points chosen for resampling (red circles)

figure
plot3(x,y,z,'.')
hold on 
plot3(allmod(1,:),allmod(2,:),allmod(3,:),'k.')
plot3(x(resampmodid),y(resampmodid),z(resampmodid),'ro')
grid on
axis image
