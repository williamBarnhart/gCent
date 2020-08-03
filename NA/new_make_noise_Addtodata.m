randn('state',sum(100*clock));
rand('state',sum(100*clock));
run_na_params %Must be in data where you are running NA

%initialize arrays
numnoise = 200;
np           = 0;
resampstruct = [];
covd         = [];
covd2        = [];
covdh        = [];
modnum       = [];
saved        = [];
rampg        = [];

for i=1:length(datafiles)
    load(datafiles{i})
    allnp(i)     = savestruct.np;
    resampstruct = [resampstruct savestruct.data];
    tmpcov=savestruct.covstruct.cov;
    tmpcov2=savestruct.covstruct2.cov;
    tmpcovh=savestruct.covstructh.cov;
    %tmpcov=diag(diag(tmpcov));
    covd         = blkdiag(covd,tmpcov);
    covd2        = blkdiag(covd2,tmpcov2);
    covdh        = blkdiag(covdh,tmpcovh);
    clear tmpcov tmpcov2 tmpcovh
end
np    = sum(allnp);
X     = [resampstruct.X];
Y     = [resampstruct.Y];
boxx  = [resampstruct.boxx];
boxy  = [resampstruct.boxy];
synth = [resampstruct.data];

for i=1:length(datafiles)
    id    = [1:allnp(i)]+sum(allnp(1:(i-1)));
    rampg = blkdiag(rampg,[(X(id)-min(X(:)));(Y(id)-min(Y(:)));ones(1,allnp(i))]);
end


noise       = corr_noise(covd,numnoise);
noise2      = corr_noise(covd2,numnoise);
noiseh      = corr_noise(covdh,numnoise);

save test_noise_ADb synth noise noise2 noiseh numnoise modnum saved datafiles
