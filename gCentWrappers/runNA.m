function runNA(gCentFile)

run(gCentFile);

display(['Running Neighbourhood Algorithm for single patch solution for eventID ' eventID])
pause(3)

writeRunNAIn(gCentFile);

STARTDIR    = pwd;
NADIR       = [WORKDIR '/NA'];
cd(NADIR)
pid         = datenum(datetime('now'));
NA_EQ_inverter
close all
% NA_EQ_inverter

saveDir = [NADIR '/run_' num2str(pid)];
mkdir([NADIR '/run_' num2str(pid)])
plotNAresults
save([NADIR '/run_' num2str(pid) '/NAinversion.mat'],'out','synth','slip','Mw','datafiles');
savegCentOutputs(out, slip, Mw, zone, saveDir);

cd(STARTDIR);
