% Trying out different parameter settings for suite 2P

i = 0;
i = i+1;
% example for datasets without folder structure
db(i).mouse_name            = '';
db(i).expts                 = []; % leave empty, or specify subfolders as numbers
db(i).diameter              = 12;
db(i).RootDir               = 'K:\temp\13_58\0'; % specify full path to tiffs here
db(i).RootStorage           = 'K:\temp\13_58\0'; % Suite2P assumes a folder structure, check out README file
db(i).expred                = []; % say one block which had a red channel 
db(i).nchannels             = 2; % how many channels did the red block have in total (assumes red is last)
db(i).nchannels_red         = 2; % how many channels did the red block have in total (assumes red is last)
db(i).AlignToRedChannel     = 0;
db(i).temp_tiff             = 'K:\temp\Suite2P_tmp.tif'; % copies each remote tiff locally first, into this file
db(i).RegFileRoot           = 'K:\temp\13_58\0';  % location for binary file
db(i).DeleteBin             = 0; % set to 1 for batch processing on a limited hard drive
db(i).ResultsSavePath       = 'K:\temp\13_58\0'; % a folder structure is created inside
db(i).RegFileTiffLocation   = 'K:\temp\13_58\0'; %'D:/DATA/'; % leave empty to NOT save registered tiffs (slow)
db(i).REDbinary             = 1; % make a binary file of registered red frames
db(i).redMeanImg            = 1; 
db(i).dobidi                = 1; % infer and apply bidirectional phase offset
db(i).nSVDforROI            = 1000; % will overwrite the default, only for this dataset
db(i).comments              = 'Testing out parameters';
db(i).doRegistration         = 1; % skip (0) if data is already registered
db(i).PhaseCorrelation       = 1; % set to 0 for non-whitened cross-correlation
db(i).SubPixel               = Inf; % 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
db(i).NimgFirstRegistration  = 500; % number of images to include in the first registration pass 
db(i).nimgbegend             = 0; % frames to average at beginning and end of blocks
db(i).sig                    = 0.5;  % spatial smoothing length in pixels; encourages localized clusters
db(i).NavgFramesSVD          = 5000; % how many (binned) timepoints to do the SVD based on
db(i).signalExtraction       = 'surround'; % how to extract ROI and neuropil signals: 
db(i).innerNeuropil  = 1; % padding around cell to exclude from neuropil
db(i).outerNeuropil  = Inf; % radius of neuropil surround
db(i).imageRate              = 30;   % imaging rate (cumulative over planes!). Approximate, for initialization of deconvolution kernel.
db(i).sensorTau              = 2; % decay half-life (or timescale). Approximate, for initialization of deconvolution kernel.
db(i).maxNeurop              = 1; % for the neuropil contamination to be less than this (sometimes good, i.e. for interneurons)
db(i).redthres               = 1.5; % the higher the thres the less red cells
db(i).redmax                 = 1; % the higher the max the more NON-red cells

