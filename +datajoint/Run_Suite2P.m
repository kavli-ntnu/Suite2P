%%% Run Suite 2P 
clc
setenv('DJ_HOST', '');
setenv('DJ_USER', '');
setenv('DJ_PASS', '');

%% Establish initial connection with database
dj.conn()

% ... and add datajoint schema folder
datajoint_path = 'C:\work\python\Suite2P-Kavli';
addpath(genpath(datajoint_path)); % add datajoint to path

%% Now run things in a loop... 
parpopulate(datajoint.Suite2PCompute)