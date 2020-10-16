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

casenum = size(config.casenames,1);
vnum = size(config.variables,1);
maps = struct;

for c = 1:casenum %load results from all cases
    casename = char(config.casenames(c));
    matname = [config.matdir casename '_' num2str(config.years(1)) '-' num2str(config.years(end)) '.mat'];
    maps.(['case' num2str(c)]) = load (matname);
end

for v = 1:vnum %find out the variables and plot
    vname = char(config.variables(v));
    vmap = zeros(360,720,casenum+1);
    for c = 1:casenum
        temp = mean(maps.(['case' num2str(c)]).E3SMflow.(vname),3,'omitnan')*3600*24*365; %(mm/yr)
        vmap(:,:,c) = flipud(temp');
    end
    vmap(:,:,end) = vmap(:,:,2) - vmap(:,:,1);
    
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
            cname = ['comparison (2-1) for ' num2str(config.years(1)) '-' num2str(config.years(end))];
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
            cname = char(config.casenames(s));
        end
        
        title([cname ' (' vname ', mm/yr)'],'Interpreter','none');
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


