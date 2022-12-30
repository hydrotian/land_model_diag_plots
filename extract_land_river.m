function extract_land_river(config,c)
%%FUNCTION_NAME - This function extracts the land and river related variables
% Syntax:  extract_land_river(config)
%
% Inputs:
%    config - This is a structure array that contains all the information
%    needed to extract the data. It includes the case names, number of
%    variables need to be plot, and the years of extraction
%    c      - This is the case number
%
% Outputs:
%    It outputs a mat files which contains the variables extracted.
%
% Author: Tian Zhou
% email: tian.zhou@pnnl.gov


casename = char(config.casename.(['case',num2str(c)]));
years = config.years.(['case',num2str(c)]);
indir = char(config.rawdir.(['case',num2str(c)]));
extract_irr = config.extract_irr.(['case',num2str(c)]);
comps = config.components.(['case',num2str(c)]);
spinup = config.spinup_plots.(['case',num2str(c)]);
ow = config.mat_overwrite.(['case',num2str(c)]);
bgc = config.bgc.(['case',num2str(c)]);

components = split(comps,'+');
ncomp = size(components,1); % number of components
var = struct;
var.elm=false; var.mosart=false; var.eam=false; %initialization
for nc = 1:ncomp
    cname = components(nc);
    switch char(cname)
        case {'elm'}
            var.elm = true;
        case {'mosart'}
            var.mosart = true;
        case {'eam'}
            var.eam = true;
    end
end

matname = [config.matdir casename '_' sprintf('%04d',years(1)) '-' sprintf('%04d',years(end)) '.mat'];
if exist (matname) > 0 && ~ow %if it's existed and not overwrite
    disp ('file existed')
else
    disp (['extracting ' casename '...']);
    out = struct;
    i=1;
    for year = years
        disp(year);
        for m = 1:12
        
        if var.mosart
                filenamemosart = [casename '.mosart.h0.' sprintf('%04d',year) '-' sprintf('%02d',m) '.nc'];
                if i == 1
                    out.area = ncread([indir casename '/run/' filenamemosart],'area'); % m2
                    out.lat = ncread([indir casename '/run/' filenamemosart],'lat');
                    out.lon = ncread([indir casename '/run/' filenamemosart],'lon');
                    out.mask = ncread([indir casename '/run/' filenamemosart],'mask');
                    out.areaup = ncread([indir casename '/run/' filenamemosart],'areatotal2');
                end
                wrmflow = ncread([indir casename '/run/' filenamemosart],'RIVER_DISCHARGE_OVER_LAND_LIQ');
                wrmflow (out.mask==2)=nan;
                out.wrmflow(:,:,i) = wrmflow;
            end
            %%%%
        
            if var.elm
                filenameelm = [casename '.elm.h0.' sprintf('%04d',year) '-' sprintf('%02d',m) '.nc'];
                runoff = ncread([indir casename '/run/' filenameelm],'QRUNOFF');
                runoff (out.mask==2)=nan;
                out.runoff(:,:,i) = runoff;
                
                qsoil = ncread([indir casename '/run/' filenameelm],'QSOIL');
                qvege = ncread([indir casename '/run/' filenameelm],'QVEGE');
                qvegt = ncread([indir casename '/run/' filenameelm],'QVEGT');
                qevap = qsoil+qvege+qvegt;
                qevap (out.mask==2)=nan;
                out.evap(:,:,i) = qevap;
            end
            %%%%    
            
            if var.eam
                filenameeam = [casename '.eam.h0.' sprintf('%04d',year) '-' sprintf('%02d',m) '.nc'];
            end
            
            if extract_irr
                irr_wm =  ncread([indir casename '/run/' filenameelm],'QIRRIG_WM'); %demand sent to WM
                irr_wm (out.mask==2)=nan;
                out.irr_wm(:,:,i) = irr_wm;
                
                irr_real = ncread([indir casename '/run/' filenameelm],'QIRRIG_REAL'); %actual irrigaiton
                irr_real (out.mask==2)=nan;
                out.irr_real(:,:,i) = irr_real;
                
                irr_surf = ncread([indir casename '/run/' filenameelm],'QIRRIG_SURF'); %surface irrigaiton
                irr_surf (out.mask==2)=nan;
                out.irr_surf(:,:,i) = irr_surf;
                
                wm_demand = ncread([indir casename '/run/' filenamemosart],'WRM_IRR_DEMAND'); %demand received by WM
                wm_demand (out.mask==2)=nan;
                out.wm_demand(:,:,i) = wm_demand./out.area*1000; %m3/s to mm/s
                
                wm_supply = ncread([indir casename '/run/' filenamemosart],'WRM_IRR_SUPPLY'); %demand received by WM
                wm_supply (out.mask==2)=nan;
                out.wm_supply(:,:,i) = wm_supply./out.area*1000; %m3/s to mm/s
            end
            
            if spinup
                fsh =  ncread([indir casename '/run/' filenameelm],'FSH'); %sensible heat (W/m2)
                fsh (out.mask==2)=nan;
                out.fsh(:,:,i) = fsh;
                
                lhf =  ncread([indir casename '/run/' filenameelm],'EFLX_LH_TOT'); %total latent heat + to atm(W/m2)
                lhf (out.mask==2)=nan;
                out.lhf(:,:,i) = lhf;
                
                tws =  ncread([indir casename '/run/' filenameelm],'TWS'); %total water storage (mm)
                tws (out.mask==2)=nan;
                out.tws(:,:,i) = tws;
                
                h2osoi_all =  ncread([indir casename '/run/' filenameelm],'H2OSOI'); %volumetric soil water (mm3/mm3)
                h2osoi = h2osoi_all(:,:,8); % extract the 8th layer of soil
                h2osoi (out.mask==2)=nan;
                out.h2osoi(:,:,i) = h2osoi;
                
                tsoi_all =  ncread([indir casename '/run/' filenameelm],'TSOI'); %soil temperature (K)
                tsoi = tsoi_all(:,:,10); % extract the 10th layer of soil
                tsoi (out.mask==2)=nan;
                out.tsoi(:,:,i) = tsoi;
                
                if bgc
                    gpp =  ncread([indir casename '/run/' filenameelm],'GPP'); %gross primary production (gC/m2/s)
                    gpp (out.mask==2)=nan;
                    out.gpp(:,:,i) = gpp;
                end
                
                channelS = ncread([indir casename '/run/' filenamemosart],'Main_Channel_STORAGE_LIQ'); %river channel storage
                channelS (out.mask==2)=nan;
                out.channelS(:,:,i) = channelS; 
                
                i=i+1;
            end
        end
        
        E3SMoutput = out;
        save(matname,'E3SMoutput','-v7.3');
    end
end
