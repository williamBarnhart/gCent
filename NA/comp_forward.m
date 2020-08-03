function [misfit,slip,t] = comp_forward(model,xytype,datastruct)
global rampg ranges drake Lp Wp smoo Cdinv p

Npatch = Lp*Wp;
type   = (xytype-1)*2 + ((Npatch~=1)+1);
drange = diff(ranges,1);
model  = ranges(1,:)+drange.*model';
nramp  = size(rampg,1);
%rake convention
%0   = left-lateral ss
%180 = right-lateral ss
%-90 = normal
%90 = thrust
switch type

    case 1
        xref       = p.xref;
        yref       = p.yref;
        
        dr         = model(1);
        angle_ref  = model(2);
        strike     = model(3);
        dip        = model(4);
        rake       = model(5);
        L          = model(6);
        W          = model(7);
        zs         = model(8);

        xs         = xref+dr*sind(angle_ref);
        ys         = yref+dr*cosd(angle_ref);

        x0         = xs+W*cosd(dip)*cosd(strike)/2;
        y0         = ys-W*cosd(dip)*sind(strike)/2;
        z0         = zs+W*sind(dip)/2;

        xt         = x0-W*cosd(dip)*cosd(strike);
        yt         = y0+W*cosd(dip)*sind(strike);
        zt         = z0-W*sind(dip);
        
        
        if(zt<0)
            disp('zt above surface')
        end
        
    case 2
        xref       = p.xref;
        yref       = p.yref;
        Zrange     = p.Zrange;
        
        dr         = model(1);
        angle_ref  = model(2);
        strike     = model(3);
        dip        = model(4);
        rake       = model(5);

        xs         = xref+dr*sind(angle_ref);
        ys         = yref+dr*cosd(angle_ref);
        zt         = min(Zrange);
        z0         = max(Zrange);
        W          = (z0-zt)/sind(dip);
        L          = 20e3;
        xt         = xs-W.*cosd(dip).*cosd(strike)/2;
        yt         = ys+W.*cosd(dip).*sind(strike)/2;
        x0         = xs+W*cosd(dip)*cosd(strike)/2;
        y0         = ys-W*cosd(dip)*sind(strike)/2;

    case 3
        xs         = model(1);
        ys         = model(2);
        strike     = model(3);
        dip        = model(4);
        rake       = model(5);
        L          = model(6);
        W          = model(7);
        zs         = model(8);

        xt         = xs-W*cosd(dip)*cosd(strike)/2;
        yt         = ys+W*cosd(dip)*sind(strike)/2;
        zt         = zs-W*sind(dip)/2;
        x0         = xs+W*cosd(dip)*cosd(strike)/2;
        y0         = ys-W*cosd(dip)*sind(strike)/2;
        z0         = zs+W*sind(dip)/2;

        if(zt<0)
            disp('zt above surface')
        end
        
    case 4
        Zrange     = p.Zrange;
        xs         = model(1);
        ys         = model(2);
        strike     = model(3);
        dip        = model(4);
        rake       = model(5);

        zt         = min(Zrange);
        z0         = max(Zrange);
        W          = (z0-zt)/sind(dip);
        L          = 20e3;
        xt         = xs-W.*cosd(dip).*cosd(strike)/2;
        yt         = ys+W.*cosd(dip).*sind(strike)/2;
        x0         = xs+W*cosd(dip)*cosd(strike)/2;
        y0         = ys-W*cosd(dip)*sind(strike)/2;
 

end

faultstruct = struct('vertices',[xt;yt],'zt',zt,'W',W,'dip',dip,'L',L,'strike',strike);
patchstruct = ver2patchconnect(faultstruct,Lp,Wp,1);
green       = make_green(patchstruct,datastruct);
g1          = green(:,1:Npatch)';
g2          = green(:,Npatch+[1:Npatch])';
rake1       = rake-drake;
rake2       = rake+drake;
data        = [datastruct.data];

if (rake1==rake2)
    green    = cosd(rake1)*g1+sind(rake1)*g2;
    smooth1  = smoother(1,patchstruct);
    smooth2  = diag(ones(1,Lp*Wp));
    nparams  = Npatch;
else
    ga       = cosd(rake1)*g1+sind(rake1)*g2;
    gb       = cosd(rake2)*g1+sind(rake2)*g2;
    green    = [ga gb];
    smooth1  = smoother(2,patchstruct);
    smooth2   = diag(ones(1,Lp*Wp*2));
    nparams  = Npatch*2;
end

smoos=10.^[-3:0.25:1];

for j=1:length(smoos)
    smoo=smoos(j);

    Gsmoo1 = [Cdinv*[green;rampg]';smoo*smooth1 zeros(nparams,nramp)];
    Gsmoo2 = [Cdinv*[green;rampg]';smoo*smooth2 zeros(nparams,nramp)];

    dsmoo = [Cdinv*data'; zeros(nparams,1)];
    LB    = [0*ones(1,nparams)   -100*ones(1,nramp)];
    UB    = [inf*ones(1,nparams)  100*ones(1,nramp)];
    A     = diag([-1*ones(1,nparams) zeros(1,nramp)]);
    b     = zeros(1,nparams+nramp);
    
    options=optimset('display','off','LargeScale','off');
    %    [slip,misfit,res]   = lsqlin(Gsmoo,dsmoo);
    %    slip(slip<0)=0;
    tic
    [slip(1,j,:),misfit(j,1),res]   = lsqlin(Gsmoo1,dsmoo,[],[],[],[],LB,UB,[],options);
    t(1,j)=toc;tic;
    [slip(2,j,:),misfit(j,2),res]   = lsqlin(Gsmoo1,dsmoo,[],[],[],[],LB,UB,[squeeze(slip(1,j,:))],options);
    t(2,j)=toc;tic;
    [slip(3,j,:),misfit(j,3),res]   = lsqlin(Gsmoo1,dsmoo,A,b,[],[],[],[],[],options);
t(3,j)=toc;tic;
    [slip(4,j,:),misfit(j,4),res]   = lsqlin(Gsmoo2,dsmoo,[],[],[],[],LB,UB,[],options);
t(4,j)=toc;tic;
    [slip(5,j,:),misfit(j,5),res]   = lsqlin(Gsmoo2,dsmoo,[],[],[],[],LB,UB,[squeeze(slip(4,j,:))],options);
    t(5,j)=toc;tic;
    [slip(6,j,:),misfit(j,6),res]   = lsqlin(Gsmoo2,dsmoo,A,b,[],[],[],[],[],options);
  t(6,j)=toc;
    %synth=[green;rampg]'*slip;
end
fboxx = [patchstruct.xfault];
fboxy = [patchstruct.yfault];
fboxz = [patchstruct.zfault];

figure
for j=1:6
    subplot(2,3,j)
patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,squeeze(slip(j,end-4,1:Npatch))')
axis image
set(gca,'zdir','reverse')
view(90-patchstruct(1).strike,90-patchstruct(1).dip)
colorbar,grid on
shading flat
end
