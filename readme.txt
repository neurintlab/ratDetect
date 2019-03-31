--------------
Rat Detection
--------------

This code was written and used for an automatic offline frame by frame extraction of 
2D coordinates of a rat from a video stream.

The function gets an excel file with the details of video files, and extracts the 
location of the animal in each frame. the rat track is saved as .fig file, and the XY coordinates are saved 
in .m file. a report of the detection is automatically saved in the xls file.


----------------------
Algorithm psuedo code:
----------------------
	frame = frame - background
	frame=rgb2gray(frame)
	frame=bw(otsu(frame))
	frame=erode(frame)
	frame=denoise(frame)
	c=centroids(frame)


--------------- 
Specifications: 
---------------
	MATLAB 2012b (may run on other versions)
	video camera: Panasonic HC-V279/ HC-W850 (not mandatory)
	Video file format: mp4
	Camera angle: bird's eye view
	Rat species: Long Evans (other species may require paameter adaptation due to color differces)
	Behavioral arena: preferably light colors
	A bakground frame of the arena without the animal is needed 
	
----------------	       
Running the code
----------------

1. Download files
2. Fill details in xls file (see example xls file- only the filled cells are necessary).
3. Open the newBatchRun.mat file
4. Update xlfileName (line 21) and saveMotherFolder (line 30)
5. Run newBatchRun.mat





