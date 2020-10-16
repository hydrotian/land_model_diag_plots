function extract_land_river(config)
%%FUNCTION_NAME - This function extracts the land and river related variables
% Syntax:  extract_land_river(config)
%
% Inputs:
%    config - This is a structure array that contains all the information
%    needed to extract the data. It includes the case names, number of
%    variables need to be plot, and the years of extraction
%
% Outputs:
%    It outputs n mat files, n = number of cases in config structure
%
% Author: Tian Zhou
% email: tian.zhou@pnnl.gov
casenum = size(config.casenames,1);
years = config.years;

for c = 1:casenum
    casename = char(config.casenames(c));
    matname = [config.matdir casename '_' num2str(config.years(1)) '-' num2str(config.years(end)) '.mat'];
    if exist (matname) == 0 %if it's not exist
        disp (['extracting ' casename '...']); 
        indir = config.rawdir;
        out = struct;
        i=1;
        for year = years
            disp(year);
            for m = 1:12
                filenameclm = [casename '.elm.h0.' num2str(year) '-' sprintf('%02d',m) '.nc'];
                filenamemosart = [casename '.mosart.h0.' num2str(year) '-' sprintf('%02d',m) '.nc'];
                if i == 1
                    out.area = ncread([indir casename '/run/' filenamemosart],'area'); % m2
                    out.lat = ncread([indir casename '/run/' filenamemosart],'lat');
                    out.lon = ncread([indir casename '/run/' filenamemosart],'lon');
                    out.mask = ncread([indir casename '/run/' filenamemosart],'mask');
                    out.areaup = ncread([indir casename '/run/' filenamemosart],'areatotal2');
                end
                
                runoff = ncread([indir casename '/run/' filenameclm],'QRUNOFF');
                runoff (out.mask==2)=nan;
                out.runoff(:,:,i) = runoff;
                
                qsoil = ncread([indir casename '/run/' filenameclm],'QSOIL');
                qvege = ncread([indir casename '/run/' filenameclm],'QVEGE');
                qvegt = ncread([indir casename '/run/' filenameclm],'QVEGT');
                qevap = qsoil+qvege+qvegt;
                qevap (out.mask==2)=nan;
                out.evap(:,:,i) = qevap;
                %%%%
                
                %irr = ncread([indir casename '/run/' filenameclm],'QIRRIG_REAL');
                %irr (out.mask==2)=nan;
                %out.irr(:,:,i) = irr;
                
                wrmflow = ncread([indir casename '/run/' filenamemosart],'RIVER_DISCHARGE_OVER_LAND_LIQ');
                wrmflow (out.mask==2)=nan;
                out.wrmflow(:,:,i) = wrmflow;
                
                i=i+1;
            end
        end
        
        E3SMflow = out;
        save(matname,'E3SMflow','-v7.3');       
    end   
end
