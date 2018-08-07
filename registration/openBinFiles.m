% open binary files to write registered tiffs to
% takes ops, ops1, and red_binary (if 1 then write red channel to binary)
function [ops1, fid, fidRED, fidIntpol] = openBinFiles(ops, ops1, red_binary)
numPlanes = numel(ops.planesToProcess);
fid    = cell(numPlanes, size(ops1,2));
fidRED = cell(numPlanes, size(ops1,2));
fidIntpol = [];
if ops.interpolateAcrossPlanes == 1 && ~isempty(ops.RegFileBinLocation)
    fidIntpol = cell(numPlanes, size(ops1,2));
end

for i = 1:numPlanes
    for j = 1:size(ops1,2)
        mouse_name = getOr(ops, 'mouse_name', []);
        if isempty(mouse_name)
            ops1{i,j}.RegFile = fullfile(ops.RegFileRoot, ...
            sprintf('plane%d.bin',  ...
            i + (j-1)*numPlanes));
        else
            ops1{i,j}.RegFile = fullfile(ops.RegFileRoot, ...
            sprintf('%s_%s_%s_plane%d.bin', ops.mouse_name, ops.date, ...
            ops.CharSubDirs, i + (j-1)*numPlanes));
        
        end
        
        regdir = fileparts(ops1{i,j}.RegFile);
        if ~exist(regdir, 'dir')
            mkdir(regdir);
        end
        
        % open bin file for writing
        fid{i,j}              = fopen(ops1{i,j}.RegFile, 'w');
        
        if red_binary
            mouse_name = getOr(ops, 'mouse_name', []);
            if isempty(mouse_name)
                ops1{i,j}.RegFile2 = fullfile(ops.RegFileRoot, ...
                sprintf('plane%d_RED.bin', ...
                i + (j-1)*numPlanes));
            else
                ops1{i,j}.RegFile2 = fullfile(ops.RegFileRoot, ...
                sprintf('%s_%s_%s_plane%d_RED.bin', ops.mouse_name, ops.date, ...
                ops.CharSubDirs, i + (j-1)*numPlanes));
            end
            
            
            fidRED{i,j}              = fopen(ops1{i,j}.RegFile2, 'w');
        end
        
        if ops.interpolateAcrossPlanes && ~isempty(ops.RegFileBinLocation)
            % open separate files for result after averaging across
            % neighbouring planes
            str = sprintf('%d_',ops1{i,j}.expts);
            str(end) = [];
            folder = fullfile(ops1{i,j}.RegFileBinLocation, ops1{i,j}.mouse_name, ...
                ops1{i,j}.date, str, 'interpolated');
            if ~exist(folder, 'dir')
                mkdir(folder);
            end
            fidIntpol{i,j} = fopen(fullfile(folder, ...
                sprintf('%s_%s_%s_plane%d.bin', ops.mouse_name, ops.date, ...
                ops.CharSubDirs, i + (j-1)*numPlanes)), 'w');
        end
    end
end