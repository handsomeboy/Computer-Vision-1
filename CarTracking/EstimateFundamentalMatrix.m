function F = EstimateFundamentalMatrix(x1, x2)
%% EstimateFundamentalMatrix

[tform,inlierpoints1,inlierpoints2] = estimateGeometricTransform(x1,x2,'projective', 'MaxNumTrials', 4000, 'MaxDistance', 1);
% 
% x_good = x1(:,1);
% y_good = x1(:,2);
% x_good_next = x2(:,1);
% y_good_next = x2(:,2);

x_init = x1.Location(:,1);
x_next = x2.Location(:,1);
y_init = x1.Location(:,2);
y_next = x2.Location(:,2);

sizeg = size(x_init);

x1 = x_init; y1 = y_init;
x2 = x_next; y2 = y_next;

X1 = [x1'; y1'; ones(1, sizeg(1))];
X2 = [x2'; y2'; ones(1, sizeg(1))];

[p1, T1] = normalise2dpts(X1);
[p2, T2] = normalise2dpts(X2);

%Plug the 8 matches into the Fundamental Matrix
Y = [p2(1,:)'.*p1(1,:)'   p2(1,:)'.*p1(2,:)'  p2(1,:)' ...
     p2(2,:)'.*p1(1,:)'   p2(2,:)'.*p1(2,:)'  p2(2,:)' ...
     p1(1,:)'             p1(2,:)'            ones(sizeg(1),1) ]; 

[U, S, V] = svd(Y, 0);
V_1 = reshape(V(:, 9), [3 3])';

[FU, FD, FV] = svd(V_1,0);
F = FU*diag([FD(1,1) FD(2,2) 0])*FV';

%Fundamental Matrix and Matlab Fund Matrix
F = T2'*F*T1;

end