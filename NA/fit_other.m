global rampg ranges drake Lp Wp smoo Cdinv p
%allfiles={'a1.mat','a2.mat','a3.mat','a4.mat'};
alldatafiles={'../T435/051124-051229.mat','../T242/040708-051215.mat','../T328/050105-051221.mat','../T328/050525-060125.mat'};

load saved_alldat
for i=1:length(saved);
    figure
%    load(allfiles{i});
    
    patchstruct = saved(i).patchstruct;
    p           = saved(i).p;
    xytype      = saved(i).xytype;
    slip        = saved(i).slip;
    Lp          = saved(i).Lp;
    Wp          = saved(i).Wp;
    model       = saved(i).model;
     Npatch      = Lp*Wp;
    [ranges,p] = EQ_defaults(p,Npatch,xytype);
    drange     = diff(ranges,1);
    model  = ranges(1,:)+drange.*model';
    rake   = model(5);
    
    xref=p.xref;
    yref=p.yref;

    for j=1:length(alldatafiles)

 

        load(alldatafiles{j})
        np     = savestruct.np;
        resampstruct = [savestruct.data];
        green       = make_green(patchstruct,resampstruct);
        g1          = green(:,1:Npatch)';
        g2          = green(:,Npatch+[1:Npatch])';
        green    = cosd(rake)*g1+sind(rake)*g2;

        
       
        data  = [resampstruct.data];
        boxx  = [resampstruct.boxx];
        boxy  = [resampstruct.boxy];
        X     = [resampstruct.X];
        Y     = [resampstruct.Y];
        rampg = [(X-min(X(:)));(Y-min(Y(:)));ones(1,np)];
 synth       = slip'*[green;rampg];

        res   = data-synth;
        subplot(2,2,j)
        patch((boxx-xref)/1e3,(boxy-yref)/1e3,res(1:np));
        axis image,shading flat
    end
end
