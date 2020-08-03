function savegCentOutputs(out, slip, Mw, zone, saveDir);

[lon, lat] = my_utm2ll(mean([out.xfault(1:4)]),mean([out.yfault(1:4)]),1,zone);

fid= fopen([saveDir '/gCentReport.txt'], 'w');
fprintf(fid,'gCent Params:\n');
fprintf(fid,'Centroid lon/lat \t\t %3.3f\t%3.3f\n', lon,lat);
fprintf(fid,'Centroid depth (km)\t\t%3.2f\n', mean([out.zfault(1:4)])/1e3);
fprintf(fid,'Depth range (km) \t\t%3.2f-%3.2f\n',min([out.zfault])/1e3,max([out.zfault])/1e3);
fprintf(fid,'Geodetic Mag\t\tMw%3.2f\n', Mw);
fprintf(fid,'Slip mag (m)\t\t%3.3f\n', slip(1));
fprintf(fid,'Str/Dip/Rake\t\t%3.0f/%2.0f/%0.0f\n',round(out.strike), round(out.dip), round(out.rake1));
fprintf(fid,'Len/Wid (km)\t\t%3.2f/%3.2f\n',out.L/1e3, out.W/1e3);