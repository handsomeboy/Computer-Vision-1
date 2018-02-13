clear all
clc
close all

training = 1:2:10;
TestFrame1 = [2:2:100];
TestFrame2 = 100:1:200;
TestFrames = [TestFrame1 TestFrame2];

[RSamples,YSamples,GSamples] = colorSamples_GMM();
[meanGreen,varG]=GMM(GSamples,5);
[meanYellow,varY]=GMM(YSamples,5);
[meanRed,varR]=GMM(RSamples,5);

vid = VideoReader('detectbuoy.avi');   
NewVid = VideoWriter('GMMBuoyTest','MPEG-4');
NewVid.FrameRate=5;
open(NewVid);


for frame=1:45

    index = TestFrames(frame);
    frame = read(vid,index);

    [dk1,dc1,final_green]=BuoyDetect(frame,meanGreen,varG);
    BinaryG2 = bwareaopen(final_green,50);
    se2 = strel('disk',6);
    BinaryG3 = imdilate(BinaryG2,se2);
    BG = bwboundaries(BinaryG3);
    figure(2),imshow(frame)
    hold on
    for  k =1:length(BG)
        boundary = BG{k};
        figure(2), plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
        hold on
        title(frame)
    end 
    
    [dkr,dcr,final_red]=BuoyDetect(frame,meanRed,varR);
    BinaryR2 = bwareaopen(final_red,50);
    se2 = strel('disk',6);
    BinaryR3 = imdilate(BinaryR2,se2);
    BR = bwboundaries(BinaryR3);
    hold on
    for  k =1:length(BR)
        boundary = BR{k};
        figure(2), plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        hold on
        title(frame)
    end 
    
    [dky,dcy,final_yellow]=BuoyDetect(frame,meanYellow,varY);
    BinaryY2 = bwareaopen(final_yellow,50);
    se2 = strel('disk',6);
    BinaryY3 = imdilate(BinaryY2,se2);
    BY = bwboundaries(BinaryY3);
    hold on
    for  k =1:length(BY)
        boundary = BY{k};
        figure(2), plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
        hold on
        title(frame)
    end 
    

    
    f = getframe(gca);
    writeVideo(NewVid,f) 

end
close(NewVid)

