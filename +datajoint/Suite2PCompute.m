%{
    # Suite2P - Processes suite2p jobs and saves output 
    -> datajoint.Suite2PJobs
    ---
    time_finished = CURRENT_TIMESTAMP :  timestamp  # Auto created timestamp
%}

classdef Suite2PCompute < dj.Computed

	methods(Access=protected)
		function makeTuples(self, key)
            
        %%%%%%%%%%%%%%%%%%%% BASE PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        config = 'config.ini';
        fullpath = regexp(mfilename('fullpath'),filesep,'split');
        basefolder_ = fullpath(1:end-2);
        basefolder = strjoin(basefolder_, filesep);
        
        % USE GPU?
        useGPU = datajoint.inifile(fullfile(basefolder,config),'read',{'suite2p_options','','useGPU'});
        useGPU = useGPU{1,1};
        if isempty(useGPU)
            error('useGPU not defined in config - please specify (0 or 1)')
        end
        ops0.useGPU = str2double(useGPU);
        
        % TEMP TIF LOCATION
        temp_tiff = datajoint.inifile(fullfile(basefolder,config),'read',{'paths','','temp_tiff'});
        temp_tiff = temp_tiff{1,1};
        if isempty(temp_tiff)
            error('temp_tiff not defined in config - please specify temp tiff path')
        end
        db.temp_tiff = temp_tiff;
        
        %%%%%%%%%%%%%%%%%%%% PATHS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        toolbox_path = datajoint.inifile(fullfile(basefolder,'config.ini'),'read',{'paths','','toolbox_path'});
        toolbox_path = toolbox_path{1,1};
        if isempty(toolbox_path) % empty
            toolbox_path = basefolder;
        end
        
        oasisfolder = basefolder_;
        oasisfolder{end+1} = 'OASIS_matlab';
        oasis_path_default = strjoin(oasisfolder,filesep);
        oasis_path = datajoint.inifile(fullfile(basefolder,'config.ini'),'read',{'paths','','oasis_path'});
        oasis_path = oasis_path{1,1};
        if isempty(oasis_path) % empty
            oasis_path = oasis_path_default;
        end

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
        
        % Retrieve entries and cast in struct like: 
        % db.mouse_name = '';      
        repository_name = fetch1(datajoint.Suite2PJobs & key,'repository_name');    
        tif_path_ = fetch1(datajoint.Suite2PJobs & key,'tif_path');
        diameter = fetch1(datajoint.Suite2PJobs & key,'diameter');
        imagerate = fetch1(datajoint.Suite2PJobs & key,'imagerate');
        job_param_name = fetch1(datajoint.Suite2PJobs & key,'job_param_name');
        suite_params = fetch(datajoint.Suite2PParams & sprintf('job_param_name = "%s"',job_param_name),'*');
        
        fprintf('Found a new Job with \nRepository: %s\nTIF Path: %s\n', repository_name, tif_path_);
        
        %%% LOOK UP FOLDER PATH BASED ON REPOSITORY NAME
        drive = datajoint.inifile(fullfile(basefolder,'config.ini'),'read',{'drives','',repository_name});
        drive = drive{1,1};
        if isempty(drive)
            error('Repository mapped on this computer (drive) not found')
        end
        
        tif_path = strcat(drive,tif_path_);
        if exist(tif_path,'dir')
            fprintf('Found path %s\n',tif_path);
        else
            error('Path to tifs not found on this computer.');
        end
        
        % Following the suite2p structure ...
        db.RootDir = tif_path;
        db.RootStorage = tif_path;
        db.RegFileRoot = tif_path;
        db.ResultsSavePath = tif_path;
        db.RegFileTiffLocation = tif_path;
        
        db.comments = suite_params.comments;
             
        db.mouse_name             = suite_params.mouse_name;
        db.expts                  = suite_params.expts; 
        db.diameter               = diameter;
        db.expred                 = 1; % Comment Horst: Not really needed.But needs to be something.
        db.nchannels              = suite_params.nchannels; %
        db.nchannels_red          = str2num(suite_params.nchannels_red); 
        db.AlignToRedChannel      = suite_params.aligntoredchannel;
        db.DeleteBin              = suite_params.deletebin; 
        db.REDbinary              = suite_params.redbinary; 
        db.redMeanImg             = suite_params.redmeanimg; 
        db.dobidi                 = suite_params.dobidi; 
        db.nSVDforROI             = suite_params.nsvdforroi;
        db.doRegistration         = suite_params.doregistration;
        db.PhaseCorrelation       = suite_params.phasecorrelation; 
        db.NimgFirstRegistration  = suite_params.nimgfirstregistration; 
        db.nimgbegend             = suite_params.nimgbegend; 
        db.sig                    = suite_params.sig;  
        db.NavgFramesSVD          = suite_params.navgframessvd; 
        db.signalExtraction       = suite_params.signalextraction; 
        db.imageRate              = imagerate;   
        db.sensorTau              = suite_params.sensortau; 
        db.maxNeurop              = suite_params.maxneurop;
        db.redthres               = suite_params.redthres;
        db.redmax                 = suite_params.redmax;
        db.getZdrift              = suite_params.getzdrift;
        db.SubPixel               = str2double(suite_params.subpixel);
        db.outerNeuropil          = str2double(suite_params.outerneuropil);
        db.innerNeuropil          = str2double(suite_params.innerneuropil); 
        
        
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
            %if ~ops0.redMeanImg || sum(red_expts)==0
            %    run_REDaddon_sourcery(db, ops0);
            %end

            % identify red cells in mean red channel image
            % fills dat.stat.redcell, dat.stat.notred, dat.stat.redprob
            identify_redcells_sourcery(db, ops0); 

        end 
       
	    self.insert(key)
		end
	end

end