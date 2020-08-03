function [naPlotH] = plot_na(models,misfits,Npatch,xytype,old)
global ranges
if(nargin<3)
  Npatch=0;
  xytype=1;
end
type   = (xytype-1)*2 + ((Npatch~=1)+1);

drange = diff(ranges,1);
b      = sort(misfits);
n      = length(misfits);
cutoff = b(ceil(n/3));
%cutoff = max(misfits);

for i=1:length(drange)
  models(i,:) = ranges(1,i)+drange(i)*models(i,:);
    if(nargin==5)
        oldmodel(i)=ranges(1,i)+drange(i)*old(i);
    end
end
index  = find(misfits==min(misfits));

if (length(index)>1)
  index=index(1) 
end

switch type
    case 1
        labels={'dr','angle','strike','dip','rake','L','W','zs'};
        ni=3;
        nj=3;
        nm=9;
    case 2
        labels={'dr','angle','strike','dip','rake'};
        ni=3;
        nj=2;
        nm=6;
    case 3
        labels={'xs','ys','strike','dip','rake','L','W','zs'};
        ni=3;
        nj=3;
        nm=9;
    case 4
        labels={'xs','ys','strike','dip','rake'};
        ni=4;
        nj=6;
        nm=6;
    case 5
        labels={'dr','angle','strike','dip','rake','area','aspect','zs'};
        ni=3;
        nj=3;
        nm=9;
    case 6
        labels={'dr','angle','strike','dip','rake'};
        ni=3;
        nj=2;
        nm=6;
end

  
naPlotH = figure;
for j=1:length(drange)
  subplot(ni,nj,j)
  plot(models(j,:),misfits,'.')
  hold on
  a=axis;
  if(drange(j)>0)
      axis([ranges(1,j) ranges(2,j) min(misfits) cutoff])
  end
  a=axis;
  title([labels{j} '=' num2str(round(models(j,index)))])
  if(nargin==5)
      plot([oldmodel(j) oldmodel(j)],a(3:4),'r')
  end
  
end

subplot(ni,nj,nm)
plot(misfits,'.')
title('misfit')
axis tight


