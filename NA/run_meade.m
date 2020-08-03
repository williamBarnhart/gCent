dx=20e3;
dy=20e3;
[X,Y]=meshgrid(minx:dx:maxx,miny:dy:maxy);
Z=0*X;

pr=0.25; %Poisson's ratio
ss=0;
ds=1;
ts=0;
for i=1:n
    U(i)=CalcTriDisps(X(:),Y(:),Z(:),vx(i,1:3), vy(i,1:3), vz(i,1:3), pr, ss, ts, ds);
    [S(i)] = CalcTriStrains(sx, sy, sz, x, y, z, pr, ss, ts, ds)
end