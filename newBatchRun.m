%% NEW BATCH RUN:
% reads data from a formatted excel file containing the
% following parameters: folder, rat name, date, first frame number and
% background frame number. It uses these to load a batch of experiment
% videos and traces the rat to create a matrix of the rat's location over
% time. It then saves the analyzed data and writes the results in the
% inputed excel file.
% An excel file name can be written in the code (line 16) or entered as function input
% Parameters to change in the code are: version number and path to save
% data: default, catch and backup
% note: this works if the file names in the excel are all filled in or none are

function []=newBatchRun(varargin)%input variables:

%% Loading initial data

%Loading a default excel file if no input was provided
if length('varargin') == 0
    xlfileName = varargin{1};
else
    xlfileName='xlsFileName.xlsx'; %***CHANGE TO CORRECT FILE NAME
end
[~,xlLabel,xlRaw]=xlsread(xlfileName);


%Defining version number to update in the excel file (change if necessary):
version='1.6'; %***

%Definind the drive on which to save the data (change if necessary):
saveMotherFolder='C:\Users\User\Desktop'; % *** WRITE THE FULL PATH
alterPathName='D:'; %***
backupPathName='I:'; %***

%Defining the indexes for session parameters
fileNameIndex=find(strncmp(xlRaw(2,:),'fileName',8));
runCheckIndex=find(strncmp(xlRaw(2,:),'run',3));
versIndex=find(strncmp(xlRaw(2,:),'nai',3));
versionWriteIndex=['A',char(versIndex(1)-27+'A')];
frameIndex=find(strncmp(xlRaw(2,:),'background',8));
dateIndex=find(strncmp(xlRaw(1,:),'last',4));
ratNameIndex=find(strncmp(xlRaw(2,:),'ratID',5));
sessionDateIdx=find(strncmp(xlRaw(2,:),'sessionDate',10));
folderIdx=find(strncmp(xlRaw(2,:),'folder',6));
addedPathIdx=find(strncmp(xlRaw(2,:),'added',5));

%Cells: the function excelWrite returns the column letters in the excel, and it retuns it in a cell variable
runWriteIndex = excelWrite(runCheckIndex);
noDetectIndex=excelWrite(find(strncmp(xlRaw(2,:),'bad',3)));
analysisFileIndex=excelWrite(find(strncmp(xlRaw(2,:),'analysisFile',12)));
numOfFrameNoDetectIndex=excelWrite(find(strncmp(xlRaw(2,:),'numOfFrame',10)));
totalFrameIndex=excelWrite(find(strncmp(xlRaw(2,:),'totalFrame',10)));
fpsIndex=excelWrite(find(strncmp(xlRaw(2,:),'fps',3)));
pathWrite=excelWrite(find(strncmp(xlRaw(2,:),'added',5)));


%% Start the loop on sessions:

%First loop runs sessions, and runs each session
for ii=3:(length(xlLabel))
    %Preparing a variable to indicate on which line the program is currently working on:
    rowToWrite=num2str(ii);
    
    %Second loop runs over the separate vidoes in a single session
    for jj=1:length(runCheckIndex)
        if strcmp(xlLabel{ii,runCheckIndex(jj)},'yes')==0 && strcmp(xlLabel{ii,runCheckIndex(jj)},'skip')==0 && strcmp(xlLabel{ii,fileNameIndex(jj)},'no file')==0
            
            %Reading rat name and session date of current session
            ratName = xlRaw{ii,ratNameIndex};
            sessionDate = xlRaw{ii,sessionDateIdx};
            
            %%Check if a file name exists in the excel
            if ischar([xlRaw{ii,fileNameIndex(jj)}])==0;
                %This section cunstructs the path and find the file name
                [fileName,pathName] = fileFinder(xlRaw,xlfileName,ratName,sessionDate,pathWrite,ii,jj);
            else
                %Read the file name from the excel:
                pathName=([xlRaw{ii,folderIdx},xlRaw{ii,addedPathIdx},'\']);
                fileName=xlRaw{ii,fileNameIndex(jj)};
            end
            
            %%
            %Loading the video according to the path name:
            vidObj = VideoReader([pathName,fileName]);
            
            %For first videos we read first and background frames from the
            %Excel to use as input for ratDetect:
            fprintf('running session on line %1.0f file %1.0f',ii,jj) %printing the seesion currently worked on:
            if strcmp(xlRaw{2,fileNameIndex(jj)},'fileName1')==1
                background = xlRaw {ii,frameIndex(ceil(jj/2))};
                firstFrame = xlRaw {ii,frameIndex(ceil(jj/2))+1};
                [locationMat,output_variables] = analyzeVideo(vidObj,background,firstFrame,runWriteIndex,ii,jj);
                a=1;
                
                %%
            else %End of condition for first video file (fileName2)
                %For second video files whice are a continuation, we define
                %No background frame and the first frame as 1:
                background = [];
                firstFrame = 1;
                if ~exist('output_variables.backgroundFrame')
                    output_variables=[];
                    fileNamePrev=xlRaw{ii,fileNameIndex(jj-1)};
                    vidObjPrev = VideoReader([pathName,fileNamePrev]);
                    background = xlRaw {ii,frameIndex(ceil(jj/2))};
                    output_variables.backgroundFrame=read (vidObjPrev,background);
                end
                background = [];
                firstFrame = 1;
                [locationMat,output_variables] = analyzeVideo(vidObj,background,firstFrame,runWriteIndex,ii,jj,output_variables.backgroundFrame);
            end %End of video condition
            
            pathName=[saveMotherFolder,['\analysis\'],ratName,'\',sessionDate,'\'];
            alterPathName=([alterPathName,ratName,'\',sessionDate,'\']);% make it local
            
            %Saving the analized files on the web driver:
            
            if ~ (exist(pathName,'dir')) % If directory of a required date does not exist, opens a new one
                mkdir(pathName);
            end %End of mkdir cond
            
            if isempty(output_variables) == 0
                noDetectIdx=output_variables.noDetectIdx;
                fps=vidObj.FrameRate;
                backgroundFrame=output_variables.backgroundFrame;
                framesIdx=output_variables.framesIdx;
                %Giving the figures names:
                currDate=date;
                set(output_variables.h2,'Name',[fileName,' ',currDate,' ', version]);
                set(output_variables.h1,'Name',[fileName,' ',currDate,' ', version]);
                figure(output_variables.h2);
                title([ratName,' ',sessionDate,' Rat Track']);
                figure(output_variables.h1);
                title([ratName,' ',sessionDate,' background']);
                h1=output_variables.h1;
                h2=output_variables.h2;
                
                
                %Collapsing the parameters meant for saving:
                params2save.locationMat=locationMat;
                params2save.firstFrame=firstFrame;
                params2save.background=background;
                params2save.fps=fps;
                params2save.noDetectIdx=noDetectIdx;
                params2save.framesIdx=framesIdx;
                
                %saving the analyzed data:
                try
                    saveData(pathName,fileName,params2save,ii,jj,h1,h2);
                catch
                    
                    saveData(alterPathName,fileName,params2save,ii,jj,h1,h2);
                end
                
                %Saving the analyzed files on the backup driver:
                %This should fit the computer the program is running on
                backupPathName1=([backupPathName,ratName,'\',sessionDate,'\']);
                saveData(backupPathName1,fileName,params2save,ii,jj,h1,h2);
                
                %%
                %%Updating excel file:
                try
                    
                    %Writing 'yes' in the run column of the file
                    xlRange=[runWriteIndex{jj},rowToWrite,':',runWriteIndex{jj},rowToWrite];
                    xlswrite(xlfileName,{'yes'},'sheet1',xlRange);
                    
                    %Writing the version number the file was analized with
                    versionWriteIndex=excelWrite(versIndex(1)-1+jj);
                    xlRange=[versionWriteIndex{1},rowToWrite,':',versionWriteIndex{1},rowToWrite];
                    xlswrite(xlfileName,{version},'sheet1',xlRange);
                    
                    %Writing percent of not detected frames:
                    %XlRange=[noDetectIndex{jj},rowToWrite,':',noDetectIndex{jj},rowToWrite];
                    %Xlswrite(xlfileName,{noDetectPercent},'sheet1',xlRange);
                    
                    %Updating analysis file name:
                    analysisFileName=strcat(fileName,'_location');
                    xlRange=[analysisFileIndex{jj},rowToWrite,':',analysisFileIndex{jj},rowToWrite];
                    xlswrite(xlfileName,{analysisFileName},'sheet1',xlRange);
                    
                    %Updating the number of frames not detected:
                    if isempty(noDetectIdx) == 1
                        noDetectIdx = 0;
                        xlRange=[numOfFrameNoDetectIndex{jj},rowToWrite,':',numOfFrameNoDetectIndex{jj},rowToWrite];
                        xlswrite(xlfileName,{noDetectIdx},'sheet1',xlRange);
                    else xlRange=[numOfFrameNoDetectIndex{jj},rowToWrite,':',numOfFrameNoDetectIndex{jj},rowToWrite];
                        xlswrite(xlfileName,{length(noDetectIdx)},'sheet1',xlRange);
                    end
                    
                    %Updating total frame number:
                    totalFrame = [vidObj.NumberOfFrames-firstFrame];
                    xlRange=[totalFrameIndex{jj},rowToWrite,':',totalFrameIndex{jj},rowToWrite];
                    xlswrite(xlfileName,{totalFrame},'sheet1',xlRange);
                    
                    %Writing the date the file was analized
                    dateWriteIndex=excelWrite(dateIndex(1)-1+jj);
                    xlRange=[dateWriteIndex{1},rowToWrite,':',dateWriteIndex{1},rowToWrite];
                    xlswrite(xlfileName,{currDate},'sheet1',xlRange);
                    
                    %%
                catch %If the excel could not be updated, write it in a notepad file for reference:
                    if ~ (exist('MyFile.txt','file'));
                        fid=fopen('MyFile.txt','w');
                        fprintf(fid, ['video number ' num2str(jj) ' in row ' num2str(ii) ' was not saved locally for backup'],['\n']);
                        fclose(fid);
                    else
                        fid=fopen('MyFile.txt','a');
                        fprintf(fid, [blanks(30) 'video number ' num2str(jj) ' in row ' num2str(ii) ' was not saved locally for backup'],['\n']);
                        fclose(fid);
                    end %End of condition
                    disp(['video number ',num2str(jj),' in row ',num2str(ii),' was not updated in the excel file. needed updates: run: yes fps:',num2str(fps), ' version: ',num2str(version)]);
                end %End of try and catch
            end
        end %End of skip cond
    end %End of file loop (jj)
    %Making sure update happens only after a successful analysis:
    if exist('h1','var') == 1 && exist('output_variables','var')
        if h1==output_variables.h1
            %Writing the fps of the files
            xlRange=[fpsIndex{1},rowToWrite,':',fpsIndex{1},rowToWrite];
            xlswrite(xlfileName,{fps},'sheet1',xlRange);
        end %End of save condition
    end %End of list loop
end %End of session loop (ii)




