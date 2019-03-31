    function  [c,leds]=filterFrame(fr2read,background,locationMat,i,leds)
%% Detection of center mass of the rat by a background substraction algorithm
     frame=fr2read;
     d=background-frame;% background substraction 
     grayIm=rgb2gray(d);% creating grayscale image
     thresh = graythresh(grayIm);     
     bw = (grayIm >= thresh * 250);% creating binary image
     seD = strel('disk',1);
     bw = imerode(bw,seD);%smoooth
     bw = bwareaopen(bw, 600);%remove ground noise
     centroids1=[];
     centroids2=[];

     stats  = regionprops(bw, {'Centroid','Area'});
     for qq=1:length(stats)% creating vec of all centroids     
         centroids1(qq)=stats(qq).Centroid(1);
         centroids2(qq)=stats(qq).Centroid(2);
     end
     

radius=200;% length of the rat is a reasonable radius parameter
% If there is a recurring detection problem: stop and start over
% condition: only one blob exists after filtering assumed to be the rat 
if length(stats)==1 
    locationMat(1,i-1)=0;
end 

% removing all blobs whose centroids are beyond radius
if ~locationMat(1,i-1)==0
    farCentroids=find(abs(centroids1-locationMat(1,i-1))>radius | abs(centroids2-locationMat(2,i-1))>radius); % fixed?
    stats(farCentroids)=[];
end

% saving centroid coardinates
if ~isempty([stats.Area])
    areaArray = [stats.Area];
    [~,idx] = max(areaArray);
    c = stats(idx).Centroid;
else
    c(1)=locationMat(1,i-1);c(2)=locationMat(2,i-1);

end


 


     
     
     
     
