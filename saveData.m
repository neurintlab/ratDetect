function [] = saveData(pathName,fileName,params2save,rowNum,vidNum,h1,h2)
%saveData - this function saves the parameters:
%'locationMat','firstFrame','background','fps','noDetectIdx','framesIdx' as
%they were analized in the location appointed to it, and if that folder
%doesn't exist, it creates it. If it is unable to save for some reason, it
%records it's failiure in a txt file saved locally

%unloading variables from params2save
locationMat=params2save.locationMat;
firstFrame=params2save.firstFrame;
background=params2save.background;
fps=params2save.fps;
noDetectIdx=params2save.noDetectIdx;
framesIdx=params2save.framesIdx;

try
    % if directory of a required date does not exist, opens a new one
    if ~ (exist(pathName,'dir'))
        mkdir(pathName);
    end %end of mkdir cond
    
    %saving data:
    save([pathName,fileName,'_location.mat'],'locationMat',...
        'firstFrame','background','fps','noDetectIdx','framesIdx');
    hgsave(h2,[pathName,fileName,'_ratTrack.fig']);
    hgsave(h1,[pathName,fileName,'_background.fig']);
    
    
    % remove comment on the following lines to save a jpeg of the background
    % and the tracking data:
    
    %saveas(h1,[alterPathName,fileName,'_background.jpg']);
    %saveas(h2,[pathName,fileName,'_ratTrack.jpg']);
    
catch
    
    %Making a note that the video was saved in an alternative path
    if ~ (exist('MyFile.txt','file'));
        fid=fopen('MyFile.txt','w');
        fprintf(fid, ['video number ' num2str(vidNum) ' in row ' num2str(rowNum) ' was saved in catch'],['\n']);
        fclose(fid);
    else
        fid=fopen('MyFile.txt','a');
        fprintf(fid, [blanks(10) 'video number ' num2str(vidNum) ' in row ' num2str(rowNum) ' was saved in catch'],['\n']);
        fclose(fid);
    end
end

