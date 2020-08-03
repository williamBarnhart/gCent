function [dlist,dsum,bestid,mind]=calc_dlist(loc,models,id,dim)

d         = bsxfun(@minus,loc,models);
dsum      = sum(d.^2,1);      %n-dimensional distance^2
dlist     = dsum-d(dim,:).^2; %(n-1) - dimensional distance ^2
dsum(id)  = Inf;
bestid    = find(dsum==min(dsum));
mind      = dsum(bestid);
