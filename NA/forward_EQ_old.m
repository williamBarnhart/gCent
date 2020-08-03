function [res,slip,misfit,out,synth,g1,g2,green,Gsmoo,dsmoo] = forward_EQ(model,xytype)
global X Y S data rampg ranges drake Lp Wp smoo Cdinv p

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

        xt         = xs-W*cosd(dip)*cosd(strike)/2;
        yt         = ys+W*cosd(dip)*sind(strike)/2;
        zt         = zs-W*sind(dip)/2;
        x0         = xs+W*cosd(dip)*cosd(strike)/2;
        y0         = ys-W*cosd(dip)*sind(strike)/2;
        z0         = zs+W*sind(dip)/2;

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

dL         = L/Lp;
dW         = W/Wp;
dx         = (xt-x0)/Wp;
dy         = (yt-y0)/Wp;

lsx = [dx-dL/2*sind(strike) dx+dL/2*sind(strike) dL/2*sind(strike) -dL/2*sind(strike) dx-dL/2*sind(strike)]';
lsy = [dy-dL/2*cosd(strike) dy+dL/2*cosd(strike) dL/2*cosd(strike) -dL/2*cosd(strike) dy-dL/2*cosd(strike)]';
lsz = [-dW*sind(dip) -dW*sind(dip) 0 0 -dW*sind(dip)]';
tsx = [(xt-x0)-L/2*sind(strike) (xt-x0)+L/2*sind(strike) L/2*sind(strike) -L/2*sind(strike) (xt-x0)-L/2*sind(strike)]';
tsy = [(yt-y0)-L/2*cosd(strike) (yt-y0)+L/2*cosd(strike) L/2*cosd(strike) -L/2*cosd(strike) (yt-y0)-L/2*cosd(strike)]';
tsz = [-W*sind(dip) -W*sind(dip) 0 0 -W*sind(dip)]';

for i=1:Wp
    x0c = xt-dx*(i);
    y0c = yt-dy*(i);
    z0p = z0-dW*(Wp-i).*sind(dip);
    for j=1:Lp
        id     = i*Lp-j+1;
        lsin   = (L/2-dL*(j-.5)).*sind(strike);
        lcos   = (L/2-dL*(j-.5)).*cosd(strike);
        x0p    = x0c+lsin;
        y0p    = y0c+lcos;
        [ux,uy,uz]  = calc_okada(1,X-x0p,Y-y0p,.25,dip,z0p,dL,dW,1,strike);
        g1(id,:)    = ux.*S(1,:)+uy.*S(2,:)+uz.*S(3,:);
        [ux,uy,uz]  = calc_okada(1,X-x0p,Y-y0p,.25,dip,z0p,dL,dW,2,strike);
        g2(id,:)    = ux.*S(1,:)+uy.*S(2,:)+uz.*S(3,:);
        if(nargout>=4)
            out(id).x0=x0p;
            out(id).y0=y0p;
            out(id).z0=z0p;
            out(id).strike=strike;
            out(id).dip=dip;
            out(id).L=dL;
            out(id).W=dW;
            out(id).boxx=x0p+lsx;
            out(id).boxy=y0p+lsy;
            out(id).boxz=z0p+lsz;
            out(id).tboxx=x0+tsx;
            out(id).tboxy=y0+tsy;
            out(id).tboxz=z0+tsz;
        end
    end
end

rake1 = rake-drake;
rake2 = rake+drake;
if (rake1==rake2)
    green    = cosd(rake1)*g1+sind(rake1)*g2;
    smooth   = diag(ones(1,Lp*Wp));
    nparams  = Npatch;
else
    ga       = cosd(rake1)*g1+sind(rake1)*g2;
    gb       = cosd(rake2)*g1+sind(rake2)*g2;
    green    = [ga gb];
    smooth   = diag(ones(1,Lp*Wp*2));
    nparams  = Npatch*2;
end


if(Npatch==1)
    %Gsmoo = [green;rampg]';
    %dsmoo = data;
    %[slip,misfit,res]   = lsqlin(Gsmoo,dsmoo);
   
    Gsmoo = Cdinv*[green;rampg]';
    dsmoo = Cdinv*data';
    [slip,misfit,res]   = lsqlin(Gsmoo,dsmoo);
   
else
    Gsmoo = [Cdinv*[green;rampg]';smoo*smooth zeros(nparams,nramp)];

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
    [slip,misfit,res]=lsqlin(Gsmoo,dsmoo,A,b,[],[],[],[],[],options);
end

synth=[green;rampg]'*slip;


