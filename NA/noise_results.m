global rampg ranges drake Lp Wp smoo Cdinv p

files={'d.mat','e.mat'};

for fileid=1:length(files)
    load(files{fileid});
   x=(fileid-1)*numnoise;
    for i=1:numnoise
        id=best(i).id;
        model1(i+x,:)=best(i).mod(:,id)'.*drange+ranges(1,:);
        mis1(i+x)=best(i).misfit(id);
        id=best(i+numnoise).id;
        model2(i+x,:)=best(i+numnoise).mod(:,id)'.*drange+ranges(1,:);
        mis2(i+x)=best(i+numnoise).misfit(id);
    end
end
   
id=1:length(mis1);
figure
subplot(2,2,1)
plot(model1(id,1),model1(id,2),'.')
hold on
plot(model2(id,1),model2(id,2),'r.')

subplot(2,2,2)
plot(model1(id,3),mis1(id),'.')
hold on
plot(model2(id,3),mis2(id),'r.')

subplot(2,2,3)
plot(model1(id,4),mis1(id),'.')
hold on
plot(model2(id,4),mis2(id),'r.')

subplot(2,2,4)
plot(model1(id,5),mis1(id),'.')
hold on
plot(model2(id,5),mis2(id),'r.')

%save threeinvert model1 model2 mis1 mis2