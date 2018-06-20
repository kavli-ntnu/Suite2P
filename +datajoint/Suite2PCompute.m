%{
    # Suite2P - Processes suite2p jobs and saves output 
    -> datajoint.Suite2PJobs
    ---
    time_finished = CURRENT_TIMESTAMP :  timestamp  # Auto created timestamp
%}

classdef Suite2PCompute < dj.Computed

	methods(Access=protected)
		function makeTuples(self, key)
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%% BASE PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%
        toolbox_path = 'C:/work/python/Suite2P-Kavli';
        oasis_path = 'C:/work/python/Suite2P-Kavli/OASIS_matlab';
        ops0.useGPU = 0; % If you can use an Nvidia GPU in matlab this accelerates registration approx 3 times.
        db.temp_tiff = 'C:/temp/temp.tif'; % Set this location to a fast local drive
        
        % DRIVE MAPPING
        drives(1).('moser_imaging') = 'L:';
        drives(1).('lager') = 'N:';
        drives(1).('datajoint') = 'J:';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        clc; close all;
        
        if exist(toolbox_path, 'dir')
            addpath(genpath(toolbox_path)) % add local path to the toolbox
            ops0.toolbox_path = toolbox_path;
        else
            error('toolbox_path does not exist, please change toolbox_path under base parameters');
        end
        if exist(oasis_path, 'dir')
            addpath(genpath(oasis_path)) % add local path to OASIS
        else
            error('oasis_path does not exist, please change oasis_path under base parameters');
        end       
        
        % Retrieve entries and cast in struct like: 
        % db.mouse_name = '';      
        repository_name = fetch1(datajoint.Suite2PJobs & key,'repository_name');
        tif_path_ = fetch1(datajoint.Suite2PJobs & key,'tif_path');
        suite_params = fetch(datajoint.Suite2PParams & key,'*');
        
        fprintf('Found a new Job with \nRepository: %s\nTIF Path: %s\n', repository_name, tif_path_);
        
        %%% LOOK UP FOLDER PATH BASED ON REPOSITORY NAME
        drive = drives(1).(repository_name);
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

        % Take care of possible Infs occuring for:
        % outerNeuropil | SubPixel | 
        if strcmp(suite_params.outerneuropil,'Inf')
           db.outerNeuropil = Inf;
        else
           db.outerNeuropil = suite_params.outerneuropil;
        end
        if strcmp(suite_params.subpixel,'Inf')
           db.SubPixel = Inf;
        else
           db.SubPixel = suite_params.subpixel;
        end        
        
        db.mouse_name             = suite_params.mouse_name;
        db.expts                  = suite_params.expts; 
        db.diameter               = suite_params.diameter;
        db.expred                 = ''; % Comment Horst: Not really needed.
        db.nchannels              = suite_params.nchannels; %
        db.nchannels_red          = suite_params.nchannels_red; 
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
        db.innerNeuropil          = suite_params.innerneuropil; 
        db.imageRate              = suite_params.imagerate;   
        db.sensorTau              = suite_params.sensortau; 
        db.maxNeurop              = suite_params.maxneurop;
        db.redthres               = suite_params.redthres;
        db.redmax                 = suite_params.redmax;
        db.getZdrift              = suite_params.getzdrift;
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
            red_expts = ismember(db.expts, getOr(db, 'expred', []));
            if ~ops0.redMeanImg || sum(red_expts)==0
                run_REDaddon_sourcery(db, ops0);
            end

            % identify red cells in mean red channel image
            % fills dat.stat.redcell, dat.stat.notred, dat.stat.redprob
            identify_redcells_sourcery(db, ops0); 

        end 
      
	    self.insert(key)
		end
	end

end