%%% Run Suite 2P 
clc
setenv('DJ_HOST', '');
setenv('DJ_USER', '');
setenv('DJ_PASS', '');

%% Establish initial connection with database
dj.conn()

%% Now run things in a loop... 
parpopulate(datajoint.Suite2PCompute)