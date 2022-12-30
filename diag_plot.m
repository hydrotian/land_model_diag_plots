function diag_plot(config,c)
%%FUNCTION_NAME - This function extracts the variable and plot it
% Syntax:  compare_plot(config,c,package_color)
%
% Inputs:
%    config - This is a structure array that contains all the information
%    needed to produce the plots. It includes the case names, number of
%    variables need to be plot, and the bounds for the comparison subplot
%
%    c      - This is the case number
%
% Outputs:
%    It outputs diagnostic plots for irrigation budget and/or spinup
%
% config.package_color = true
% Requires two packages: M_Map (https://www.eoas.ubc.ca/~rich/map.html)
%                    cptcmap (https://github.com/kakearney/cptcmap-pkg)
%
% Author: Tian Zhou
% email: tian.zhou@pnnl.gov
% Note: This script only prepared for 0.5 deg global configurations. It
% also requires some packages to make the plots more pretty. If no packages
% installed, then use package_color = 0

casename = char(config.casename.(['case',num2str(c)]));
years = config.years.(['case',num2str(c)]);
matname = [config.matdir casename '_' sprintf('%04d',years(1)) '-' sprintf('%04d',years(end)) '.mat'];
converter = 3600*24*365; %to convert flux terms from mm/s to mm/yr

irr = config.irr_budget.(['case',num2str(c)]);
spinup = config.spinup_plots.(['case',num2str(c)]);
bgc = config.bgc.(['case',num2str(c)]);
package_color = config.package_color;

if irr || spinup
    maps.(['case' num2str(c)]) = load (matname);
end

if irr
    %%%%%% compare irrigation budget between ELM and MOSART-WM
    vmap = zeros(360,720,5);
    
    vname = 'irr_wm';
    temp = -mean(maps.(['case' num2str(c)]).E3SMoutput.(vname),3,'omitnan')*converter; %(mm/yr)
    vmap(:,:,1) = flipud(temp');
    
    vname = 'wm_demand';
    temp = mean(maps.(['case' num2str(c)]).E3SMoutput.(vname),3,'omitnan')*converter; %(mm/yr)
    vmap(:,:,2) = flipud(temp');
    
    vname = 'wm_supply';
    temp = mean(maps.(['case' num2str(c)]).E3SMoutput.(vname),3,'omitnan')*converter; %(mm/yr)
    vmap(:,:,3) = flipud(temp');
    
    vname = 'irr_surf';
    temp = mean(maps.(['case' num2str(c)]).E3SMoutput.(vname),3,'omitnan')*converter; %(mm/yr)
    vmap(:,:,4) = flipud(temp');
    
    vname = 'irr_real';
    temp = mean(maps.(['case' num2str(c)]).E3SMoutput.(vname),3,'omitnan')*converter; %(mm/yr)
    vmap(:,:,5) = flipud(temp');
    
    fg = figure;
    set(fg, 'Position', [50 60 1200 500]);
    xi = -179.75:0.5:179.75;
    yi = -89.75:0.5:89.75;
    [Xi, Yi] = meshgrid(yi,xi);
    
    subplot(2,3,1);
    temp = vmap(:,:,1);
    plot_map(temp, package_color,[0 100], 'new', '(irr_wm, mm/yr)')
    
    subplot(2,3,2);
    temp = vmap(:,:,2);
    plot_map(temp, package_color,[0 100],'new','(wm_demand, mm/yr)')
    
    subplot(2,3,3);
    temp = vmap(:,:,2) - vmap(:,:,1);
    % temp(abs(temp)<0.5)=nan;
    plot_map(temp, package_color,[-10 10],'purp_orange','(wm_demand - irr_wm, mm/yr)')
    
    subplot(2,3,4);
    temp = vmap(:,:,3);
    plot_map(temp, package_color,[0 100],'new','(wm_supply, mm/yr)')
    
    subplot(2,3,5);
    temp = vmap(:,:,4);
    plot_map(temp, package_color,[0 100],'new','(irr_surf, mm/yr)')
    
    subplot(2,3,6);
    temp = (vmap(:,:,4) - vmap(:,:,3));
    % temp(abs(temp)<0.5)=nan;
    plot_map(temp, package_color,[-10 10],'purp_orange','(irr_surf - wm_supply, mm/yr)')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gcf,'PaperPositionMode','auto')
    d = clock;
    print(fg,'-dpng','-r300', [config.outdir '\irr_budget.' casename '.' num2str(d(1)) '-' ...
        num2str(d(2)) '-' num2str(d(3)) '-' num2str(second(datetime('now'),'secondofday')) '.png']);
    close (fg);
end

if spinup
    fg = figure;
    set(fg, 'Position', [50 60 1200 500]);
    subplot(2,3,1);
    monthly_ts = squeeze(mean(mean(maps.(['case' num2str(c)]).E3SMoutput.fsh,1,'omitnan'),2,'omitnan'));
    plot_line(monthly_ts, years, 'W/m^2', 'sensible heat (FSH)');
    
    subplot(2,3,2);
    monthly_ts = squeeze(mean(mean(maps.(['case' num2str(c)]).E3SMoutput.lhf,1,'omitnan'),2,'omitnan'));
    plot_line(monthly_ts, years, 'W/m^2', 'latent heat (EFLX_LH_TOT)');
    
    subplot(2,3,3);
    monthly_ts = squeeze(mean(mean(maps.(['case' num2str(c)]).E3SMoutput.tws,1,'omitnan'),2,'omitnan'));
    plot_line(monthly_ts, years, 'mm', 'total water storage (TWS)');
    
    subplot(2,3,4);
    monthly_ts = squeeze(mean(mean(maps.(['case' num2str(c)]).E3SMoutput.h2osoi,1,'omitnan'),2,'omitnan'));
    plot_line(monthly_ts, years, 'mm^3', 'volumetric soil water at 8th layer (H2OSOI)');
    
    subplot(2,3,5);
    monthly_ts = squeeze(mean(mean(maps.(['case' num2str(c)]).E3SMoutput.tsoi,1,'omitnan'),2,'omitnan'));
    plot_line(monthly_ts, years, 'K', 'soil temperature at 10th layer (TSOI)');
    
    if bgc
        subplot(2,3,6);
        monthly_ts = squeeze(mean(mean(maps.(['case' num2str(c)]).E3SMoutput.gpp,1,'omitnan'),2,'omitnan'));
        plot_line(monthly_ts, years, 'gC/m^2/s', 'GPP');
    end
    
    set(gcf,'PaperPositionMode','auto')
    d = clock;
    print(fg,'-dpng','-r300', [config.outdir '\Spinup.' casename '.' num2str(d(1)) '-' ...
        num2str(d(2)) '-' num2str(d(3)) '-' num2str(second(datetime('now'),'secondofday')) '.png']);
    close (fg);
end

%%%%%%%

    function plot_map(map, package_color,range, cpt, title_text)
        
        if package_color
            m_proj('Equid','lon',[-180 180],'lat',[-60 85]);
        end
        
        if package_color
            m_pcolor(Yi',Xi',flipud(map));
            cptcmap(cpt, 'mapping', 'direct');
            hold on
            m_coast ('color',[.7 .7 .7]);
            hold off
            set(gca,'fontname','Segoe UI Semilight')
            m_grid('linewi',1,'tickdir','in')
        else
            h = pcolor(Yi',Xi',flipud(map));
            set(h, 'EdgeColor', 'none');
            colormap(cool)
        end
        
        cb = colorbar('southoutside');
        caxis (range)
        title(title_text,'Interpreter','none');
    end

    function plot_line(ts, years, unit, title_text)
        ts_annual = mean(reshape(ts,12,[]));
        plot(years,ts_annual,'linewidth',2);
        xlabel('year');
        ylabel(unit);
        title(title_text);
    end

end