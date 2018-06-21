%{
        # Suite2P job parameters
        job_param_name               :   varchar(50)      # Suite2P Parameter set name
        ---
        param_comment = ""           :   varchar(1000)    # Comments on parameter set
        comments = ""                :   varchar(1000)    # Comments (Suite2P internal field)
        mouse_name  = ""             :   varchar(50)      # Mouse name-creating folder
        expts  = ""                  :   varchar(50)      # Experiment names folders
        nchannels                    :   int              # Number of channels
        nchannels_red                :   varchar(10)      # How many channels did the red block have in total (assumes red is last)
        aligntoredchannel = 0        :   int              # Align to red channel?
        deletebin = 1                :   int              # Set to 1 for batch processing on a limited hard drive
        redbinary = 1                :   int              # Make a binary file of registered red frames
        redmeanimg    = 1            :   int              # 
        dobidi = 1                   :   int              # Infer and apply bidirectional phase offset
        nsvdforroi = 1000            :   int              #
        doregistration = 1           :   int              # Skip (0) if data is already registered
        phasecorrelation = 1         :   int              # Set to 0 for non-whitened cross-correlation
        subpixel = "Inf"             :   varchar(10)      # 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
        nimgfirstregistration = 500  :   int              # Number of images to include in the first registration pass 
        nimgbegend   = 0             :   int              # Frames to average at beginning and end of blocks
        sig  = 0.5                   :   float            # Spatial smoothing length in pixels; encourages localized clusters
        navgframessvd  = 5000        :   int              # How many (binned) timepoints to do the SVD based on
        signalextraction             :   varchar(50)      # How to extract ROI and neuropil signals
        innerneuropil = 1            :   varchar(10)      # Padding around cell to exclude from neuropil
        outerneuropil  = "Inf"       :   varchar(10)      # Radius of neuropil surround
        sensortau = 2                :   float            # Decay half-life (or timescale). Approximate, for initialization of deconvolution kernel.
        maxneurop  = 1               :   float            # For the neuropil contamination to be less than this (sometimes good, i.e. for interneurons)
        redthres = 1.5               :   float            # The higher the thres the less red cells
        redmax = 1                   :   float            # The higher the max the more NON-red cells
        getzdrift = 1                :   int              # Z drift calculation
%}

classdef Suite2PParams < dj.Lookup
end