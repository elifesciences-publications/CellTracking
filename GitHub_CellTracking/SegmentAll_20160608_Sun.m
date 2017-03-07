%Begin in the baseFolder

baseFolder = 'C:\Users\Harry\Desktop\DataSun\2016_06_08'; %change this

roundFolders = dir([baseFolder,'\Round*']);

for i = 1:size(roundFolders)
    cd(roundFolders(i).name);
    trialFolders = dir([baseFolder,'\',roundFolders(i).name,'\Trial*']);
    
    for j = 1:size(trialFolders)
        cd(trialFolders(j).name);
        
        params.path = [baseFolder,'\',roundFolders(i).name,'\',trialFolders(j).name];
        File = dir([params.path,'\fc2*']);
        params.BaseFile = 'fc2';
        params.allFiles = File;
        params = MakeMaskVR(params);
        params.offset = 1;
        params.numParticles = 4;
        params.increment = 50;
        params.threshold = 19;
        params.imCloseDiamter = 16;
        params.AreaLimits = [300 8000];
        % Run the segmentation
        particleMatrix8bit_EC_newBG_median_VideoReaderERODE(params,1);
        % get the number of frames in each movie
        vr = VideoReader([params.path,'/',params.allFiles(1).name]);
        params.numFrames(1) = vr.NumberOfFrames;
        % Create locationMatrix -- make sure you save params along with it.
        locationMatrix = [];
        struct = load([params.path,'/',params.BaseFile,'_',num2str(1)]);
        lmTemp = struct.locationMatrix;
        locationMatrix = [locationMatrix; lmTemp];
        
        clear struct
        clear lmTemp
        save locationMatrix locationMatrix params
        clear locationMatrix
        clear params
        
        cd ..
    end
    
    cd ..  
end



