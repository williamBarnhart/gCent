global rampg ranges drake Lp Wp smoo Cdinv p
randn('state',sum(100*clock));
rand('state',sum(100*clock));
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

X     = [resampstruct.X];
Y     = [resampstruct.Y];

ch    = chol(covd);
Cdinv = inv(ch');
sortt  = 0;
EQt    = 0;

for i=1:length(datafiles)
    id    = [1:allnp(i)]+sum(allnp(1:(i-1)));
    rampg = blkdiag(rampg,[(X(id)-min(X(:)));(Y(id)-min(Y(:)));ones(1,allnp(i))]);
end

load test_noise_ADb

donum=50;
startnum=0;

%define search ranges
Npatch     = Lp*Wp;
if(Npatch==1),drake=0;end

[ranges,p] = EQ_defaults(p,Npatch,xytype);
drange     = diff(ranges,1);

%check for norange
no_na   = find(drange==0);
nd      = length(drange);
data   = [resampstruct.data];


totcount   = ns+niter*nn*nr;
alli  = totcount*donum;
s     = 0;
h     = waitbar(s,'','name','running na');

for noisetypes=2:2
for runid = (startnum+[1:donum])+(noisetypes-1)*numnoise
    teststruct = resampstruct;
  runid
    if(runid<=numnoise)
        for j=1:np
            teststruct(j).data = data(j)+noise(j,runid)';
        end
    elseif(runid<=numnoise*2)
        for j=1:np
            teststruct(j).data = data(j)+noise2(j,runid-numnoise)';
        end
%     else
%         for j=1:np
%             teststruct(j).data = data(j)+noiseh(j,runid-numnoise*2)';
%         end
    end
    

    old        = 0;
    startcount = 0;
    misfit     = [];
     %setup initial random model sampling and associated misfits
    if(startcount==0)
        models          = rand(nd,ns);
        models(no_na,:) = 0;
        disp(['Setting up ' num2str(ns) ' initial models'])
        for j=1:ns
            tic
            [res,slip] = forward_EQ(models(:,j),xytype,teststruct);
            misfit(j)  = sum(res(1:np).^2)/np;
            update_time
            EQt=EQt+tmp;
        end
    end

    for i=1:niter
        ntot         = length(misfit);
        disp(['Iteration ' num2str(i) ': Sorting models'])
        tic
        [allmod,rid] = new_na(nr,nn,models,misfit,no_na);
        tmp=toc;
        sortt=sortt+tmp;

        for j=1:nr*nn
            tic
            res            = forward_EQ(allmod(:,j),xytype,teststruct);
            misfit(end+1)  = sum(res(1:np).^2)/np;
            update_time
            EQt=EQt+tmp;
        end
        models       = [models allmod];
    end

    id=find(misfit==min(misfit));
    [res,slip,resnorm,out,synth]=forward_EQ(models(:,id),xytype,resampstruct);
    newimprovemod
    
    saved(runid).patchstruct=out;
    saved(runid).slip=slip;
    saved(runid).Lp=Lp;
    saved(runid).Wp=Wp;
    saved(runid).misfit=misfit(id);
    saved(runid).res=res;
    %saved(runid).synth=synth;
    saved(runid).xytype=xytype;
    saved(runid).p=p;
    saved(runid).smoo=smoo;
    saved(runid).model=models(:,id);
    saved(runid).newmod=newmod;
    saved(runid).datafiles=datafiles;

end
end
   

close(h)

tmp=load('newrun.mat');
oldsaved=tmp.saved;
for noisetypes=2:2
for runid = (startnum+[1:donum])+(noisetypes-1)*numnoise
    oldsaved(runid)=saved(runid);
end
end
saved=oldsaved;
save newrun saved;



%save e
% 
% 
% [res,slip,resnorm,out,synth]=forward_EQ(models(:,id),xytype,resampstruct);
% res=data'-synth;
% bigid = find(slip(1:Npatch)==max(slip(1:Npatch)));
% 
% xref=p.xref;
% yref=p.yref;
% nramp = size(rampg,1);
% ramp  = slip(end-nramp+1:end)'*rampg;
% fboxx = [out.xfault]-xref;
% fboxy = [out.yfault]-yref;
% fboxz = [out.zfault];
% 
% mu  = 3.3e10;
% mom = sum(abs(slip(1:end-nramp)))*out(1).L*out(1).W*mu;
% M0  = mom*1e7;
% Mw  = log10(M0)/1.5-10.73
% 
return

boxx  = [resampstruct.boxx];
boxy  = [resampstruct.boxy];

figure
subplot(2,3,1)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,data)
hold on
axis image,shading flat
c=caxis;
colorbar

subplot(2,3,2)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,synth(1:np)');
axis image,shading flat
hold on
plot(fboxx(:,bigid)/1e3,fboxy(:,bigid)/1e3,'k')
caxis(c)
colorbar
title(['smoothing=' num2str(smoo)])

subplot(2,3,3)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,res(1:np)');
axis image,shading flat
colorbar
title(['res=' num2str(min(misfit))]);

subplot(2,1,2)
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
if(Npatch==1)
    shading faceted
else
    shading flat
end

disp(['Spent ' num2str(round(EQt)) ' seconds on okada and ' num2str(round(sortt)) ' seconds sorting'])

if(old)
    diffmod=oldmod-models(:,id);
    figure
    subplot(2,2,1)
    patch((boxx-xref)/1e3,(boxy-yref)/1e3,res(1:np)');
    axis image,shading flat
    colorbar
    cax=caxis;
    subplot(2,2,2)
    patch((boxx-xref)/1e3,(boxy-yref)/1e3,oldres(1:np)');
    axis image,shading flat
    colorbar
    subplot(2,2,3)
    patch((boxx-xref)/1e3,(boxy-yref)/1e3,oldres(1:np)'-res(1:np)');
    axis image,shading flat
    colorbar
    caxis(cax)
    subplot(2,2,4)
    patch((boxx-xref)/1e3,(boxy-yref)/1e3,oldres(1:np)'-res(1:np)');
    axis image,shading flat
    colorbar



    plot_na(models,misfit,Npatch,xytype,oldmod);
else
    plot_na(models,misfit,Npatch,xytype);
end
