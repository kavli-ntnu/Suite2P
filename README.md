# KAVLI Suite2P with Datajoint

Forked from [Suite2p: fast, accurate and complete two-photon pipeline](https://github.com/cortex-lab/Suite2P) on 05.04.2018. Added [OASIS](https://github.com/zhoupc/OASIS_matlab) on same date. Algorithmic details in [http://biorxiv.org/content/early/2016/06/30/061507](http://biorxiv.org/content/early/2016/06/30/061507).

### Last commit
Last commit taken over from master in original repo: 08003ee6ec9a4a4ad87e600dcc053063b02ddac9

### Changes
Made independent of the original "forced" folder structure (Mouse/Date/) to be able to call .tif folders directly. If ``mouse_name`` does not exist in make_db, process with non-prefixed folder structure.

What changed are the export filenames (changed throughout different .m files).
Consider the following example:

**OLD**:
```
foldr = fullfile(ops.RegFileTiffLocation, ops.mouse_name, ops.date, ...
         ops.SubDirs{k}, sprintf('Plane%d', iplane));
```

**NEW**:
```
mouse_name = getOr(ops, 'mouse_name', []);
if isempty(mouse_name) % file names are fixed in make_db and no folder structure has to be assumed.
    foldr = fullfile(ops.RegFileTiffLocation, sprintf('Plane%d', iplane));  
else
    foldr = fullfile(ops.RegFileTiffLocation, ops.mouse_name, ops.date, ...
             ops.SubDirs{k}, sprintf('Plane%d', iplane));    
```

This gets rid of the pre-defined folder structure that contains both ``mouse_name`` and ``date`` in the path.


### Standard setup
To run Suite2P (and omit the mouse_name/date folder structure) it is now assumed that:
- The data folder (``RootDir``) contains all the .tif files that should be analyzed together and they have some logical ordering such that ``natsort`` can take care of putting them into the right order.
- I keep the following folders all the same: ``RootDir`` = ``RootStorage`` = ``RegFileRoot`` = ``ResultsSavePath`` = ``RegFileTiffLocation``. This saves everything (including registered tif files) to the original data folder. ``temp_tiff`` is set to a local drive.
- The tif files are either scanimage big tifs with different channels being chained together like *channel1-channel2-channel1-channel2-...* or mimic this structure (either uint16 or int16).
- If the data contains a second (red, non-signal) channel, then the setup should be:
```
db.expred                 = 1;
db.nchannels              = 2;
db.nchannels_red          = 2;
db.AlignToRedChannel      = 0; % Change this to 1 if red channel has nice structural signal
db.REDbinary              = 1;
db.redMeanImg             = 1;
```
This will create bin files ``plane1.bin`` and ``plane1_RED.bin`` in the export folder and create separate motion corrected tif stacks for each channel. It will calculate a mean red image (after motion correction) and calculate probabilities of cells being red, reflected in the export as ``dat.stat.redcell``, ``dat.stat.notred``, ``dat.stat.redprob`` (it runs ``identify_redcells_sourcery`` for that).

**Careful!** Assumes now that the experiments all have the same number of green and red channels (within one data folder).
**To do**: (1) Test normal suite2p folder structure.

### Datajoint
This version integrates a datajoint based job handler (see ``+datajoint``). Documentation will follow.
