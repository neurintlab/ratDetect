 function [locationMat,output]=ratDetect(vidObj,background,firstFrame,varargin)

%% List of parameters:
%numFrames=500;
numFrames=vidObj.NumberOfFrames;
firstFrameNum=firstFrame; % first frame with the rat
firstFrame=read(vidObj,firstFrame);
currDate=date;
if(nargin~=4) 
   backgroundFrame=read(vidObj,background);
else
   backgroundFrame=varargin{1,1};
end
h1=figure;
image(backgroundFrame); title(' Background ');

% detecting all red pixels coordinates from background frame (timer)
[row, col] = find(backgroundFrame(:,:,1)>253 & backgroundFrame(:,:,2)<150 & backgroundFrame(:,:,3)<150);
if isempty(row) %if there is no timer we define the timer location parameters as 0
    leds.timer_maxCol = 0; leds.timer_minCol = 0;
    leds.timer_maxRow = 0;  leds.timer_minRow = 0;
else    
    leds.timer_maxCol = max(col); leds.timer_minCol = min(col);
    leds.timer_maxRow = max(row); leds.timer_minRow = min(row);
end
leds.counter=2;
leds.countStop=0;
leds.flag=0;
leds.frameIndex=firstFrameNum;

leds.avgG=mean(mean(backgroundFrame(row,col,2)));
leds.avgB=mean(mean(backgroundFrame(row,col,3)));

% initializing function output variables
leds.ledTiming=zeros(1,length(firstFrameNum:numFrames));
locationMat=zeros(2,length(firstFrameNum:numFrames));
framesIdx=zeros(1,length(firstFrameNum:numFrames));
i=2;

%% Tracking and localizing the rat in each frame
% first frame
[c,leds] = filterFrame(firstFrame,backgroundFrame,locationMat,i,leds);       
          locationMat(1,i-1)=c(1);locationMat(2,i-1)=c(2);
          framesIdx(1,i-1)=firstFrameNum;
          %i=i+1;      
          startRow=c(1);startCol=c(2);
          bar = waitbar(0,'Analyzing, Please wait') ;

%all frames

for t=firstFrameNum+1:numFrames-1
     frame=read(vidObj,t);
     [c,leds] = filterFrame(frame,backgroundFrame,locationMat,i,leds);
     locationMat(1,t-firstFrameNum+1)=c(1);
     locationMat(2,t-firstFrameNum+1)=c(2); % updating x,y coardinates for plot 
     framesIdx(1,i)=t;
         i=i+1;
         %disp(t);
         if (numFrames)/10==round(numFrames)/10
         switch t
             case [round(numFrames)/10]
                 waitbar (0.1,bar,'Analyzing, Please wait: 10% done');
             case [round(numFrames)*2/10]
                 waitbar (0.2,bar,'Analyzing, Please wait: 20% done');
             case [round(numFrames)*3/10]
                 waitbar (0.3,bar,'Analyzing, Please wait: 30% done');
             case [round(numFrames)*4/10]
                 waitbar (0.4,bar,'Analyzing, Please wait: 40% done');
             case [round(numFrames)*5/10]
                 waitbar (0.5,bar,'Analyzing, Please wait: 50% done');
             case [round(numFrames)*6/10]
                 waitbar (0.6,bar,'Analyzing, Please wait: 60% done');
             case [round(numFrames)*7/10]
                 waitbar (0.7,bar,'Analyzing, Please wait: 70% done');
             case [round(numFrames)*8/10]
                 waitbar (0.8,bar,'Analyzing, Please wait: 80% done');
             case [round(numFrames)*9/10]
                 waitbar (0.9,bar,'Analyzing, Please wait: 90% done');
         end
         end
end

% last frame and presentation of track on it
lastFrame=read(vidObj,numFrames);
h2=figure;
delete(bar);
[c,leds] = filterFrame(lastFrame,backgroundFrame,locationMat,i,leds);                    
          endRow=c(1); endCol=c(2);
          image(lastFrame);
          hold on;
          title(['Rat Track ']);
scatter(locationMat(1,:),locationMat(2,:),9,'filled');               

% Operations on locationMat
locationMat(1,i)=c(1);locationMat(2,i)=c(2);
plot(locationMat(1,:),locationMat(2,:),'r');  
text(startRow-10,startCol - 30,'Start','FontSize',12,'Color','y');
text(endRow-10,endCol - 30,'End','FontSize',12,'Color','y');  

temp=abs(diff(locationMat,1,2));
noDetectIdx=find(temp(1,:)==0)+1;

% plot no detections
plot(locationMat(1,noDetectIdx),locationMat(2,noDetectIdx),'g.'); 
noDetectIdx=framesIdx(noDetectIdx);

% Operations on framesIdx
framesIdx(1,i)=numFrames;

% Packinng output values
output.framesIdx=framesIdx;
output.h1=h1;
output.h2=h2;
output.backgroundFrame=backgroundFrame;
output.noDetectIdx=noDetectIdx;
