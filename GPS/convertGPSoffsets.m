function savestruct = convertGPSoffsets(out,zone);

lon = [out.lon];
lat = [out.lat];
dE  = [out.dX];
dY  = [out.dY];
eE  = [out.eX];
eN  = [out.eY];


[tmpX,tmpY]= my_utm2ll(lon,lat,2,zone);
np = length(tmpX);
S= zeros(3,np);
for i=1:np
    X(2*i-1,1)  = tmpX(i);
    Y(2*i-1,1)  = tmpY(i);
    X(2*i,1)    = tmpX(i);
    Y(2*i,1)  = tmpY(i);
    S(1, i*2-1)= 1;
    S(2, i*2) =1;
    data(2*i-1,1)   = dE(i);
    data(2*i,1)     = dN(i);
    covd(2*i-1,1)= eE(i);
    covd(2*i,1)= eN(i);
end

% data= -data/1e3;
cov= diag(covd.^2);
np=np*2;
fill= zeros(1,np);

savestruct.covstruct.cov= covd;


for i=1:np
    %     savestruct.data(i).x       = fill(i);
    % savestruct.data(i).y       = fill(i);
    
    savestruct.data(i).scale   = fill(i);
    savestruct.data(i).count   = fill(i);
    savestruct.data(i).X       = X(i);
    savestruct.data(i).Y       = Y(i);
    
    savestruct.data(i).data    = data(i);
    savestruct.data(i).S       = S(:,i);
    
    savestruct.data(i).trix    = zeros(3,1);
    savestruct.data(i).triy    = zeros(3,1);
    
    savestruct.data(i).trid =0;
    %     savestruct.data(i).trix    = zeros(5,1);
    %     savestruct.data(i).triy    = zeros(5,1);
    %     savestruct.data(i).trid    = NaN;
end

savestruct.np= np;
savestruct.zone= zone;