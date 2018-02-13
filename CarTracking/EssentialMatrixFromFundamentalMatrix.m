function [E, R, t] = EssentialMatrixFromFundamentalMatrix(F,K,cameraParams, inliers1, inliers2)
E = K' * F * K;
[U, D, V] = svd(E);
e = (D(1,1) + D(2,2)) / 2;
D(1,1) = e;
D(2,2) = e;
D(3,3) = 0;
E = U * D * V';
[U, ~, V] = svd(E);

W = [0 -1 0;
     1 0 0; 
     0 0 1];
Z = [0 1 0; 
    -1 0 0; 
     0 0 0];

R1 = U * W * V';
if det(R1) < 0
    R1 = -R1;
end
R2 = U * W' * V';
if det(R2) < 0
    R2 = -R2;
end

Tx = U * Z * U';
t1 = [Tx(3, 2), Tx(1, 3), Tx(2, 1)];

t2 = -t1;

Rs = cat(3, R1, R1, R2, R2);
Ts = cat(1, t1, t2, t1, t2);

%% Choose the right solution
Negatives = zeros(1, 4);
Pos1 = cameraMatrix(cameraParams, eye(3), [0,0,0]);
for k = 1:size(Ts, 1)
   Pos2 = cameraMatrix(cameraParams,Rs(:,:,k)', Ts(k, :));
% Triangulation
   points3D_1 = zeros(size(inliers1, 1), 3, 'like', inliers1);
   Pos1_a = Pos1';
   Pos2_a = Pos2';

   M1 = Pos1_a(1:3, 1:3);
   M2 = Pos2_a(1:3, 1:3);

   c1 = -M1 \ Pos1_a(:,4);
   c2 = -M2 \ Pos2_a(:,4);

   for kk = 1:size(inliers1,1)
      u1 = [inliers1(kk,:), 1]';
      u2 = [inliers2(kk,:), 1]';
      a1 = M1 \ u1;
      a2 = M2 \ u2;
      A = [a1, -a2];
      y = c2 - c1;

      alpha = (A' * A) \ A' * y;
      p = (c1 + alpha(1) * a1 + c2 + alpha(2) * a2) / 2;
      points3D_1(kk, :) = p';
   end
   points3D_2 = bsxfun(@plus, points3D_1 * Rs(:,:,k)', Ts(k, :));
   Negatives(k) = sum((points3D_1(:,3) < 0) | (points3D_2(:,3) < 0));
end

[val, idx] = min(Negatives);
R = Rs(:,:,idx)';
t = Ts(idx, :);
tNorm = norm(t);
if tNorm ~= 0
    t = t ./ tNorm;
end


%% Rotation and translation
R = R';
t = -t * R;
end
