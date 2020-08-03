function datastruct = loadData(processor,datafilename,zone,limitny,azo,const_los,losfilename,nx,ny);

switch processor
    case 'ROIPAC'
        if isempty(losfilename)
            error('Designate a geo_incidence.unw file and path');
        end
        
        datastruct = loadROIPAC(datefilename,zone,limitny,azo);
        datastruct = loadLOS_ROIPAC(datastruct,losfilename,azo,cont_los);
    
    case 'ISCE'
        datastruct = loadISCE(datafilename, zone, limitny, azo);
        datastruct = loadLOS_ISCE(datastruct,losfilename,azo);
    
    case 'GMT'
        datastruct = loadGMT(datafilename, losfilename,nx, ny, zone, limitny, azo);
        
    case 'TimeSeries'
        %This expects time series files in geocoded, geotiff format, in
        %units of mm/yr.
        %LOSFILENAME should be two files, look.tif and heading.tif:
        %{look.tif, heading.tif'}
        datastruct = loadTimeSeries(datafilename,losfilename,dt, zone);
        

        
end

        