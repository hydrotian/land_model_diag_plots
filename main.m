clc; clear;
% This script extracts the land and river related variables
% from two cases and then generate plots to compare runoff and evap
%
% Author: Tian Zhou
% email: tian.zhou@pnnl.gov

addpath('/qfs/people/zhou014/matlab/packages/m_map/'); %color package
addpath(genpath('/qfs/people/zhou014/matlab/packages/cptcmap-pkg-master/')); %color package

config = struct;
config.rawdir1 = '/compyfs/zhou014/E3SMv2/'; %case1 output directory
config.casename1 = 'v2.LR.amip_trigrid_irrimip_spinup';
config.years1 = 1854:1859;

config.rawdir2 = '/compyfs/zhuq283/e3sm_scratch/E3SMv2/'; %case2 output directory
config.casename2 = '20220321_CBGCv2.r05.compy.I1850GSWCNPWFM.adsp';
config.years2 = 695:700;

config.matdir = '/compyfs/zhou014/E3SMv2/irrimip_diag/'; %mat files will be saved here
config.outdir = '/compyfs/zhou014/E3SMv2/irrimip_diag/'; %output figures will be saved here
config.variables = {'wrmflow';'runoff';'evap'}; %variables for plot, one variable per figure
config.extract_irr = 1; %extract irrigation related variable, can only be used on simulations with irrigation turned on
config.compare_irr = 1; %compare irrigation water budget between ELM and WM

config.bounds = [0 200; 0 200; 0 200]; %range of the comparison plots, one pair for each variable
config.absolute_compare = 1; % if true, then the comparison will be absolute difference, if false, then the comparison is relative.

if size(config.variables,1) ~= size(config.bounds,1)
    warning('number of variables does not match number of bounds');
end

package_color = 1;

%%%% call functions
extract_land_river(config);
compare_plot(config, package_color);