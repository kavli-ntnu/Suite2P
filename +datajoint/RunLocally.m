%%%%%%%%%%%%%%%  RUN SUITE2P without DATAJOINT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%tif_path = 'L:\Flavio\2P\L8M1\12072018\MUnit_0';
tif_path = 'L:\Flavio\2P\L1M1CA3\03072018\test_export';
diameter = 15; % ADJUST THIS!

ops0.useGPU = 1;
% TEMP TIF LOCATION
db.temp_tiff = 'G:\temp\temp.tif';

%%%%%%%%%%%%%%%%%%%% PATHS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

toolbox_path = 'L:\SUITE2P-KAVLI';
oasis_path = 'L:\SUITE2P-KAVLI\OASIS_matlab';

%%%%%%%%%%%%%%%%%%%% RUN SUITE2P %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; close all;

if exist(toolbox_path, 'dir')
    addpath(genpath(toolbox_path)) % add local path to the toolbox
    ops0.toolbox_path = toolbox_path;
else
    error('toolbox_path does not exist, please change toolbox_path under base parameters or add to config.ini');
end
if exist(oasis_path, 'dir')
    addpath(genpath(oasis_path)) % add local path to OASIS
else
    error('oasis_path does not exist, please change oasis_path under base parameters or add to config.ini');
end       


% Following the suite2p structure ...
db.RootDir             = tif_path;
db.RootStorage         = tif_path;
db.RegFileRoot         = tif_path;
db.ResultsSavePath     = tif_path;
db.RegFileTiffLocation = tif_path;

db.comments = '';

db.mouse_name             = '';
db.expts                  = ''; 
db.diameter               = diameter;
db.expred                 = 1; % Comment Horst: Not really needed. But needs to be something.
db.nchannels              = 2; %
db.nchannels_red          = 2; 
db.AlignToRedChannel      = 0;
db.DeleteBin              = 0; 
db.REDbinary              = 1; 
db.redMeanImg             = 1; 
db.dobidi                 = 1; 
db.nSVDforROI             = 1000;
db.doRegistration         = 1;
db.PhaseCorrelation       = 1; 
db.NimgFirstRegistration  = 500; 
db.nimgbegend             = 0; 
db.sig                    = 0.5;  
db.NavgFramesSVD          = 5000; 
db.signalExtraction       = 'surround'; 
db.imageRate              = 32;   
db.sensorTau              = 2; 
db.maxNeurop              = 1;
db.redthres               = 1.5;
db.redmax                 = 1;
db.getZdrift              = 1;
db.SubPixel               = Inf;
db.outerNeuropil          = Inf;
db.innerNeuropil          = 1; 


% SET THIS ACCORDING TO WHAT YOU RETRIEVE FROM THE JOBS TABLE 
if isinf(db.outerNeuropil)
    ops0.minNeuropilPixels = 400; % minimum number of pixels in neuropil surround
    ops0.ratioNeuropil     = 5; % ratio btw neuropil radius and cell radius
    % radius of surround neuropil = ops0.ratioNeuropil * (radius of cell)
end

% mex -largeArrayDims SpikeDetection/deconvL0.c (or .cpp) % MAKE SURE YOU COMPILE THIS FIRST FOR DECONVOLUTION
ops0.fig                    = 0; % turn off figure generation with 0
ops0.showTargetRegistration = 0; % shows the image targets for all planes to be registered
ops0.ShowCellMap            = 0; % during optimization, show a figure of the clusters

%% RUN THE PIPELINE HERE
run_pipeline(db, ops0);

% deconvolved data into st, and neuropil subtraction coef in stat
add_deconvolution(ops0, db);

% add red channel information (if it exists)
if isfield(db,'expred') && ~isempty(db.expred)
    % creates mean red channel image aligned to green channel
    % use this if you didn't get red channel during registration
    % OR you have a separate experiment with red and green just for this
    %red_expts = ismember(db.expts, getOr(db, 'expred', []));
    %if ~ops.redMeanImg || sum(red_expts)==0
    %    run_REDaddon_sourcery(db, ops0);
    %end

    % identify red cells in mean red channel image
    % fills dat.stat.redcell, dat.stat.notred, dat.stat.redprob
    identify_redcells_sourcery(db, ops0); 

end 