%{
    # Jobs that Suite2P should process
    session_name      :   char(16)       # Session name
    dataset_name      :   char(16)       # Dataset name (TIFRaw)
    ---
    -> Suite2PParams
    repository_name   :   varchar(100)   # Short name for repository
    tif_path          :   varchar(255)   # Path of raw tif(s) on repository
    diameter          :   int            # Cell diameter in pixels
    imagerate         :   float          # Imaging rate (cumulative over planes!). For initialization of deconvolution kernel
    entry_time = CURRENT_TIMESTAMP :  timestamp  # Auto created timestamp
%}

classdef Suite2PJobs < dj.Manual
end