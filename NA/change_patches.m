global rampg ranges drake Lp Wp smoo Cdinv p
;

load saved_alldat
for j=1:length(saved);
  p=saved(j).p;
  datafiles=saved(j).datafiles;
  Lp=saved(j).Lp;
  Wp=saved(j).Wp;
  smoo=saved(j).smoo;
  xytype=saved(j).xytype;
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
  drange     = diff(ranges,1);
  model       = saved(j).model;

  Lp=10;
  Wp=10;
  Npatch=Lp*Wp;
  [res,slip,resnorm,out,synth]=forward_EQ(model,xytype,resampstruct);
res=data'-synth;
norm(res)
bigid = find(slip(1:Npatch)==max(slip(1:Npatch)));

xref=p.xref;
yref=p.yref;
nramp = size(rampg,1);
ramp  = slip(end-nramp+1:end)'*rampg;
fboxx = [out.xfault]-xref;
fboxy = [out.yfault]-yref;
fboxz = [out.zfault];

mu  = 3.3e10;
mom = sum(abs(slip(1:end-nramp)))*out(1).L*out(1).W*mu;
M0  = mom*1e7;
Mw  = log10(M0)/1.5-10.73



patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,slip(1:Npatch)')
axis image
set(gca,'zdir','reverse')
view(90-out(1).strike,90-out(1).dip)
a=axis;
axis([a(1:4) 0 a(end)])
colorbar,grid on
title(['Mw=' num2str(Mw)])
xlabel('East (km)')
ylabel('North (km)')
zlabel('Depth (km)')


    shading flat


end

