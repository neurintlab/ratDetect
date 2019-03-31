function [ locationMat,output_variables ] = analyzeVideo(vidObj,background,firstFrame,runWriteIndex,ii,jj,varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if(nargin~=6) 
   backgroundFrame=varargin{1,1};
end

if mod(jj,2)==1
    [locationMat,output_variables]= ratDetect(vidObj,background,firstFrame);
else [locationMat,output_variables]= ratDetect(vidObj,background,firstFrame,backgroundFrame);
end


end

