function [ranges,p]=EQ_defaults(p,Npatch,xytype)


if isempty(p.radius), p.radius = [0 10e3];end
if isempty(p.angle),  p.angle  = [0 360];end
if isempty(p.strike), p.strike = [0 360];end
if isempty(p.dip),    p.dip    = [0 90];end
if isempty(p.rake),   p.rake   = [-180 180];end
if isempty(p.L),      p.L      = [0 10e3];end
if isempty(p.W),      p.W      = [0 10e3];end
if isempty(p.zs),     p.zs     = [5 15e3];end
if isempty(p.Zrange), p.Zrange = [0 15e3];end
if isempty(p.area),   p.area   = [0 100e6];end
if isempty(p.asp),    p.asp    = [-1 1];end


if(xytype == 1)
    if(or(isempty(p.xref),isempty(p.yref)))
        disp('should set xref and yref target value if xytype==1')
    else
        if(Npatch == 1)
            ranges = [p.radius' p.angle' p.strike' p.dip' p.rake' p.L' p.W' p.zs'];
        elseif(Npatch>1)
            ranges = [p.radius' p.angle' p.strike' p.dip' p.rake'];
        end
    end
elseif(xytype==2)
    if (or(isempty(p.xs),isempty(p.ys)))
        disp('should set xs and ys ranges if xytype==2)')
    else
        if(Npatch == 1)
            ranges = [p.xs' p.ys' p.strike' p.dip' p.rake' p.L' p.W' p.zs'];
        elseif(Npatch>1)
            ranges = [p.xs' p.ys' p.strike' p.dip' p.rake'];
        end
    end
    p.xref=mean(p.xs);
    p.yref=mean(p.ys);
elseif(xytype==3)
    if(or(isempty(p.xref),isempty(p.yref)))
        disp('should set xref and yref target value if xytype==1')
    else
        if(Npatch == 1)
            ranges = [p.radius' p.angle' p.strike' p.dip' p.rake' p.area' p.asp' p.zs'];
        elseif(Npatch>1)
            ranges = [p.radius' p.angle' p.strike' p.dip' p.rake'];
        end
    end
elseif(xytype==2)
else
    disp('bad xytype')
end