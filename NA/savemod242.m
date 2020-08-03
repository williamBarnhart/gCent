
%filename='saved_models_T242b_rakefix.mat';
if(exist(filename,'file'))
    load(filename);
    n=length(saved)+1;
else
    n=1;
end

saved(n).patchstruct=out;
saved(n).slip=slip;
saved(n).Lp=Lp;
saved(n).Wp=Wp;
saved(n).misfit=misfit(id);
saved(n).res=res;
saved(n).synth=synth;
saved(n).xytype=xytype;
saved(n).p=p;
saved(n).smoo=smoo;
saved(n).model=models(:,id);
%saved(n).newmod=newmod;
saved(n).datafiles=datafiles;
save(filename,'saved')
