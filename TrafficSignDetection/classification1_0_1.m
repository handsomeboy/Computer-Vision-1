clc
clear all
close all
warning off;

% rgbImage = imread('1.jpg');
% load projectedImages.mat;
% load eigenSigns.mat;
% load meanValue.mat;
% load trainNumber.mat;

load variables.mat;

[basefilename,path]= uigetfile({'/Users/Aaron/Documents/MATLAB/Perception/Final/TestDB/*.jpg'},'Open JPEG Test Image File');
testImage= fullfile(path, basefilename);
rgbImage = imread(testImage);

% rgbImage = imresize(rgbImage,.25);
figure; subplot(331); imshow(rgbImage); title('Original image');

yCbCrImg = rgb2ycbcr(rgbImage);
% figure; imshow(yCbCrImg); title('yCbCr image');

%Y = yCbCrImg(:,:,1);
%Cb = yCbCrImg(:,:,2);
Cr = yCbCrImg(:,:,3);

% %figure; imshow(Y); title('Y image');
% %figure; imshow(Cb); title('Cb image');
% figure; imshow(Cr); title('Cr image');

maskCr = Cr > 140;
% figure,imshow(maskCr); title('Mask Image');

sqrBox = regionprops(bwlabel(maskCr),'all');
[numLabel unused] = size(sqrBox);
maxContourArea = 0;
for label = 1 : numLabel    
   height = sqrBox(label).BoundingBox(4);
   width = sqrBox(label).BoundingBox(3);
   if maxContourArea < height * width
       maxAreaNum = label;
       maxContourArea = height * width;
   end 
end

rowMin = sqrBox(maxAreaNum).BoundingBox(2);
rowMax = rowMin + sqrBox(maxAreaNum).BoundingBox(4) - 1;
colMin = sqrBox(maxAreaNum).BoundingBox(1);
colMax = colMin + sqrBox(maxAreaNum).BoundingBox(3) - 1;


croppedImg = rgbImage(rowMin : rowMax, colMin : colMax, : );
subplot(332);  imshow(croppedImg); title('Cropped Image');

%%

yCbCrImg = rgb2ycbcr(croppedImg);
% figure; imshow(yCbCrImg); title('yCbCr image');

croppedCr = yCbCrImg(:,:,3);
subplot(333); imshow(croppedCr); title('Cropped Cr Image');

croppedCr = imfill(croppedCr);
subplot(334); imshow(croppedCr); title('Filled Image');

croppedBw = im2bw(croppedCr,0.55);
subplot(335); imshow(croppedBw); title('Cropped BW Image');


se = strel('disk',3);
croppedBw = double(imopen(croppedBw,se));
subplot(336); imshow(croppedBw); title('After Opening')

% clear segImg;
segImg(:,:,1) = double(croppedImg(:,:,1)) .* croppedBw;
segImg(:,:,2) = double(croppedImg(:,:,2)) .* croppedBw;
segImg(:,:,3) = double(croppedImg(:,:,3)) .* croppedBw;
subplot(337); imshow(uint8(segImg)); title('Seg Image');


segImg = uint8(segImg);
% segImg(croppedBw == 0,1:3) = 255;
% figure; imshow(uint8(segImg)); xlabel('Seg Image');

[m, n] = size(croppedBw);

for i = 1:m
    for j = 1:n
        if croppedBw(i,j) == 0
          % Change from white to our gray level
          segImg (i,j,1) = 255;
          segImg (i,j,2) = 255;
          segImg (i,j,3) = 255;
        end
    end
end

% for i = 1:3
%     tempSeg = segImg(:,:,i);
%     tempSeg(croppedBw == 0) = 255;
%     segImg(:,:,i) = tempSeg;
% end

subplot(338); imshow(segImg); title('Seg Image');


%% Feature Extration

% trainDBPath = 'E:\Kaam\Current\Amol Kale\Test\TrainDB';   %%%%% Give Pathname of the Training Database

segImg = imresize(segImg,[100 100]);
segGrayImg = rgb2gray(segImg);
[irow icol] = size(segGrayImg);
reshapedImage = reshape(segGrayImg',irow*icol,1);

% %%%%%%%%%%%%%%%%%%%%%%%% File management %%%%%%%%%%%%%%%%%%%%%%%%
% trainFiles = dir(trainDBPath);
% trainNumber = 0;
% 
% for i = 1:size(trainFiles,1)
%     if not(strcmp(trainFiles(i).name,'.')|strcmp(trainFiles(i).name,'..')|strcmp(trainFiles(i).name,'Thumbs.db'))
%         trainNumber = trainNumber + 1; % Number of all images in the training database
%     end
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%% Construction of 2D matrix from 1D image vectors %%
% 
% Y = [];
% for i = 1 : 13%trainNumber   
%     % The name of each image in databases is choosen as a sequencial number.
%     
%     str = int2str(i);
%     str = strcat('\',str,'.jpg');
%     str = strcat(trainDBPath,str);
%     
%     img = imread(str);
%     
%     yCbCrImg = rgb2ycbcr(img);
% % figure; imshow(yCbCrImg); title('yCbCr image');
% 
% Cr = yCbCrImg(:,:,3);
% 
% maskCr = Cr > 140;
% % figure,imshow(maskCr); title('Mask Image');
% 
% sqrBox = regionprops(bwlabel(maskCr),'all');
% [numLabel unused] = size(sqrBox);
% maxContourArea = 0;
% for label = 1 : numLabel    
%    height = sqrBox(label).BoundingBox(4);
%    width = sqrBox(label).BoundingBox(3);
%    if maxContourArea < height * width
%        maxAreaNum = label;
%        maxContourArea = height * width;
%    end 
% end
% 
% rowMin = sqrBox(maxAreaNum).BoundingBox(2);
% rowMax = rowMin + sqrBox(maxAreaNum).BoundingBox(4) - 1;
% colMin = sqrBox(maxAreaNum).BoundingBox(1);
% colMax = colMin + sqrBox(maxAreaNum).BoundingBox(3) - 1;
% 
% 
% croppedImg = img(rowMin : rowMax, colMin : colMax, : );
% % figure; imshow(croppedImg); xlabel('Cropped Image');
%         
%     grayImg = rgb2gray(croppedImg);
%     trainResize = imresize(grayImg, [100 100]);
%     
%     [irow, icol] = size(trainResize);
%     temp = reshape(trainResize',irow*icol,1);   % Reshaping 2D images into 1D image vectors
%     Y = [Y temp]; % 'Y' grows after each turn                        
% end
% 
% m = mean(Y,2); % Computing the average image m = (1/P)*sum(Yj's)  (j = 1 : P)
% trainNumber = size(Y,2);
% 
% %%%%%%%%%%%%%%%%%%%%%%%% Calculating the deviation of each image from mean image %%%%%%%%%%%%%%%
% A = [];  
% for i = 1 : trainNumber
%     temp = double(Y(:,i)) - m; % Computing the difference image for each image in the training set Ai = Yi - m
%     A = [A temp]; % Merging all centered images
% end
% %%%%%%%%%%%%%%%%%%%%%%%% Calculating the eigenvectors %%%%%%%%%%%%%%%%%%%%%
% L = A'*A;
% % figure, imshow(L), title('L')
% [V D] = eig(L); % Eigen Vector: V, Eigen Value: D
% 
% L_eig_vec = [];
% for i = 1 : size(V,2) 
%     if( D(i,i)>1 )
%         L_eig_vec = [L_eig_vec V(:,i)];
%     end
% end
% 
% eigenSigns = A * L_eig_vec;
% 
% projectedImages = [];
% Train_Number = size(eigenSigns,2);
% for i = 1 : Train_Number
%     temp = eigenSigns'*A(:,i); % Projection of centered images into signspace
%     projectedImages = [projectedImages temp]; 
% end
% 
% 

%%%%%%%%%%%%%%%%%%%%%%%% Extracting the PCA features from test image %%%%%%

diff = double(reshapedImage)-mean_value; % Centered test image
projectedTestImage = eigenSigns'*diff; % Test image feature vector

%%%%%%%%%%%%%%%%%%%%%%%% Finding Distance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% trainDBPath = '.\TrainDB';  
% trainFiles = dir(trainDBPath);
% trainNumber = 0;
% 
% for i = 1:size(trainFiles,1)
%     if not(strcmp(trainFiles(i).name,'.')|strcmp(trainFiles(i).name,'..')|strcmp(trainFiles(i).name,'Thumbs.db'))
%         trainNumber = trainNumber + 1; % Number of all images in the training database
%     end
% end

Euc_dist = [];
for i = 1 : Train_Number
    q = projectedImages(:,i);
    temp = ( norm( projectedTestImage - q ) )^2;
    Euc_dist = [Euc_dist temp];
end

[Euc_dist_min , Recognized_index] = min(Euc_dist);

% recognizedSign = floor(Recognized_index/10);
recognizedSign = Recognized_index;
% imageNum = mod(Recognized_index,10);
% outputName = strcat(int2str(recognizedSign),'.jpg');

selectedImage = [pwd '/TrainDB/Train (' num2str(recognizedSign) ').jpg'];
selectedImage = imread(selectedImage);

subplot(339); imshow(selectedImage); title('Equivalent Image');
msgbox(['The Sign Selected is : ',int2str(recognizedSign)]);

str = ['Matched image is :  Train (' num2str(recognizedSign) ').jpg'];
disp(str)


