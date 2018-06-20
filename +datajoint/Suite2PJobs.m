%{
    # Jobs that Suite2P should process
    job_id            :   char(16)               # Job ID (hash)
    ---
    -> datajoint.Suite2PParams
    repository_name   :   varchar(100)           # Short name for repository
    tif_path          :   varchar(255)           # Path of raw tif(s) on repository
    entry_time = CURRENT_TIMESTAMP :  timestamp  # Auto created timestamp
%}

classdef Suite2PJobs < dj.Manual
end