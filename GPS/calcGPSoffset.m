
function out = calcGPSoffset(filename, ot);

fid         = fopen(filename,'r');
dataTable   = textscan(fid,'%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','headerLines',1);
station     = dataTable{1};
decimalYear = dataTable{3};
dxi         = dataTable{8};
dxf         = dataTable{9};
dyi         = dataTable{10};
dyf         = dataTable{11};
dzi         = dataTable{12};
dzf         = dataTable{13};

dx          = dxi+dxf;
dy          = dyi+dyf;
dz          = dzi+dzf;



% Get station location
fid2        = fopen('/Users/wbarnhart/Documents/MATLAB/gCent/v0/GPS/UNR_station_list.txt');
stationTable= textscan(fid2,'%s%f%f%f');
slon        = stationTable{3};
slat        = stationTable{2};
ind         = strmatch(station{1},stationTable{1});
lon         = slon(ind);
lat         = slat(ind);


id1         = find(decimalYear<ot & decimalYear>=ot-(30/365.25));
id2         = find(decimalYear>ot & decimalYear<=ot+(30/365.25));


d1          = decimalYear(id1);
d2          = decimalYear(id2);

% DX displacement
[p1,goodness1]  = fit(d1-ot,dx(id1),'poly1');


if length(id2)==1
    p2.p2 = dx(id2);
    cint2=zeros(2);
else
    [p2,goodness2]  = fit(d2-ot,dx(id2),'poly1');
    cint2           = confint(p2);
end

cint1           = confint(p1);

dE              = p2.p2-p1.p2;
eE              = mean([diff(cint1(:,2)) diff(cint2(:,2))]);



% DY displacement
[p1,goodness1]  = fit(d1-ot,dy(id1),'poly1');


if length(id2)==1
    p2.p2 = dy(id2);
    cint2=zeros(2);
else
    [p2,goodness2]  = fit(d2-ot,dy(id2),'poly1');
    cint2           = confint(p2);
end

cint1           = confint(p1);

dN              = p2.p2-p1.p2;
eN              = mean([diff(cint1(:,2)) diff(cint2(:,2))]);

% DZ displacement
[p1,goodness1]  = fit(d1-ot,dz(id1),'poly1');


if length(id2)==1
    p2.p2 = dz(id2);
    cint2=zeros(2);
else
    [p2,goodness2]  = fit(d2-ot,dz(id2),'poly1');
    cint2           = confint(p2);
end

cint1           = confint(p1);

dU              = p2.p2-p1.p2;
eU              = mean([diff(cint1(:,2)) diff(cint2(:,2))]);

out.lon     = lon;
out.lat     = lat;
out.dX      = dE;
out.dY      = dN;
out.dZ      = dU;
out.eX      = eE;
out.eY      = eN;
out.eZ      = eU;



