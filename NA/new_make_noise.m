run_na_params %Must be in data where you are running NA

%initialize arrays
np           = 0;
resampstruct = [];
covd         = [];
covd2        = [];
covdh        = [];

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

for i=1:length(datafiles)
    id    = [1:allnp(i)]+sum(allnp(1:(i-1)));
    rampg = blkdiag(rampg,[(X(id)-min(X(:)));(Y(id)-min(Y(:)));ones(1,allnp(i))]);
end

load saved_models
modnum   = 1;
numnoise = 100;

patchstruct = saved(modnum).patchstruct;
slip        = saved(modnum).slip;
Npatch      = length(patchstruct);
green       = make_green(patchstruct,resampstruct);
g1          = green(:,1:Npatch)';
g2          = green(:,Npatch+[1:Npatch])';
rake1       = [patchstruct.rake1];
rake2       = [patchstruct.rake2];

if (rake1==rake2)
    green    = cosd(rake1)*g1+sind(rake1)*g2;
else
    ga       = cosd(rake1)*g1+sind(rake1)*g2;
    gb       = cosd(rake2)*g1+sind(rake2)*g2;
    green    = [ga gb];
end
green       = [green;rampg];

synth       = repmat(green'*slip,1,numnoise);
noise       = corr_noise(covd,numnoise);
noise2      = corr_noise(covd2,numnoise);
noiseh      = corr_noise(covdh,numnoise);

save test_noise synth noise noise2 noiseh numnoise modnum saved datafiles
