%% SET ALL DEFAULT OPTIONS HERE
% check out the README file for detailed instructions
% **** and for more options available ****

clc;clear all;close all;
addpath('C:\work\python\Suite2P_make_db') % add the path to your make_db file
addpath(genpath('C:\work\python\Suite2P_Kavli\OASIS_matlab')) % add the path to your make_db file

% overwrite any of these default options in your make_db file for individual experiments
make_db_example; % RUN YOUR OWN MAKE_DB SCRIPT TO RUN HERE

ops0.toolbox_path = 'C:\work\python\Suite2P_Kavli';
if exist(ops0.toolbox_path, 'dir')
	addpath(genpath(ops0.toolbox_path)) % add local path to the toolbox
else
	error('toolbox_path does not exist, please change toolbox_path');
end

% mex -largeArrayDims SpikeDetection/deconvL0.c (or .cpp) % MAKE SURE YOU COMPILE THIS FIRST FOR DECONVOLUTION
ops0.useGPU                 = 0; % if you can use an Nvidia GPU in matlab this accelerates registration approx 3 times. You only need the Nvidia drivers installed (not CUDA).
ops0.fig                    = 0; % turn off figure generation with 0
% ---- registration options ------------------------------------- %
ops0.showTargetRegistration = 0; % shows the image targets for all planes to be registered
% ---- cell detection options ------------------------------------------%
ops0.ShowCellMap            = 0; % during optimization, show a figure of the clusters

% SET THIS ! 
if isinf(ops0.outerNeuropil)
    ops0.minNeuropilPixels = 400; % minimum number of pixels in neuropil surround
    ops0.ratioNeuropil     = 5; % ratio btw neuropil radius and cell radius
    % radius of surround neuropil = ops0.ratioNeuropil * (radius of cell)
end

db0 = db;
%% RUN THE PIPELINE HERE

for iexp = 1 %[1:length(db0)]
    db = db0(iexp);
    run_pipeline(db, ops0);
    
    % deconvolved data into st, and neuropil subtraction coef in stat
    add_deconvolution(ops0, db);
    
    % add red channel information (if it exists)
    if isfield(db,'expred') && ~isempty(db.expred)
        % creates mean red channel image aligned to green channel
        % use this if you didn't get red channel during registration
        % OR you have a separate experiment with red and green just for this
        red_expts = ismember(db.expts, getOr(db, 'expred', []));
        if ~ops0.redMeanImg || sum(red_expts)==0
            run_REDaddon_sourcery(db, ops0);
        end
        
        % identify red cells in mean red channel image
        % fills dat.stat.redcell, dat.stat.notred, dat.stat.redprob
        identify_redcells_sourcery(db, ops0); 
        
    end
    
end

