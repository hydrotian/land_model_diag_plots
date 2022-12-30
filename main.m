clc; clear;
% This script extracts the land and river related variables
% from two cases and then generate plots to compare runoff and evap
%
% Author: Tian Zhou
% email: tian.zhou@pnnl.gov

addpath('/qfs/people/zhou014/matlab/packages/m_map/'); %color package
addpath(genpath('/qfs/people/zhou014/matlab/packages/cptcmap-pkg-master/')); %color package


% input 

%case output directory
%rawdir = {'/compyfs/zhou014/E3SMv2/'; '/compyfs/zhuq283/e3sm_scratch/E3SMv2/'};
rawdir = {'/compyfs/zhou014/E3SMv2/'; '/compyfs/zhou014/E3SMv2/'};

%casename = {'v2.LR.amip_trigrid_irrimip_spinup'; '20220321_CBGCv2.r05.compy.I1850GSWCNPWFM.adsp'};
casename = {'v2.LR.amip_trigrid_irrimip_spinup'; 'v2.LR.amip_trigrid_irrimip_spinup'};

years = {num2str(1850:1865); num2str(1885:1900)};

% allowed arguments: 'a+b+...'. a, b,... could be 'elm', 'eam', 'mosart', or blank. Extra variables for spinup plots will be extracted 
components = {'eam+elm+mosart'; 'eam+elm+mosart'};

% T indicates irrigation related variable will be extracted, can only be used on simulations with irrigation turned on
extract_irr = {true; true};

% T indicates irrigation budget diagnostic figures will be generated
irr_budget = {true; true};

% T indicates spinup plots will be generated
spinup_plots = {false; false};

% T indicates it's a bgc run
bgc = {false; false};

% T indicates the previously generated .mat file will be overwritten. Normally used when more variables are need to be extracted.
mat_overwrite = {false; false};

% generate config structure
config = struct;
for c = 1:2
    config.rawdir.(['case',num2str(c)]) = char(rawdir(c));
    config.casename.(['case',num2str(c)]) = char(casename(c));
    config.years.(['case',num2str(c)]) = str2num(cell2mat(years(c)));
    config.components.(['case',num2str(c)]) = char(components(c));
    config.extract_irr.(['case',num2str(c)]) = logical(cell2mat(extract_irr(c)));
    config.irr_budget.(['case',num2str(c)]) = logical(cell2mat(irr_budget(c)));
    config.spinup_plots.(['case',num2str(c)]) = logical(cell2mat(spinup_plots(c)));
    config.bgc.(['case',num2str(c)]) = logical(cell2mat(bgc(c)));
    config.mat_overwrite.(['case',num2str(c)]) = logical(cell2mat(mat_overwrite(c)));
end
    
% define some values for comparisons
config.matdir = '/compyfs/zhou014/E3SMv2/irrimip_diag/'; %mat files will be saved here
config.outdir = '/compyfs/zhou014/E3SMv2/irrimip_diag/'; %output figures will be saved here
config.variables = {'wrmflow';'runoff';'evap'}; %variables for plot, one variable per figure
config.bounds = [-200 200; -200 200; -200 200]; %range of the comparison plots, one pair for each variable
config.absolute_compare = true; % if true, then the comparison will be absolute difference, if false, then the comparison is relative.
config.package_color = true; %true means using external package (m_map and cpt) for plotting 

if size(config.variables,1) ~= size(config.bounds,1)
    warning('number of variables does not match number of bounds');
end

%%%% call functions

% first extract the variables for the cases
for c = 1:2
    extract_land_river(config,c);
end

compare_plot(config);

for c = 1:2
    diag_plot(config,c);
end
