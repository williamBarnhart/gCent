function datastructNew = cropDatastruct(datastruct,cropX,cropY);
display('Cropping Dataset');
X = [datastruct.X];
Y = [datastruct.Y];
data = [datastruct.data];
phs = [datastruct.phs];
pixelsize = [datastruct.pixelsize];
S = [datastruct.S];


idx     = find(X(1,:)>cropX(1)&X(1,:)<cropX(2));
idy     = find(Y(:,1)>cropY(1)&Y(:,1)<cropY(2));

X       = X(min(idy):max(idy),min(idx):max(idx));
Y       = Y(min(idy):max(idy),min(idx):max(idx));
data    = data(min(idy):max(idy),min(idx):max(idx));
S       = S(min(idy):max(idy),min(idx):max(idx),:);
nx      = length(idx);
ny      = length(idy);
phs     = phs(min(idy):max(idy),min(idx):max(idx));


datastructNew = datastruct;
datastructNew.X=X;
datastructNew.Y=Y;
datastructNew.S=S;
datastructNew.data=data;
datastructNew.nx = nx;
datastructNew.ny = ny;
datastructNew.phs = phs;
