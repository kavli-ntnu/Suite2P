%%% Run Suite 2P 
clc
setenv('DJ_HOST', '');
setenv('DJ_USER', '');
setenv('DJ_PASS', '');

%% Establish initial connection with database
dj.conn()

%% Now run things in a loop... 
while true
disp(datetime('now'))
disp('Starting a new parpopulate command in 30 seconds ...')
pause(30)

parpopulate(datajoint.Suite2PCompute)
end