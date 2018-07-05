function success = createPatches(imgName)

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Patches creation       %  
%%%%%%%%%%%%%%%%%%%%%%%%%%

img = imread(imgName);

tmpFolder = 'tmp';
outCNNFolder = tmpFolder;

offsets(1, :) = [90, 0];
offsets(2, :) = [-90, 0];
patchPx = 500;

success = 0;

for xOffset=0:90:270    
    offsets(size(offsets, 1) + 1, :) = [0, xOffset];
end

mkdir(tmpFolder);
imgSz = size(img);
indices = [];

for j=1:size(offsets, 1)
    [imgPatch, ind, phi, theta] = extractPatch(img, offsets(j, 1), offsets(j, 2), patchPx, patchPx);
    indices(j, :, :) = ind;
    
    curOutFile = ['Patch', num2str(j), '.png'];        
    imwrite(imgPatch, [tmpFolder, '/', curOutFile]);

    sphCoordFile = ['PatchSC', num2str(j), '.bin'];
    fileID = fopen([tmpFolder, '/', sphCoordFile], 'w');
    fwrite(fileID, patchPx, 'uint16');
    fwrite(fileID, phi, 'single');
    fwrite(fileID, theta, 'single');
    fclose(fileID);
end

save('tmp/indices.mat', 'indices');

success = 1;

end
