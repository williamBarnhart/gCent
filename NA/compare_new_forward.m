global X Y S rampg data ranges drake Lp Wp smoo Cdinv p

run_na_params
%initialize arrays
np           = 0;
resampstruct = [];
covd         = [];
rampg        = [];

for i=1:length(datafiles)
    load(datafiles{i})
    allnp(i)     = savestruct.np;
    resampstruct = [resampstruct savestruct.data];
    tmpcov=savestruct.covstruct.cov;
    %tmpcov=diag(diag(tmpcov));
    covd         = blkdiag(covd,tmpcov);
end
np    = sum(allnp);
data  = [resampstruct.data];
X     = [resampstruct.X];
Y     = [resampstruct.Y];
boxx  = [resampstruct.boxx];
boxy  = [resampstruct.boxy];
S     = [resampstruct.S];
%covd=diag(diag(covd));
ch    = chol(covd);
Cdinv = inv(ch');
sortt  = 0;
EQt    = 0;

for i=1:length(datafiles)
    id    = [1:allnp(i)]+sum(allnp(1:(i-1)));
    rampg = blkdiag(rampg,[(X(id)-min(X(:)));(Y(id)-min(Y(:)));ones(1,allnp(i))]);
end

%define search ranges
Npatch     = Lp*Wp;
if(Npatch==1),drake=0;end

[ranges,p] = EQ_defaults(p,Npatch,xytype);
[junk,nd]=size(ranges);
model=0.5*ones(nd,1);


[res1,slip1,misfit1,out1,synth1,g11,g21,green1,Gsmoo1,dsmoo1] = forward_EQ(model,xytype);
[res2,slip2,misfit2,out2,synth2,g12,g22,green2,Gsmoo2,dsmoo2] = forward_EQ_new(model,xytype,resampstruct);


slip1(1);
slip2(1);
slip1(1)-slip2(1)
misfit1;
misfit2;
misfit1-misfit2
xref=p.xref;
yref=p.yref;
nramp = size(rampg,1);
fboxx = [out1.boxx]-xref;
fboxy = [out1.boxy]-yref;
fboxz = [out1.boxz];


figure
subplot(3,2,1)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,synth1(1:np)'-synth2(1:np)');
axis image,shading flat
hold on
plot(fboxx/1e3,fboxy/1e3,'k')
colorbar
title('synth')

subplot(3,2,2)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,res1(1:np)'-res2(1:np)');
axis image,shading flat
hold on
plot(fboxx/1e3,fboxy/1e3,'k')
colorbar
title('res')

subplot(3,2,3)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,dsmoo1(1:np)'-dsmoo2(1:np)');
axis image,shading flat
hold on
plot(fboxx/1e3,fboxy/1e3,'k')
colorbar
title('dsmoo')

subplot(3,2,4)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,Gsmoo1(1:np,1)'-Gsmoo2(1:np,1)');
axis image,shading flat
hold on
plot(fboxx/1e3,fboxy/1e3,'k')
colorbar
title('gsmoo')

subplot(3,2,5)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,g11(1,1:np)-g12(1,1:np));
axis image,shading flat
hold on
plot(fboxx/1e3,fboxy/1e3,'k')
colorbar
title('g1')



subplot(3,2,6)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,g21(1,1:np)-g22(1,1:np));
axis image,shading flat
hold on
plot(fboxx/1e3,fboxy/1e3,'k')
colorbar
title('g2')



