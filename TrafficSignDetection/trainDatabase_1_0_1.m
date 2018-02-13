clc; close all; clear all;

%% Path
trainDBPath = '/Users/Aaron/Documents/MATLAB/Perception/Final/TrainDB';   %%%%% Give Pathname of the Training Database

%%%%%%%%%%%%%%%%%%%%%%%% File management %%%%%%%%%%%%%%%%%%%%%%%%
trainFiles = dir(trainDBPath);
trainNumber = 0;

for i = 1:size(trainFiles,1)
    if not(strcmp(trainFiles(i).name,'.')|strcmp(trainFiles(i).name,'..')|strcmp(trainFiles(i).name,'Thumbs.db'))
        trainNumber = trainNumber + 1; % Number of all images in the training database
    end
end

%%%%%%%%%%%%%%%%%%%%%%%% Construction of 2D matrix from 1D image vectors %%

Y = [];
for i = 1 : trainNumber
    % The name of each image in databases is choosen as a sequencial number.
    
    str = int2str(i);
    str = strcat('/',str,'.jpg');
    str = strcat(trainDBPath,str);
    
    img = imread([pwd '/TrainDB/Train (' num2str(i) ').jpg']);
    
    yCbCrImg = rgb2ycbcr(img);
    % figure; imshow(yCbCrImg); title('yCbCr image');

    Cr = yCbCrImg(:,:,3);

    maskCr = Cr > 140;
    % figure,imshow(maskCr); title('Mask Image');

    sqrBox = regionprops(bwlabel(maskCr),'all');
    [numLabel, unused] = size(sqrBox);
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


    croppedImg = img(rowMin : rowMax, colMin : colMax, : );
    % figure; imshow(croppedImg); title('Cropped Image');

    grayImg = rgb2gray(croppedImg);
    trainResize = imresize(grayImg, [100 100]);

    [irow, icol] = size(trainResize);
    temp = reshape(trainResize',irow*icol,1);   % Reshaping 2D images into 1D image vectors
    Y = [Y temp]; % 'Y' grows after each turn                        
end

mean_value = mean(Y,2); % Computing the average image m = (1/P)*sum(Yj's)  (j = 1 : P)
trainNumber = size(Y,2);

%%%%%%%%%%%%%%%%%%%%%%%% Calculating the deviation of each image from mean image %%%%%%%%%%%%%%%
A = [];  
for i = 1 : trainNumber
    temp = double(Y(:,i)) - mean_value; % Computing the difference image for each image in the training set Ai = Yi - m
    A = [A temp]; % Merging all centered images
end
%%%%%%%%%%%%%%%%%%%%%%%% Calculating the eigenvectors %%%%%%%%%%%%%%%%%%%%%
L = A'*A;
% figure, imshow(L), title('L')
[V, D] = eig(L); % Eigen Vector: V, Eigen Value: D

L_eig_vec = [];
for i = 1 : size(V,2) 
    if( D(i,i)>1 )
        L_eig_vec = [L_eig_vec V(:,i)];
    end
end

eigenSigns = A * L_eig_vec;

projectedImages = [];
Train_Number = size(eigenSigns,2);
for i = 1 : Train_Number
    temp = eigenSigns'*A(:,i); % Projection of centered images into signspace
    projectedImages = [projectedImages temp]; 
end

 %save('projectedImages.mat','projectedImages');
 %save('eigenSigns.mat','eigenSigns');
 %save('meanValue.mat','mean_value');
 %save('trainNumber.mat','Train_Number');

save('variables.mat','projectedImages','eigenSigns','mean_value','Train_Number');


