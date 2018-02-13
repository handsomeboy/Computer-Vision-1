% Robotics: Estimation and Learning 
% WEEK 1
%  written by Sifei Li, May 2016
function [segI, loc,prob_image] = BuoyDetect(I,mu,sigma)
%% Hard code your learned model parameters here
% load('mu.mat', 'mu');
% load('sigma.mat', 'sigma');

thre = 0.000005;

%% Find ball-color pixels using your model
[m n c] = size(I);

data = reshape(I, [m*n, 3]);
dim = 3;
prob = g_prob( data, mu, sigma, dim );
prob_sum = sum(prob, 2);
prob_bi(find(prob_sum > thre)) = 1;
prob_bi(find(prob_sum <= thre)) = 0;
prob_image = reshape(prob_bi, m, n);
% imshow(prob_image);

%% Do more processing to segment out the right cluster of pixels.
% You may use the following functions.
%   bwconncomp
%   regionprops
ball = bwconncomp(prob_image);


center_struct = regionprops(prob_image, 'centroid'); 
center = cat(1, center_struct.Centroid);

%% Compute the location of the ball center
%

segI = prob_image;
loc = 1;


end
