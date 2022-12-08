function compare_plot(config,package_color)
%%FUNCTION_NAME - This function extracts the variable and plot it
% Syntax:  compare_plot(config,package_color)
%
% Inputs:
%    config - This is a structure array that contains all the information
%    needed to produce the plots. It includes the case names, number of
%    variables need to be plot, and the bounds for the comparison subplot
%
%    package_color - This flag tells the script if the plotting package is
%    installed, if not, set it to 0
%
% Outputs:
%    It outputs n figures, n = number of variables in config structure
%
% Required packages: M_Map (https://www.eoas.ubc.ca/~rich/map.html)
%                    cptcmap (https://github.com/kakearney/cptcmap-pkg)
% Author: Tian Zhou
% email: tian.zhou@pnnl.gov
% Note: This script only prepared for 0.5 deg global configurations. It
% also requires some packages to make the plots more pretty. If no packages
% installed, then use package_color = 0

casenum = 2;
vnum = size(config.variables,1);
maps = struct;
converter = 3600*24*365; %to convert flux terms from mm/s to mm/yr

for c = 1:casenum %load results from all cases
    if c == 1
        casename = char(config.casename1);
        years = config.years1;
    elseif c == 2
        casename = char(config.casename2);
        years = config.years2;
    end
    
    matname = [config.matdir casename '_' sprintf('%04d',years(1)) '-' sprintf('%04d',years(end)) '.mat'];
    maps.(['case' num2str(c)]) = load (matname);
end

for v = 1:vnum %find out the variables and plot
    vname = char(config.variables(v));
    vmap = zeros(360,720,casenum+1);
    for c = 1:casenum
        if strcmp(vname, 'wrmflow')
            temp = mean(maps.(['case' num2str(c)]).E3SMoutput.(vname),3,'omitnan'); %(m3/s)
        else
            temp = mean(maps.(['case' num2str(c)]).E3SMoutput.(vname),3,'omitnan')*converter; %(mm/yr)
        end
        vmap(:,:,c) = flipud(temp');
    end
    if config.absolute_compare
        vmap(:,:,end) = vmap(:,:,2) - vmap(:,:,1);
    else
        vmap(:,:,end) = (vmap(:,:,2) - vmap(:,:,1))./vmap(:,:,1)*100;
    end
    
    
    %%%%%% start plotting
    fg = figure;
    set(fg, 'Position', [50 60 600 800]);
    xi = -179.75:0.5:179.75;
    yi = -89.75:0.5:89.75;
    [Xi, Yi] = meshgrid(yi,xi);
    
    for s = 1:casenum+1
        subplot(3,1,s);
        if package_color
            m_proj('Equid','lon',[-180 180],'lat',[-60 85]);
        end
        if s==casenum+1
            temp = vmap(:,:,s);
            if package_color
                m_pcolor(Yi',Xi',flipud(temp));
                cptcmap('GMT_jet', 'mapping', 'direct');
                hold on
                m_coast ('color',[.7 .7 .7]);
                hold off
            else
                h = pcolor(Yi',Xi',flipud(temp));
                set(h, 'EdgeColor', 'none');
                colormap(jet)
            end
            cb = colorbar('eastoutside');
            caxis (config.bounds(v,:))
            cname = ['comparison (2-1) for ' sprintf('%04d',years(1)) '-' sprintf('%04d',years(2))];
            if strcmp(vname, 'wrmflow')
                title([cname ' (' vname ', m3/s)'],'Interpreter','none');
            else
                title([cname ' (' vname ', mm/yr)'],'Interpreter','none');
            end
            % title([cname ' (' vname ', percent change)'],'Interpreter','none');
        else
            temp = log10(vmap(:,:,s)); temp(imag(temp)~=0) = nan;
            if package_color
                m_pcolor(Yi',Xi',flipud(temp));
                cptcmap('GMT_drywet', 'mapping', 'direct');
                hold on
                m_coast ('color',[.7 .7 .7]);
                hold off
            else
                h = pcolor(Yi',Xi',flipud(temp));
                set(h, 'EdgeColor', 'none');
                colormap(jet)
            end
            cb = colorbar('eastoutside');
            caxis ([0 4])
            colorbar('Ticks',[0,1,2,3,4],...
                'TickLabels',{'1','10','100','1e3','1e4'})
			if s == 1
               cname = char(config.casename1);
            elseif s == 2
               cname = char(config.casename2);
            end
            title([cname ' (' vname ', mm/yr)'],'Interpreter','none');
        end
        
        
        set(gca,'fontname','Segoe UI Semilight')
        if package_color
            m_grid('linewi',1,'tickdir','in')
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gcf,'PaperPositionMode','auto')
    d = clock;
    print(fg,'-dpng','-r300', [config.outdir '\' vname '.' date '-' ...
        num2str(d(4)) '-' num2str(d(5)) '-' num2str(d(6)) '.png']);
    close (fg);
end

if config.compare_irr
    %%%%%% compare irrigation budget between ELM and MOSART-WM
    vmap = zeros(360,720,5);
    for c = 1:casenum     
        if c == 1
            casename = char(config.casename1);
        elseif c == 2
            casename = char(config.casename2);
        end
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
        h = pcolor(Yi',Xi',flipud(temp));
        set(h, 'EdgeColor', 'none');
        colormap(cool)
        cb = colorbar('eastoutside');
        caxis ([0 100])
        title(['(irr_wm, mm/yr)'],'Interpreter','none');
        
        subplot(2,3,2);
        temp = vmap(:,:,2);
        h = pcolor(Yi',Xi',flipud(temp));
        set(h, 'EdgeColor', 'none');
        colormap(cool)
        cb = colorbar('eastoutside');
        caxis ([0 100])
        title(['(wm_demand, mm/yr)'],'Interpreter','none');
        
        subplot(2,3,3);
        temp = vmap(:,:,2) - vmap(:,:,1);
        temp(abs(temp)<0.5)=nan;
        h = pcolor(Yi',Xi',flipud(temp));
        set(h, 'EdgeColor', 'none');
        cb = colorbar('eastoutside');
        caxis ([-10 10])
        title(['(wm_demand - irr_wm, mm/yr)'],'Interpreter','none');
        
        
        subplot(2,3,4);
        temp = vmap(:,:,3);
        h = pcolor(Yi',Xi',flipud(temp));
        set(h, 'EdgeColor', 'none');
        colormap(cool)
        cb = colorbar('eastoutside');
        caxis ([0 100])
        title(['(wm_supply, mm/yr)'],'Interpreter','none');
        
        subplot(2,3,5);
        temp = vmap(:,:,4);
        h = pcolor(Yi',Xi',flipud(temp));
        set(h, 'EdgeColor', 'none');
        colormap(cool)
        cb = colorbar('eastoutside');
        caxis ([0 100])
        title(['(irr_surf, mm/yr)'],'Interpreter','none');
        
        subplot(2,3,6);
        temp = (vmap(:,:,4) - vmap(:,:,3));
        temp(abs(temp)<0.5)=nan;
        h = pcolor(Yi',Xi',flipud(temp));
        set(h, 'EdgeColor', 'none');
        cb = colorbar('eastoutside');
        caxis ([-10 10])
        title(['(irr_surf - wm_supply, mm/yr)'],'Interpreter','none');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(gcf,'PaperPositionMode','auto')
        d = clock;
        print(fg,'-dpng','-r300', [config.outdir '\irr_budget.' casename '.' date '-' ...
            num2str(d(4)) '-' num2str(d(5)) '-' num2str(d(6)) '.png']);
        close (fg);
    end
end
end
