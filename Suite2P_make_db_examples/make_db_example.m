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

