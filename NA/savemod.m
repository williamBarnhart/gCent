
filename='saved_models_T435b.mat';
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
save(filename,'saved')
