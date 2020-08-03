function [allmod,resampmodid]=new_na(nr,nn,models,misfit,no_na)

maxn         = 5000;
[nd,ntot]    = size(models);
[tmp,sortid] = sort(misfit,'ascend');
if(ntot>maxn)
    disp([num2str(ntot) ' models, just using best ' num2str(maxn)])
    misfit       = misfit(sortid(1:ntot));
    models       = models(:,sortid(1:ntot));
    [nd,ntot]    = size(models);
    [tmp,sortid] = sort(misfit,'ascend');
end
r            = randperm(nr);
resampmodid  = (sortid(r));
allmod       = zeros(nd,nn*nr);
dimid        = randperm(nd);
dimid        = dimid(~ismember(dimid,no_na));

id=0;
for i=resampmodid
    loc    = models(:,i);
    d      = bsxfun(@minus,loc,models);
    ds     = d.^2;

    for l=1:nn
        id=id+1;
        for k=dimid
            dlist  = sum(ds,1)-ds(k,:);
            d1     = models(k,i)+models(k,:);
            d2     = dlist(i)-dlist;
            d3     = models(k,i)-models(k,:);
            xji    = (d1+d2./d3)/2;
            xji(i) = NaN;
            below  = xji(xji<loc(k));
            above  = xji(xji>loc(k));
         
            lb = max([0 below]);
            ub = min([1 above]);
            db = ub-lb;
            
            r      = rand(1);
            diff   = lb+db*r-loc(k);
            loc(k) = loc(k)+diff;
            d(k,:) = d(k,:)+diff;
            ds     = d.^2;

        end
        allmod(:,id)=loc;
    end
end



