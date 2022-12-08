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

for c = 1:2
    if c == 1
        casename = char(config.casename1);
        years = config.years1;
		indir = config.rawdir1;
    elseif c == 2
        casename = char(config.casename2);
        years = config.years2;
		indir = config.rawdir2;
    end
    
    matname = [config.matdir casename '_' sprintf('%04d',years(1)) '-' sprintf('%04d',years(end)) '.mat'];
    if exist (matname) == 0 %if it's not exist
        disp (['extracting ' casename '...']);
        out = struct;
        i=1;
        for year = years
            disp(year);
            for m = 1:12
                filenameclm = [casename '.elm.h0.' sprintf('%04d',year) '-' sprintf('%02d',m) '.nc'];
                filenamemosart = [casename '.mosart.h0.' sprintf('%04d',year) '-' sprintf('%02d',m) '.nc'];
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
                
                if config.extract_irr
                    irr_wm =  ncread([indir casename '/run/' filenameclm],'QIRRIG_WM'); %demand sent to WM
                    irr_wm (out.mask==2)=nan;
                    out.irr_wm(:,:,i) = irr_wm;
                    
                    irr_real = ncread([indir casename '/run/' filenameclm],'QIRRIG_REAL'); %actual irrigaiton
                    irr_real (out.mask==2)=nan;
                    out.irr_real(:,:,i) = irr_real;
                    
                    irr_surf = ncread([indir casename '/run/' filenameclm],'QIRRIG_SURF'); %surface irrigaiton
                    irr_surf (out.mask==2)=nan;
                    out.irr_surf(:,:,i) = irr_surf;
                    
                    wm_demand = ncread([indir casename '/run/' filenamemosart],'WRM_IRR_DEMAND'); %demand received by WM
                    wm_demand (out.mask==2)=nan;
                    out.wm_demand(:,:,i) = wm_demand./out.area*1000; %m3/s to mm/s
                    
                    wm_supply = ncread([indir casename '/run/' filenamemosart],'WRM_IRR_SUPPLY'); %demand received by WM
                    wm_supply (out.mask==2)=nan;
                    out.wm_supply(:,:,i) = wm_supply./out.area*1000; %m3/s to mm/s
                    
                end
                
                wrmflow = ncread([indir casename '/run/' filenamemosart],'RIVER_DISCHARGE_OVER_LAND_LIQ');
                wrmflow (out.mask==2)=nan;
                out.wrmflow(:,:,i) = wrmflow;
                
                i=i+1;
            end
        end
        
        E3SMoutput = out;
        save(matname,'E3SMoutput','-v7.3');
    end
end
