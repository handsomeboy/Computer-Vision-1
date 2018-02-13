clear all
clc
close all

% Video Writer

video = VideoWriter('VisualOdometry','MPEG-4');

video.FrameRate = 30;
open(video);

%Extract the camera parameters for each image
[fx, fy, cx, cy, G_camera_image, LUT] = ReadCameraModel('Oxford_dataset/stereo/centre','Oxford_dataset/model');

K = [fx, 0, cx;
     0, fy, cy;
     0, 0, 1];
cameraParams = cameraParameters('IntrinsicMatrix',K');
 
start_position = [0 0 0];
R1_position = [1 0 0;
        0 1 0
        0 0 1];

position_2 = [0 0 0];
R2_position = [1 0 0;
        0 1 0
        0 0 1];    
    
cd Oxford_dataset/stereo/centre

images.filename = ls('*png');
image_size = size(images.filename); 

for frame = 200:3699%size_im(1)-1
    frame
    
    %From Bayer to RGB
    Image = imread(images.filename(frame,:));
    
    extracted = demosaic(Image,'gbrg');
    %Get the next frame from the current
    new_image = imread(images.filename(frame+1,:));
    new_extracted = demosaic(new_image,'gbrg');
  
    % imshow(I);
    %figure(2), imshow(J_next);
    
    %Undistort both images (i and i+1)
    img = UndistortImage(extracted, LUT);
    %imshow(img)
    next_image = UndistortImage(new_extracted, LUT);
    
    %%Denoise image
    img = imgaussfilt(img, 0.8);
    next_image = imgaussfilt(next_image, 0.8);

    %%Gray Image
    img = rgb2gray(img);
    next_image = rgb2gray(next_image);
  
    
    %% Feature extraction from both the images (Harris or FAST)
    harris_feat_1 = detectSURFFeatures(img);
    harris_feat_2 = detectSURFFeatures(next_image); 
    
    [feat1,valid_points1] = extractFeatures(img, harris_feat_1);
    [feat2,valid_points2] = extractFeatures(next_image, harris_feat_2);
    
    matchedPairs = matchFeatures(feat1,feat2, 'MaxRatio', 0.26);
    match_pair1 = valid_points1(matchedPairs(:,1),:);
    match_pair2 = valid_points2(matchedPairs(:,2),:); 
    
    
    x_good = match_pair1.Location(:,1);
    y_good = match_pair1.Location(:,2);
    x_good_next = match_pair2.Location(:,1);
    y_good_next = match_pair2.Location(:,2);
    

    %% Fundamental Matrix with RANSAC
    [fRANSAC, inliersIdx] = estimateFundamentalMatrix(match_pair1,match_pair2,'Method','RANSAC','NumTrials',2000,'DistanceThreshold',1e-3);
    % Kovesi Fundamental Matrix
    F = EstimateFundamentalMatrix(match_pair1,match_pair2);
    
    m_locX1 = match_pair1.Location(:,1);
    m_locY1 = match_pair1.Location(:,2);
    fear_inliers1 = [m_locX1(inliersIdx) m_locY1(inliersIdx)];
    
    m_locX2 = match_pair2.Location(:,1);
    m_locY2 = match_pair2.Location(:,2);
    feat_inliers2 = [m_locX2(inliersIdx) m_locY2(inliersIdx)]; 
    
%% Essential Matrix
    [E1, R1, t1] = EssentialMatrixFromFundamentalMatrix(F,K,cameraParams, match_pair1.Location, match_pair2.Location);
    [E2, R2, t2] = EssentialMatrixFromFundamentalMatrix(fRANSAC,K,cameraParams, fear_inliers1, feat_inliers2);
    

    
%% Trajectory

    R1_position = R1 * R1_position;
    start_position = start_position + t1 * R1_position;
%     if (pos1(3) - init_pos(3)) < 0
%         pos1(3) = -pos1(3)
%     end
    
    % fRANSAC
    R2_position = R2 * R2_position;
    position_2 = position_2 + t2 * R2_position;
    
    figure(8)
    subplot(1,2,2)
    title('Matched Features')
    %showMatchedFeatures(img, next_image, match_pair1, match_pair2);
    imshow(img)
    subplot(1,2,1)
    title('Visual Odometry')
    plot(start_position(1),start_position(3),'bo', position_2(1),position_2(3),'g*')
    legend('Visual Odometry(function)','Visual Odometry(MATLAB)','Location','SouthEast')
    hold on
    
    frame = getframe(gcf);
    pause(0.001);
    writeVideo(video,frame);
    
    pause(0.001);
end

cd ../../..
close(video)










