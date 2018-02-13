clear all
clc

vid = VideoReader('detectbuoy.avi');
NewVid = VideoWriter('BuoyTesting','MPEG-4');
open(NewVid);
TestFrame1 = [2:2:100];
TestFrame2 = 100:1:200;
TestFrames = [TestFrame1 TestFrame2];

[meanR, stdR, DataR, meanY, stdY, DataY, meanG, stdG, DataG] = estimate();

for n = 1:length(TestFrames) 
index = TestFrames(n);
frame = read(vid,index);
[L W e] = size(frame);

%GET CHANNELS
redChannel = frame(:, :, 1);
greenChannel = frame(:, :, 2);
blueChannel = frame(:, :, 3);
yellowChannel = (double(redChannel)+double(greenChannel))/2;

%CREATE PROBABILITY MATRIX
P = normpdf(double(redChannel),meanR,stdR);
Pmax = max(P(:));%Find the max probability

%yellow
y_prob = normpdf(double(yellowChannel),meanY,stdY);
Pymax = max(y_prob(:));

%green
greenChannel = (double(greenChannel)+double(blueChannel))/2;
g_prob = normpdf(double(greenChannel),meanG,stdG);
Pgmax = max(g_prob(:));


%MAPPED PROBABILITY MATRIX
input_range = Pmax - 0;
Inputy = Pymax;
Inputg = Pgmax;
output_range =  255 - 0; 

%mapped probability matrices
MappedR = P * (output_range/(input_range));
MappedY = y_prob * (output_range/Inputy);
MappedG = g_prob * (output_range/Inputg);



%CREATE BINARY
%Find red
thresholdR = 240;
Red_Binary = im2bw(frame);
for i =1:480
    for o = 1:640
        if (MappedR(i,o) > thresholdR && MappedY(i,o)<50)
            Red_Binary(i,o) = 1;
        else
            Red_Binary(i,o) = 0;
        end
    end
end
Red_Binary2 = bwareaopen(Red_Binary,6);
se1 = strel('disk', 10);
Red_Binary3 = imdilate(Red_Binary2,se1);

%Find yellow, same method
thresholdY = 240;
YellowBin = im2bw(frame);
for i =1:480
    for o = 1:640
        if (MappedY(i,o) > thresholdY  && MappedR(i,o)< 199 && MappedR(i,o) > 150 && MappedG(i,o) < 90)
            YellowBin(i,o) = 1;
        else
            YellowBin(i,o) = 0;
        end
    end
end
YellowBin2 = bwareaopen(YellowBin,1);
YellowBin3 = imdilate(YellowBin2,se1);


%Find green, same method
thresholdG = 250;
GreenBin   = im2bw(frame);
for i =1:480
    for o = 1:640
        if (MappedG(i,o) > thresholdG && MappedR(i,o)<50 && MappedY(i,o) > 100)
            GreenBin(i,o) = 1;
        else
            GreenBin(i,o) = 0;
        end
    end
end 
GreenBin2 = bwareaopen(GreenBin,4);
GreenBin3 = imdilate(GreenBin2,se1);
%imshow(GreenBin);
% figure

binImage = Red_Binary3 | YellowBin3 | GreenBin3;
binimg = strcat('binary_',num2str(index,'%03i'),'.jpg');
%imwrite(binImage,binimg);

%COUTNOUR PREPARATION
Rtick = 0;
Ytick = 0;
Gtick =0;

BlobR = regionprops(Red_Binary3,'Centroid');
if (length(BlobR) > 0)
rx = BlobR(1).Centroid(1);
ry = BlobR(1).Centroid(2);

xmin = rx - 75;
xmax = rx + 75;
ymin = ry - 75;
ymax = ry + 75;
R_major = MappedR;
for i = 1:L
    for j = 1:W
        if (j<xmin || j>xmax || i<ymin || i>ymax)
            R_major(i,j) = 0;
        end
    end
end
Rtick = 1;
end

%Yellow countour prep
BlobY = regionprops(YellowBin3,'Centroid');
if (length(BlobY) > 0)
yx = BlobY(1).Centroid(1);
yy = BlobY(1).Centroid(2);

xmin = yx - 75;
xmax = yx + 75;
ymin = yy - 75;
ymax = yy + 75;
Y_major = MappedY;
for i = 1:L
    for j = 1:W
        if (j<xmin || j>xmax || i<ymin || i>ymax)
            Y_major(i,j) = 0;
        end
    end
end
Ytick = 1;
end

%Green Prep
BlobG = regionprops(GreenBin2,'Centroid','Area');
if (length(BlobG) > 0)
for s = 1:length(BlobG)
gx = BlobG(s).Centroid(1);
gy = BlobG(s).Centroid(2);
if (Ytick == 1 && (((yy-gy)^2+(yx-gx)^2)^.5 <70 || BlobG(s).Area > 100))
    gy = yy;
    gx = yx;
    break
end
end
end

imshow(frame)
hold on

%DRAW CONTOURS
%Draw red
if(Rtick == 1)
R_major = im2bw(R_major);
B = bwboundaries(R_major);
for  k =1:length(B)
boundary = B{k};
plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end 
end
       
%Draw yellow
if(Ytick == 1)
Y_major = im2bw(Y_major);
B = bwboundaries(Y_major);
for  k =1:length(B)
boundary = B{k};
plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
end 
end

%Draw green
B = bwboundaries(GreenBin3);
for  k =1:length(B)
boundary = B{k};
if (Ytick == 1 && (((yy-gy)^2+(yx-gx)^2)^.5 > 70))
plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
end 
end

title(n)
f = getframe(gca);
im = frame2im(f);
segimg = strcat('output_',num2str(index,'%03i'),'.jpg');
%imwrite(im,segimg);
writeVideo(NewVid,im) 
end
close(NewVid);



