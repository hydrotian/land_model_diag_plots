function compare_plot(config)
%%FUNCTION_NAME - This function extracts the variable and plot it
% Syntax:  compare_plot(config,package_color)
%
% Inputs:
%    config - This is a structure array that contains all the information
%    needed to produce the plots. It includes the case names, number of
%    variables need to be plot, and the bounds for the comparison subplot
%
% Outputs:
%    It outputs n figures, n = number of variables in config structure
%
% config.package_color = true
% Requires two packages: M_Map (https://www.eoas.ubc.ca/~rich/map.html)
%                    cptcmap (https://github.com/kakearney/cptcmap-pkg)
% Author: Tian Zhou
% email: tian.zhou@pnnl.gov
% Note: This script only prepared for 0.5 deg global configurations. It
% also requires some packages to make the plots more pretty. If no packages
% installed, then use package_color = F

casenum = 2;
vnum = size(config.variables,1);
maps = struct;
converter = 3600*24*365; %to convert flux terms from mm/s to mm/yr
package_color = config.package_color;

for c = 1:casenum %load results from all cases
casename = char(config.casename.(['case',num2str(c)]));
years = char(config.years.(['case',num2str(c)]));
    
    matname = [config.matdir casename '_' sprintf('%04d',years(1)) '-' sprintf('%04d',years(end)) '.mat'];
    maps.(['case' num2str(c)]) = load (matname);
end

for v = 1:vnum %find out the variables and plot
    vname = char(config.variables(v));
    disp(['generating compare plots for ' vname]);
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
        if s==casenum+1 % difference plot
            temp = vmap(:,:,s);
            if package_color
                m_pcolor(Yi',Xi',flipud(temp));
                cptcmap('purp_orange', 'mapping', 'direct');
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
            cname = char(config.casename.(['case',num2str(s)]));
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
    print(fg,'-dpng','-r300', [config.outdir '\' vname '.' num2str(d(1)) '-' ...
        num2str(d(2)) '-' num2str(d(3)) '-' num2str(second(datetime('now'),'secondofday')) '.png']);
    close (fg);
    
end
end
