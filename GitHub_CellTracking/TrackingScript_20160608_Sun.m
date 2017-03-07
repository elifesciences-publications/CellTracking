load locationMatrix.mat
%%
plotLocationMatrixAny(locationMatrix,1,1,size(locationMatrix,1))
%%
% PREPARE FOR TRACKING
% locationMatrix is broken into segments of delta frames - each of which is
% tracked separately and then joined at the end of the script.
nF = size(locationMatrix,1);
delta = 5000; %frames per tracked chunk.
params.delta = delta;
sFs = 1:delta:nF;
params.sFs = sFs;
% setting this to 40 works MUCH better - consider a filter.
%params.rmBlobsThresh = 500;

locationMatrixR = locationMatrix;
%locationMatrixR = locationMatrixMI(:,1:5,:);
%locationMatrixR = RemoveSecondaryBlobsAtWalls(locationMatrix,params); % removes objects on the wall smaller than rmBlobsThresh
%figure
%locationMatrixR = RemoveSmallObjects(locationMatrixR,params.rmBlobsThresh);
%plotLocationMatrixAny(locationMatrixR,1,1,size(locationMatrix,1))
% locationMatrixR has small blobs and blobs near the chamber boundary
% removed.  this deals with the fact that the cells can often be split into
% two chunks when they are near the boundary.
%% TRACK
params.joinFramesThresh = 20;
for i=1:numel(sFs)
    sprintf('current chunk %i of %i',i,numel(sFs))
    % joinFrames solves the linear assignment problem for each pair of
    % frames for the entire chunk.  This results in a bunch of segments
    % that then need to be join using newGaps.
    if i<numel(sFs)
        a = joinFrames(locationMatrixR(sFs(i):sFs(i+1),:,:),params.joinFramesThresh,[1 1 0 0 0]);
    else
        a = joinFrames(locationMatrixR(sFs(i):end,:,:),params.joinFramesThresh,[1 1 0 0 0]);
    end

     a = cleanTraces(a,1,1);
     a = newGaps(a,80);
     a = cleanTraces(a,5,5);
     a = newGaps(a,1500);
     a = cleanTraces(a,100,100);
   

       %      chunk 7 8
%      a = cleanTraces(a,1,1);
%      a = newGaps(a,80);
%         a = cleanTraces(a,5,5);
%         a = newGaps(a,500);
%         a = cleanTraces(a,20,20);
%         a = newGaps(a,500);


     
    B{i} = a; % put the joined tracks into a cell array where each entry 
end
%% PLOT ALL OF THE CHUNKS.
plotAllChunks(B,params)

%% remove the first and last chunk which we will not analyze.
%B = B(2:end-1);
save trackedB B params
%% PLOT CHUNKS MANUALLY THAT NEED INSPECTION -- if you need more info about
% what is going on.  
%ch = 28;
%figure
%for i=1:size(B{ch},3)
   %sprintf('%i traces in this segment.',size(B{ch},3))
   %plot(B{ch}(:,2,i))
   %hold all
   %end
%% checking crossings with SVMs will not work with the previously constructed 
% training set because the old training data was constructed with tracking
% data from the 15fps webcams, not these 30fps PointGrey cameras we are
% using now.  For now, rework examine interactions to get some data.  
%% CHECK CROSSING EVENTS that remain uncertain
    params.CrossingThreshold = 70;
    i = 2;
    B = examineInteractionIllinois(B,i,params);
    %pack % there is a memory leak in the java GUI that I do not understand. 
    % this keeps it from getting out of hand.  Lame.
%% save B with fixed interactions
save BwithFixedInteractions B params
%% JOIN CELLS.
x = joinCells(B);
%% LOOK FOR INSANITY
% sort in order of appearance
for i=1:size(x,3)
    sInd(i) = find(~isnan(x(:,1,i)),1,'first');
end
[sortInd IX] = sort(sInd,'ascend');
% sort x so that trajectories are in order of appearance.
xS = x(:,:,IX);
xS = getVelocitiesOmega_EC_forTracking(xS);

%% examine basic properties of traces -- incorrect identification of interaction
% events is typically evident here.

figure('pos',[100 500 1400 400])
for i=1:size(xS,3)
    subplot(1,3,1)
    %plot(squeeze(xS(:,3,i)))

    tmp = sqrt(xS(:,3,i)./sqrt(1 - xS(:,4,i).^2)*pi); 
    plot(nanmoving_average(tmp,400))
    hold all
    title('length of major axis for equiv ellipse')
    %plot(tmp)
    
    subplot(1,3,2)
    plot(nanmoving_average(xS(:,6,i),400))
    hold all
    title('speed')
    
    subplot(1,3,3)
    plot(nanmoving_average(xS(:,3,i),1000))
    hold all
    title('areas')
end

blue = 1;
green = 2;
red = 3;
cyan = 4;

x = xS;

%% clean up messy things
% Typically DO NOT need to run

% x(1:7037,:,[3 2]) = x(1:7037,:,[2 3]);
% 
% x(1:9000,:,[1 2]) = x(1:9000,:,[2 1]);


%% examine again
%Only need to run if you ran the previous cell
figure('pos',[100 500 1400 400])
for i=1:size(x,3)
    subplot(1,3,1)

    tmp = sqrt(x(:,3,i)./sqrt(1 - x(:,4,i).^2)*pi); 
    plot(nanmoving_average(tmp,400))
    hold all
    title('length of major axis for equiv ellipse')
    
    subplot(1,3,2)
    plot(nanmoving_average(x(:,6,i),400))
    hold all
    title('speed')
    
    subplot(1,3,3)
    plot(nanmoving_average(x(:,3,i),1000))
    hold all
    title('areas')
end
%% save the fixed x
save xTrajectoriesFixed x
%% ENTER DIVISION TIMES, SPLIT TRAJECTORIES, CONCATENATE WALL LOGICAL.
%% not tested.
% x = xS;
% params.numDivs = 2;
% params.wallBoundary = 30;
% [junk params splits] = SplitIntoDivisions(x,params);
%%

p(1).trajectory = x(1:9000,:,blue);
p(1).isFull = 0;
p(1).hasBeg = 0;
p(1).hasEnd = 0;
p(1).lineage = 1;

%p(2).trajectory = x(1:9000,:,green);
%p(2).isFull = 0;
%p(2).hasBeg = 0;
%p(2).hasEnd = 0;
%p(2).lineage = 2;
% 
% p(3).trajectory = x(1:9000,:,red);
% p(3).isFull = 0;
% p(3).hasBeg = 0;
% p(3).hasEnd = 0;
% p(3).lineage = 3;
% 
% p(4).trajectory = x(1:9000,:,red);
% p(4).isFull = 0;
% p(4).hasBeg = 0;
% p(4).hasEnd = 0;
% p(4).lineage = 2;


%% SAVE B,p,params.
% cCross = getCorrectCrossings(B,params);
cCross = [];
dog = strsplit(params.path,'\');
save([dog{numel(dog)-2} '_' 'Sun' dog{numel(dog)-1} dog{numel(dog)}],'p','B','params','cCross','x');
clear

