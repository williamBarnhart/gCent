global rampg ranges drake Lp Wp smoo Cdinv p
load('a5_1.mat');
patchstruct = saved(1).patchstruct;
p           = saved(1).p;
xytype      = saved(1).xytype;
slip        = saved(1).slip;
Lp          = saved(1).Lp;
Wp          = saved(1).Wp;
misfit      = saved(1).misfit;
res         = saved(1).res;
synth       = saved(1).synth;
model       = saved(1).model;
%datafiles   = saved(1).datafiles;
datafiles   = {'../T435/051124-051229.mat'};
xref=p.xref;
yref=p.yref;
Lp=3;
Wp=3;
p.Zrange = [3e3 8e3];
drake        = 0;
np           = 0;
resampstruct = [];
covd         = [];
rampg        = [];

for i=1:length(datafiles)
    load(datafiles{i})
    allnp(i)     = savestruct.np;
    resampstruct = [resampstruct savestruct.data];
    tmpcov=savestruct.covstruct.cov;
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

Npatch      = Lp*Wp;
[ranges,p] = EQ_defaults(p,Npatch,xytype);
drange     = diff(ranges,1);


for i=1:length(datafiles)
    id    = [1:allnp(i)]+sum(allnp(1:(i-1)));
    rampg = blkdiag(rampg,[(X(id)-min(X(:)));(Y(id)-min(Y(:)));ones(1,allnp(i))]);
end
nramp = size(rampg,1);

mu  = 3.3e10;
smoos=10.^[1:-0.25:-0.5];
slip=zeros(Npatch+nramp,1);
j=ceil(length(smoos)/2);
figure
for smooid=1:length(smoos)
    smoo =smoos(smooid);
    
    [res,slip,resnorm(smooid),out,synth]=forward_EQ(model,xytype,resampstruct,slip);
fboxx = [out.xfault];
fboxy = [out.yfault];
fboxz = [out.zfault];

res=data'-synth;
    roughs(smooid)=norm(slip(1:end-nramp));
    mom = sum(abs(slip(1:end-nramp)))*out(1).L*out(1).W*mu;
    M0  = mom*1e7;
    Mw(smooid) = log10(M0)/1.5-10.73;

  
    subplot(j,4,smooid*2-1)
    patch((boxx-xref)/1e3,(boxy-yref)/1e3,res(1:np)');
    axis image,shading flat
    colorbar
    title(['res=' num2str(resnorm(smooid))]);
    
    subplot(j,4,smooid*2)
    patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,slip(1:Npatch)')
    axis image
    set(gca,'zdir','reverse')
    view(90-patchstruct(1).strike,90-patchstruct(1).dip)
    a=axis;
    axis([a(1:4) 0 a(end)])
    colorbar,grid on
    title(['Mw=' num2str(Mw(smooid))])
    xlabel('East (km)')
    ylabel('North (km)')
    zlabel('Depth (km)')

    shading flat


end

figure
plot(resnorm,roughs,'.-')

