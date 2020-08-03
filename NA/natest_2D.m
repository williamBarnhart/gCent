nd     = 2;
ns     = 50; %initial sample size
nr     = 3;  %number cells resampled
nn     = 100; %number of new samples in each resampled

models = rand(nd,ns);
x      = models(1,:);
y      = models(2,:);

misfit = rand(1,ns); %random misfit function

no_na  = [];



figure
plot(x,y,'.')
hold on 
voronoi(x,y)


%run one interation of NA
[allmod,resampmodid]=new_na(nr,nn,models,misfit,no_na);

%plot results to verify that new samples (black dots) are around
%the two points chosen for resampling (red circles)
plot(allmod(1,:),allmod(2,:),'k.')
plot(x(resampmodid),y(resampmodid),'ro')
grid on
axis image

