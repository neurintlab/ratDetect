function [ fileName,pathName ] = fileFinder( xlRaw,xlfileName,ratName,sessionDate,pathWrite,ii,jj)
%FILEFINDER - this function is called when there is no file name available
%in the excel, and it uses the rat name and session date to find the
%correct file name and update it in the excel for later use.

%Reading the path name from the early rows of the excel to find the video files:
folderPath=(xlRaw{ii,find(strncmp(xlRaw(2,:),'folder',6))}); 
contList = struct2dataset(dir(folderPath));
ratFold= find (strncmp(contList.name,['rat',ratName],8));
addedPath = ([cell2mat(contList.name(ratFold)),'\',sessionDate]);
contList = struct2dataset(dir([folderPath,'\',addedPath,'\*.mp4']));
pathName=[folderPath,addedPath,'\'];
fileNameWriteIndex=excelWrite(find(strncmp(xlRaw(2,:),'fileName',8)));

%% Inside the folder, selecting the file name according to the value of jj:
foldFileNames = contList.name;
foldFileNums=zeros(length(foldFileNames),1);
for kk=1:length(foldFileNames);
    foldFileNums(kk)=str2num(foldFileNames{kk}(2 : end-4));
end
foldFileNums=sort(foldFileNums);
foldFileInd = find(foldFileNums>0);
fileName=foldFileNames{foldFileInd(jj)};

%%
%%Updating the excel with the rest of the path name
rowToWrite=num2str(ii);
pathWrite = excelWrite(find(strncmp(xlRaw(2,:),'added',5)));
xlRange=[pathWrite{1},rowToWrite,':',pathWrite{1},rowToWrite];
xlswrite(xlfileName,{addedPath},'sheet1',xlRange);

foldFileNames = contList.name;
foldFileNums= zeros(length(foldFileNames),1);

for kk=1:length(foldFileNames);
    foldFileNames{kk}=foldFileNames{kk}(2 : end-4);
    foldFileNums(kk)=str2num(foldFileNames{kk});
end

%Updating file name in the excel:
xlRange=[fileNameWriteIndex{jj},rowToWrite,':',fileNameWriteIndex{jj},rowToWrite];
xlswrite(xlfileName,{fileName},'sheet1',xlRange);

end

