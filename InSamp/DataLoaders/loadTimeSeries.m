function datastruct = loadTimeSeries(filename,losfilename, dt, zone,limitny,azo);



datastruct=struct([]);
S = [];
if(nargin<7)
    azo=0;
end
if(nargin<6)
    limitny=0;
end
if(nargin<5)
    zone=0;
end

if nargin<2
    losfilename=[];
end

if(nargin<1)
    [infilename, pathname]=uigetfile({'*.xy*','Unwrapped files (*.xy)'; ...
        '*','All files'}, ...
        'Pick an input file');
    
    filename=[pathname infilename];
    
    nx  = input([' \n'...
        '\n'...
        'Enter width of the interferogram from grdinfo output \n','s']);
    ny  = input([' \n'...
        '\n'...
        'Enter length of the interferogram from grdinfo output \n','s']);
    
end

[vels,R]        = geotiffread(filename);
vels            = double(vels);
data            = vels/1000*dt;

[lon,lat]       = meshgrid([linspace([R.LongitudeLimits(1)],[R.LongitudeLimits(2)],[R.RasterSize(2)])],linspace([R.LatitudeLimits(1)],[R.LatitudeLimits(2)],[R.RasterSize(1)]));
lon             = flipud(lon);
lat             = flipud(lat);
lookfilename    = losfilename{1};
headingfilename = losfilename{2};

look            = geotiffread(lookfilename);
look            = deg2rad(double(look));

heading         = geotiffread(headingfilename);
heading         = deg2rad(180-double(heading));

id              = find(heading==0);
jd              = find(heading~=0);
heading(id)     = mean(heading(jd));
look(id)        = mean(look(jd));

S1              = [sin(heading).*sin(look)];
S2              = [cos(heading).*sin(look)];
S3              = [-cos(look)];
badid           = find(S1(:)==0);
S1(badid)       = S1(1); % set to average in load_los
S2(badid)       = S2(1);
S3(badid)       = S2(1);
S(:,:,1)        = S1;
S(:,:,2)        = S2;
S(:,:,3)        = S3;
[ny,nx]         = size(data);


[X,Y]           = my_utm2ll(lon,lat,2,zone);
pixelsize       = Y(2)-Y(1);
datastruct=struct('data',data,'mag',[],'phs',[],'X',X,'Y',Y,'pixelsize',pixelsize, ...
    'zone',zone,'lambda',[],'nx',nx,'ny',ny,'filename',filename, ...
    'scale',0,'extrax',0,'extray',0, 'S',S);





