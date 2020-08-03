global rampg ranges drake Lp Wp smoo Cdinv p

run_na_params %Must be in data where you are running NA

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


load saved_models_T242b_rakefix
n=length(saved);
figure
fbx=[];
fby=[];
fbz=[];
sx=[];
sy=[];
sz=[];

for i=1:n
    patchstruct = saved(i).patchstruct;
    slip        = saved(i).slip;
    Lp          = saved(i).Lp;
    Wp          = saved(i).Wp;
    misfit      = saved(i).misfit;
    res         = saved(i).res;
    synth       = saved(i).synth;
    p           = saved(i).p;
    model       = saved(i).model;
    Npatch      = Lp*Wp;
    fboxx = [patchstruct.xfault];
    fboxy = [patchstruct.yfault];
    fboxz = [patchstruct.zfault];
    fbx   = [fbx mean(fboxx(1:4,:),1)];
    fby   = [fby mean(fboxy(1:4,:),1)];
    fbz   = [fbz mean(fboxz(1:4,:),1)];
    
    rake1  = [patchstruct.rake1];
    rake2  = [patchstruct.rake2];
    strike = [patchstruct.strike];
    dip    = [patchstruct.dip];
    
    slip = slip(1:Npatch)';
    
    sds=slip.*sind(rake1);
    sss=slip.*cosd(rake1);

    sx=[sx sss.*sind(strike)-sds.*cosd(dip).*cosd(strike)];
    sy=[sy sss.*cosd(strike)+sds.*cosd(dip).*sind(strike)];
    sz=[sz -sds.*sind(dip)];
   

    if(Npatch==1),drake=0;end
    [ranges,p] = EQ_defaults(p,Npatch,xytype);
    drange     = diff(ranges,1);
    
    [newmod,newresn,newres]=lsqnonlin('forward_EQ',model,[],[],[],xytype,resampstruct);
    [model newmod]
    [norm(res) newresn]
    %[oldres,oldslip,oldresnorm,out,oldsynth]=forward_EQ(models(:,id),xytype,resampstruct);

    %patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,slip(1:Npatch)')
    plot3(fboxx/1e3,fboxy/1e3,fboxz/1e3,'k')
    hold on
    if(Npatch==1)
        patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,norm(res));
    end
    axis image
    set(gca,'zdir','reverse')
    view(90-strike(1),90-dip(1))
   

end
quiver3(fbx/1e3,fby/1e3,fbz/1e3,sx,sy,sz)
grid on
colorbar