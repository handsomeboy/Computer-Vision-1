clc
clear all
close all

% Gaussian Kernel
mu = 2;
sigma = 2;
index = -floor(mu/2) : floor(mu/2);
[X, Y] = meshgrid(index, index);
G = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
G = G / sum(G(:));

% Camera Model
[fx, fy, cx, cy, G_camera_image, LUT] = ReadCameraModel('Oxford_dataset/stereo/centre','Oxford_dataset/model'); 

% Camera Matrix
K = [fx 0 0; 0 fy 0; cx cy 1];

cameraParams = cameraParameters('IntrinsicMatrix',K);

% Get Files
frames_directory = fullfile('Oxford_dataset', 'stereo','centre');
cd(frames_directory);
files.filename = ls('*png'); %all files with .png type
Frames = files.filename;
% frameSet = imageSet(frames_directory);
% Frames = frameSet(1).ImageLocation;
% Frames = Frames';

current_pt = [0;0;0;1];

for f = 1000:1000
    f
    filepath = Frames(f,:);
    filepath_next = Frames(f+1,:);
    img = imread(filepath);
    img_next = imread(filepath_next);
    color_img = demosaic(img,'gbrg');
    color_img_next = demosaic(img_next, 'gbrg');
    
    color_img_ud = UndistortImage(color_img,LUT);    
    color_img_next_ud = UndistortImage(color_img_next,LUT);
    
    img_ud = rgb2gray(color_img_ud);
    img_next_ud = rgb2gray(color_img_next_ud);
    
    img_ud = imfilter(img_ud, G);
    img_next_ud = imfilter(img_next_ud, G);
    
    points1 = detectSURFFeatures(img_ud);
    points2 = detectSURFFeatures(img_next_ud);
    
    [f1,vpts1] = extractFeatures(img_ud,points1);
    [f2,vpts2] = extractFeatures(img_next_ud,points2);
    
    indexPairs = matchFeatures(f1,f2, 'MaxRatio', 0.3);
    matchedPoints1 = vpts1(indexPairs(:,1));
    matchedPoints2 = vpts2(indexPairs(:,2));
    
    matches1 = matchedPoints1.Location;
    matches2 = matchedPoints2.Location;
    
    matches_1_x = matches1(:,1);
    matches_1_y = matches1(:,2);
    matches_2_x = matches2(:,1);
    matches_2_y = matches2(:,2);
    
    dist = sqrt((matches_2_x - matches_1_x).^2 + (matches_2_y - matches_1_y).^2);
    thresh = 20;
    final_matches = find(dist<thresh);
    
    for n = 1:size(final_matches,1)
        index = final_matches(n);
        matches_1_final(n,:) = matches1(index,:);
        matches_2_final(n,:) = matches2(index,:);
    end
    
    F = EstimateFundamentalMatrix(matches_1_final,matches_2_final);
    
    E = EssentialMatrixFromFundamentalMatrix(F,K);
    [U,S,V] = svd(E);
    diag_110 = [1 0 0; 0 1 0; 0 0 0];
    V = V';
    newE = U*diag_110*V;
    [U,S,V] = svd(newE);
    
    W = [0, -1, 0; 1, 0, 0; 0, 0, 1];
    Z = [0 1 0; -1 0 0; 0 0 0];
    
    R1 = U * W * V;
    R2 = U * transpose(W) * V;
    
    if det(R1) < 0
        R1 = -R1;
    end

    if det(R2) < 0
        R2 = -R2;
    end
    
    Tx = U * Z * U';
    t = [Tx(3, 2), Tx(1, 3), Tx(2, 1)];
    tNorm = norm(t);
    if tNorm ~= 0
        t = t ./ tNorm;
    end
    

    po=R2*po+t1';
    [Rot,tran] = cameraPose(F,cameraParams,inliers1,inliers2);
    %   figure(7)
    %     plot(po(1), po(2),'bo');
    %     hold on,
    %location=-t2*R2';
    R1
    Rot
    Rot=Rot*Rpos;
    location=location+tran*Rot;
    %  location=location/location(1,3);
    figure(7)
    plot3(location(1), location(2),location(3),'bo');
    hold on
%     figure(2)
%     showMatchedFeatures(img_ud,img_next_ud,matchedPoints1,matchedPoints2);
    %legend('matched points 1','matched points 2');
    %current_pt = next_pt;
end

cd ../../..