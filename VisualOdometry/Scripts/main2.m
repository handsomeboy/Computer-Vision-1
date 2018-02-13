clear all
clc
close all

% Video Writer

v = VideoWriter('VisualOdometry','MPEG-4');
v.FrameRate = 30;
open(v);

%Extract the camera parameters for each image
[fx, fy, cx, cy, G_camera_image, LUT] = ReadCameraModel('Oxford_dataset/stereo/centre','Oxford_dataset/model');

K = [fx, 0, cx;
     0, fy, cy;
     0, 0, 1];
cameraParams = cameraParameters('IntrinsicMatrix',K');
 
pos_init = [0 0 0];
pos1 = [0 0 0];
Rpos1 = [1 0 0;
        0 1 0
        0 0 1];

pos2 = [0 0 0];
Rpos2 = [1 0 0;
        0 1 0
        0 0 1];    
    
cd Oxford_dataset/stereo/centre

images.filename = ls('*png');
size_im = size(images.filename); 

for f = 200:3699%size_im(1)-1
    f
    
    %From Bayer to RGB
    I = imread(images.filename(f,:));
    J = demosaic(I,'gbrg');

    %Get the next frame from the current
    I_next = imread(images.filename(f+1,:));
    J_next = demosaic(I_next,'gbrg');
    % imshow(I);
    %figure(2), imshow(J_next);
    
    %Undistort both images (i and i+1)
    img = UndistortImage(J, LUT);
    %figure(3), imshow(img)
    img_next = UndistortImage(J_next, LUT);
    %figure(4), imshow(img_next)
    
    %%Denoise image
    img = imgaussfilt(img, 0.8);
    img_next = imgaussfilt(img_next, 0.8);

    %%Gray Image
    img = rgb2gray(img);
    img_next = rgb2gray(img_next);
  
    
    %% Feature extraction from both the images (Harris or FAST)
    harris1 = detectSURFFeatures(img);
    harris2 = detectSURFFeatures(img_next); 
    
    [features1,valid_points1] = extractFeatures(img, harris1);
    [features2,valid_points2] = extractFeatures(img_next, harris2);
    
    indexPairs = matchFeatures(features1,features2, 'MaxRatio', 0.3);
    matchedPoints1 = valid_points1(indexPairs(:,1),:);
    matchedPoints2 = valid_points2(indexPairs(:,2),:); 
    
    %figure(5); showMatchedFeatures(img, img_next, matchedPoints1, matchedPoints2);
    
    
    x_good = matchedPoints1.Location(:,1);
    y_good = matchedPoints1.Location(:,2);
    x_good_next = matchedPoints2.Location(:,1);
    y_good_next = matchedPoints2.Location(:,2);
    

    %% Fundamental Matrix with RANSAC
    [fRANSAC, inliersIdx] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'Method','RANSAC','NumTrials',2000,'DistanceThreshold',1e-3);
    % Kovesi Fundamental Matrix
    F = EstimateFundamentalMatrix(matchedPoints1,matchedPoints2);
    
    m1X = matchedPoints1.Location(:,1);
    m1Y = matchedPoints1.Location(:,2);
    inliers1 = [m1X(inliersIdx) m1Y(inliersIdx)];
    
    m2X = matchedPoints2.Location(:,1);
    m2Y = matchedPoints2.Location(:,2);
    inliers2 = [m2X(inliersIdx) m2Y(inliersIdx)]; 
    
%% Essential Matrix
    [E1, R1, t1] = EssentialMatrixFromFundamentalMatrix(F,K,cameraParams, matchedPoints1.Location, matchedPoints2.Location);
    [E2, R2, t2] = EssentialMatrixFromFundamentalMatrix(fRANSAC,K,cameraParams, inliers1, inliers2);
    

    
%% Trajectory

    Rpos1 = R1 * Rpos1;
    pos1 = pos1 + t1 * Rpos1;
%     if (pos1(3) - init_pos(3)) < 0
%         pos1(3) = -pos1(3)
%     end
    
    % fRANSAC
    Rpos2 = R2 * Rpos2;
    pos2 = pos2 + t2 * Rpos2;
    
    figure(8)
    subplot(1,2,2)
    title('Matched Features')
    showMatchedFeatures(img, img_next, matchedPoints1, matchedPoints2);
    subplot(1,2,1)
    title('Visual Odometry')
    plot(pos1(1),pos1(3),'bo', pos2(1),pos2(3),'g*')
    legend('Visual Odometry(function)','Visual Odometry(MATLAB)')
    hold on
   
    frame = getframe(gcf);
    writeVideo(v,frame);
    
    pause(0.001);
end

cd ../../..
close(v)










