function ops1 = getBlockBegEnd(fid, ops1)

Ly = ops.Ly;
Lx = ops.Ly;
bitspersamp = 16; %this is hard-coded for now, needs to change

frewind(fid); % rewind the file just in case
offset = 0; % offset keeps track of the starting byte for each block
for k = 1:length(ops.SubDirs) % loop through all blocks
    nFramesBlock = ops1.Nframes(k); % read the number of frames per block 
    nfrtoread = min(nFramesBlock, ops.nimgbegend); % average at most the number of frames in this block
    
    fseek(fid, offset, 'bof'); % seek to the start of the block
    data = fread(fid,  Ly*Lx*nfrtoread, '*int16'); % read exactly this many frames
    data  = reshape(data, Ly, Lx, nfrtoread); % reshape into the image size
    ops1.mimg_beg(:,:,k) = mean(data, 3); % average frames
        
    
    fseek(fid, offset + bitspersamp/8 * Ly * Lx * (nFramesBlock - nfrtoread), 'bof'); % seek to the end of the block 
    data = fread(fid,  Ly*Lx*nfrtoread, '*int16'); % same as above
    data  = reshape(data, Ly, Lx, nfrtoread);% same as above
    ops1.mimg_end(:,:,k) = mean(data, 3);% same as above
    
    offset = offset + bitspersamp/8 * Ly * Lx * nFramesBlock; % finally, increase offset to the next block
end