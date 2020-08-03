
%load saved_models_T242b
load saved_alldat
n=length(saved);
%figure
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
%    synth       = saved(i).synth;
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
    sn(i)=sum(slip);
    fx1(i)=sum(mean(fboxx(1:4,:),1).*slip)/sn(i);
    fy1(i)=sum(mean(fboxy(1:4,:),1).*slip)/sn(i);
    fz1(i)=sum(mean(fboxz(1:4,:),1).*slip)/sn(i);
   
    
    sds=slip.*sind(rake1);
    sss=slip.*cosd(rake1);

    sx=[sx sss.*sind(strike)-sds.*cosd(dip).*cosd(strike)];
    sy=[sy sss.*cosd(strike)+sds.*cosd(dip).*sind(strike)];
    sz=[sz -sds.*sind(dip)];
    
    
    patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,slip(1:Npatch)),shading flat
    hold on
   % plot3(fboxx/1e3,fboxy/1e3,fboxz/1e3,'k')
    hold on
    %if(Npatch==1)
    %    patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,norm(res));
    %end
    axis image
    set(gca,'zdir','reverse')
    view(90-strike(1),90-dip(1))
    disp(norm(res))
end

%quiver3(fbx/1e3,fby/1e3,fbz/1e3,sx,sy,sz)
grid on
colorbar