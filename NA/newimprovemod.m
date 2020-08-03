model=models(:,id);
xref=p.xref;
yref=p.yref;
nramp = size(rampg,1);
ramp  = slip(end-nramp+1:end)'*rampg;
    
[newmod]=lsqnonlin('forward_EQ',model,[zeros(size(model))],[ones(size(model))],[],xytype,resampstruct);
[model newmod];
[oldres,oldslip,oldresnorm,oldout,oldsynth]=forward_EQ(model,xytype,resampstruct);
[newres,newslip,newresnorm,newout,newsynth]=forward_EQ(newmod,xytype,resampstruct);
%return

oldres=data'-oldsynth;
fboxx = [oldout.xfault]-xref;
fboxy = [oldout.yfault]-yref;
fboxz = [oldout.zfault];
figure

subplot(2,2,1)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,oldres(1:np)');
axis image,shading flat
colorbar
title(['res=' num2str(oldresnorm)]);

subplot(2,2,2)
patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,oldslip(1:Npatch)')
axis image
set(gca,'zdir','reverse')
view(90-oldout(1).strike,90-oldout(1).dip)
a=axis;
axis([a(1:4) 0 a(end)])
colorbar,grid on
xlabel('East (km)')
ylabel('North (km)')
zlabel('Depth (km)') 
 


    
newres=data'-newsynth;
fboxx = [newout.xfault]-xref;
fboxy = [newout.yfault]-yref;
fboxz = [newout.zfault];


subplot(2,2,3)
patch((boxx-xref)/1e3,(boxy-yref)/1e3,newres(1:np)');
axis image,shading flat
colorbar
title(['res=' num2str(newresnorm)]);

subplot(2,2,4)
patch(fboxx/1e3,fboxy/1e3,fboxz/1e3,newslip(1:Npatch)')
axis image
set(gca,'zdir','reverse')
view(90-newout(1).strike,90-newout(1).dip)
a=axis;
axis([a(1:4) 0 a(end)])
colorbar,grid on
xlabel('East (km)')
ylabel('North (km)')
zlabel('Depth (km)') 

plot_na(models,misfit,Npatch,xytype,newmod);