global rampg ranges drake Lp Wp smoo Cdinv p



if(exist('models','var'))
    old        = 1;
    startcount = size(models,2);
    totcount   = niter*nn*nr;
    disp(['Beginning with ' num2str(startcount) ' previous models']);   
else
    run_na_params %Must be in data where you are running NA
    old        = 0;
    totcount   = ns+niter*nn*nr;
    startcount = 0;
end
niter;
%[datafiles Lp]
%smoo
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
load synth_dif_rake.mat
np    = sum(allnp);
data  = synth';
clear synth
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

if(old)
    id     = find(misfit==min(misfit));
    oldmod = models(:,id);
    [oldres,oldslip,oldresnorm,out,oldsynth]=forward_EQ(models(:,id),xytype,resampstruct);
    oldres = data'-oldsynth;
end

%check for norange
no_na   = find(drange==0);
nd      = length(drange);


alli  = totcount;
s     = 0;
h     = waitbar(s,'','name','running na');

%setup initial random model sampling and associated misfits
if(startcount==0)
    models          = rand(nd,ns);
    models(no_na,:) = 0;
    disp(['Setting up ' num2str(ns) ' initial models'])
    for j=1:ns
        tic
        [res,slip] = forward_EQ(models(:,j),xytype,resampstruct);
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
    res            = forward_EQ(allmod(:,j),xytype,resampstruct);
    misfit(end+1)  = sum(res(1:np).^2)/np;
    update_time
    EQt=EQt+tmp;
  end
  models       = [models allmod];   
end
close(h)

id=find(misfit==min(misfit));
[res,slip,resnorm,out,synth]=forward_EQ(models(:,id),xytype,resampstruct);
res=data'-synth;
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


%return
if(0)
    figure
    subplot(2,2,1)
    n=np/2;
    quiver((X(1:n)-xref)/1e3,(Y(1:n)-yref)/1e3,data(1:n),data([1:n]+n))
    axis image

    subplot(2,2,2)
    quiver((X(1:n)-xref)/1e3,(Y(1:n)-yref)/1e3,synth(1:n)',synth(n+[1:n])');
    axis image
    title(['smoothing=' num2str(smoo)])

    subplot(2,2,3)
    quiver((X(1:n)-xref)/1e3,(Y(1:n)-yref)/1e3,res(1:n)',res([1:n]+n)');
    axis image
    title(['res=' num2str(min(misfit))]);
else
    figure
    for i=1:length(datafiles)
        ids=[(1+sum(allnp(1:i-1))):sum(allnp(1:i))];

        subplot(length(datafiles),3,1+(i-1)*3)
        patch((boxx(:,ids)-xref)/1e3,(boxy(:,ids)-yref)/1e3,data(ids))
        hold on
        axis image,shading flat
        c=caxis;
        colorbar

        subplot(length(datafiles),3,2+(i-1)*3)
        patch((boxx(:,ids)-xref)/1e3,(boxy(:,ids)-yref)/1e3,synth(ids)');
        axis image,shading flat
        hold on
        plot(fboxx(:,bigid)/1e3,fboxy(:,bigid)/1e3,'k')
        caxis(c)
        colorbar
        title(['smoothing=' num2str(smoo)])

        subplot(length(datafiles),3,3+(i-1)*3)
        patch((boxx(:,ids)-xref)/1e3,(boxy(:,ids)-yref)/1e3,res(ids)');
        axis image,shading flat
        colorbar
        title(['res=' num2str(sum(res(ids).^2))]);
    end
    figure
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
    title('new res')
    subplot(2,2,2)
    patch((boxx-xref)/1e3,(boxy-yref)/1e3,oldres(1:np)');
    axis image,shading flat
    colorbar
    title('old res')
    subplot(2,2,3)
    patch((boxx-xref)/1e3,(boxy-yref)/1e3,oldres(1:np)'-res(1:np)');
    axis image,shading flat
    colorbar
    caxis(cax)
    title('res diff, same caxis')
    subplot(2,2,4)
    patch((boxx-xref)/1e3,(boxy-yref)/1e3,oldres(1:np)'-res(1:np)');
    axis image,shading flat
    colorbar
    title('res diff, full caxis')



    plot_na(models,misfit,Npatch,xytype,oldmod);
else
    plot_na(models,misfit,Npatch,xytype);
end
