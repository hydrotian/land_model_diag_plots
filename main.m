clc; clear;
% This script extracts the land and river related variables
% from two cases and then generate plots to compare runoff and evap
%
% Author: Tian Zhou
% email: tian.zhou@pnnl.gov

config = struct;
config.rawdir = '/compyfs/zhou014/E3SM_simulations_AMIP/'; %case output directory
config.matdir = '/qfs/people/zhou014/matlab/'; %mat files will be saved here
config.outdir = '/qfs/people/zhou014/matlab/'; %output figures will be saved here
config.variables = {'runoff';'evap'}; %variables for plot, one variable per figure

%config.casenames = {'20201002_5b7b8b1.ielm_17_dynamic_transient.r05_r05.compycropflag';...
%    '20201002_5b7b8b1.ielm_17_dynamic_transient.r05_r05.compy'};
config.casenames = {'20201002_5b7b8b1.ielm_17_dynamic_transient.r05_r05.compy';...
    '20201002_5b7b8b1.ielm_17_fixec_no_transient.r05_r05.compy'}; % case name, only two allowed
config.years = 1958:1958; %extracting years
config.bounds = [-500 500; -50 50]; %range of the comparison plots, one for runoff, one for evap

if size(config.variables,1) ~= size(config.bounds,1)
    warning('number of variables does not match number of bounds');
end

package_color = 0;

%%%% call functions
extract_land_river(config);
compare_plot(config, package_color);
