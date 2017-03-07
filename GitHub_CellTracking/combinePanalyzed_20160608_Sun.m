%%Create a pAnalyzed that has pAnalyzed from all subfolders
%for 5-minuters
path = 'C:\Users\Harry\Desktop\DataSun\2016_06_08'; %SET THIS MANUALLY (more down the page)
roundFolders = dir([path,'\Round*']);
pCombined = [];

for i = 1:size(roundFolders)
    subPath = [path,'\',roundFolders(i).name];
    trialFolders = dir([subPath,'\Trial*']);
    
    for j = 1:size(trialFolders)
    
        endPath = [subPath,'\',trialFolders(j).name];
        load([endPath,'\pAnalyzed.mat']);
        theSize = size(pAnalyzed);

        pCombined = [pCombined pAnalyzed];

        clear endPath
        clear pAnalyzed
        clear theSize
    end
    clear subPath
    clear trialFolders
end

clear i
clear j
clear k

p20160608Sun = pCombined; %SET THIS MANUALLY 
save([path,'\p20160608Sun.mat'],'p20160608Sun'); %SET THIS MANUALLY

clear path
clear roundFolders
clear pCombined
