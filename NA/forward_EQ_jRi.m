function [res,slip,jRi,patchstruct,synth,g1,g2,green,Gsmoo,dsmoo] = forward_EQ_jRi(model,xytype,datastruct,startslip)
global rampg ranges drake Lp Wp smoo Cdinv p covd2

L      = 30e3;
Npatch = Lp*Wp;
type   = (xytype-1)*2 + ((Npatch~=1)+1);
drange = diff(ranges,1);
model  = ranges(1,:)+drange.*model';
nramp  = size(rampg,1);
np     = length(datastruct);
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
        %L          = 20e3;
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
        %L          = 20e3;
        xt         = xs-W.*cosd(dip).*cosd(strike)/2;
        yt         = ys+W.*cosd(dip).*sind(strike)/2;
        x0         = xs+W*cosd(dip)*cosd(strike)/2;
        y0         = ys-W*cosd(dip)*sind(strike)/2;

    case 5
        xref       = p.xref;
        yref       = p.yref;
        
        dr         = model(1);
        angle_ref  = model(2);
        strike     = model(3);
        dip        = model(4);
        rake       = model(5);
        area       = model(6);
        asp        = model(7);
        zs         = model(8);
        asp        = 10^asp;
        L          = sqrt(area/asp);
        W          = L*asp;
        
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
       
    case 6
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
        %L          = 20e3;
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
[patchstruct.rake1]=deal([rake1]);
[patchstruct.rake2]=deal([rake2]);


if (rake1==rake2)
    green    = cosd(rake1)*g1+sind(rake1)*g2;
    if(Npatch>1)
        smooth   = smoother(1,patchstruct);
    end
     %   smooth   = diag(ones(1,Lp*Wp));
    nparams  = Npatch;
else
    ga       = cosd(rake1)*g1+sind(rake1)*g2;
    gb       = cosd(rake2)*g1+sind(rake2)*g2;
    green    = [ga gb];
    if(Npatch>1)
        smooth   = smoother(2,patchstruct);
    end
    %smooth   = diag(ones(1,Lp*Wp*2));
    nparams  = Npatch*2;
end

scaleval=mean(abs(green(:)))/mean(abs(rampg(:)));
green=green/scaleval;
%data=data/scaleval;


if(Npatch==1)
    %Gsmoo = [green;rampg]';
    %dsmoo = data;
    %[slip,misfit,res]   = lsqlin(Gsmoo,dsmoo);
   
    Gsmoo = Cdinv*[green;rampg]';
    dsmoo = Cdinv*data';    

%     [slip,misfit,res]   = lsqlin(Gsmoo,dsmoo);
    [slip, misfit,ril] = lsqlin(Gsmoo,dsmoo);
    Gg = inv(Gsmoo'*Gsmoo)*Gsmoo';
    N  = Gsmoo*Gg;
    M   = [eye(np) -N];
    iRi = sum(ril(1:np).^2)/np;
    covresjRi = M*M';
    covresiRi  = M*covd2*M';
    jRin       = mean(diag(covresjRi));
    iRin        = mean(diag(covresiRi));
    oRo         = iRi-iRin;
    jRi         = oRo+jRin;
    res = ril;
    
    slip(1:nparams)=slip(1:nparams)/scaleval;
    
else

    Gsmoo = [Cdinv*[green;rampg]';smoo*smooth/scaleval zeros(nparams,nramp)];
  
    dsmoo = [Cdinv*data'; zeros(nparams,1)];
    LB    = [0*ones(1,nparams)   -100*ones(1,nramp)];
    UB    = [inf*ones(1,nparams)  100*ones(1,nramp)];
    A     = diag([-1*ones(1,nparams) zeros(1,nramp)]);
    b     = zeros(1,nparams+nramp);
    
    options=optimset('display','off','LargeScale','off');
%    [slip,misfit,res]   = lsqlin(Gsmoo,dsmoo);
%    slip(slip<0)=0;
    %[slip,misfit,res]   = lsqlin(Gsmoo,dsmoo,[],[],[],[],LB,UB,[],options);
    %[slip,misfit,res]   = lsqlin(Gsmoo,dsmoo,[],[],[],[],LB,UB,[slip],options);
    if(nargin==4)
        startslip(1:nparams)=startslip(1:nparams)*scaleval;
        [slip,misfit,res]=lsqlin(Gsmoo,dsmoo,A,b,[],[],[],[],[startslip],options);
    else
        [slip,misfit,res]=lsqlin(Gsmoo,dsmoo,A,b,[],[],[],[],[],options);
    end
    slip(1:nparams)=slip(1:nparams)/scaleval;
end

green=green*scaleval;
%data=data*scaleval;
%rampg=rampg*scaleval;
synth=[green;rampg]'*slip;
