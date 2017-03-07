%Begin in the baseFolder, inside the date

baseFolder = 'C:\Users\Harry\Desktop\DataSun\2016_06_08';
dateString = '2016_06_08';
compString = 'Sun';
labelString = 'doubleMutantcuredA';
od = .2;

distanceFromWallThreshold = 40; %Manually input distance from wall in pixels
timeStep = .0333; %Manually input time between frames
distanceStep = .15; %Manually input distance between two pixels in um (standard for this camera is 2.5um/pixel before magnification)

roundFolders = dir([baseFolder,'\Round*']);

for i = 1:size(roundFolders)
    cd(roundFolders(i).name);

    trialFolders = dir([baseFolder,'\',roundFolders(i).name,'\Trial*']);
    
    for j = 1:size(trialFolders)
        cd(trialFolders(j).name);
        
        %load the trajectory
        load([dateString,'_',compString,roundFolders(i).name,trialFolders(j).name,'.mat'])
        
        for k = 1:numel(p)

            farEnoughFromWallVector = makeFarEnoughFromWallVector(distanceFromWallThreshold,p(k).trajectory,params);
            p(k).trajectory(:,9) = farEnoughFromWallVector;

            linSpeedVector = distanceStep*p(k).trajectory(:,6)/timeStep;
            median = nanmedian(linSpeedVector);
            idx = linSpeedVector>2*median;
            linSpeedVector(idx) = NaN; %Rid yourself of absurdly high speeds
            p(k).trajectory(:,6) = linSpeedVector;
    
            p(k).date = dateString;
            p(k).label = labelString;
            p(k).trial = trialFolders(j).name;
            p(k).round = roundFolders(i).name;
            p(k).comp = compString;
            p(k).od = od;
    
            idx = farEnoughFromWallVector == 0;
            linSpeedVectorOffWall = linSpeedVector;
            linSpeedVectorOffWall(idx) = NaN;
            p(k).trajectory(:,10) = linSpeedVectorOffWall;
    
            areaVectorOffWall = p(k).trajectory(:,3);
            areaVectorOffWall(idx) = NaN;
            p(k).trajectory(:,11) = areaVectorOffWall;
        end        
        
        pAnalyzed = p;
        
        save pAnalyzed pAnalyzed
        
        clear p pAnalyzed farEnoughFromWallVector linSpeedVector median idx
        clear linSpeedVectorOffWall areaVectorOffWall B cCross params x
        cd ..
    end

    cd ..

end

clear




