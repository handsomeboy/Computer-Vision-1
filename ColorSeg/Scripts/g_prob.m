function [ prob ] = g_prob( data, mu, sigma, dim )
% Implement Probability densiy function of Gaussian Mixture Model
% Written by Sifei Li, May 2016
% input: data: the input color pixel data, len * 3
%        mu: mean, dim * 3
%        sigma: covariance matrix, 3 * 3 * dim
%        dim: dimension of GMM 
% output:prob: probability, len * dim

% compute the constant in Pdf for each dim
[len, ~] = size(data);
cons = zeros(1,dim);
for i = 1:dim
    cons(i) = 1/((2 * pi) ^ (dim / 2) * det(sigma(:,:,i)) ^ 0.5);
end

prob = zeros(len, dim); % initialize the prob result

for i = 1:dim
    diff = double(data) - repmat(mu(i,:),size(data,1), 1);
    part = diff * inv(sigma(:,:,i));
    for j = 1:len
        prob(j,i) = exp(-0.5 * part(j,:) * diff(j,:)') * cons(i);
    end
end

end

