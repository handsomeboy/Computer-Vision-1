clear all
load('variables')
cd 'Dataset2/input'

mu = 5;
sigma = 2;
index = -floor(mu/2) : floor(mu/2);
[X Y] = meshgrid(index, index);
H = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
H = H / sum(H(:));

x = [1 1628 1628 1];
y = [1 1 618 618];

mask = poly2mask(x,y, 1236, 1628);

sign_folder = 'signs/';

v = VideoWriter('traffic_sign','MPEG-4');
v.FrameRate = 30;
open(v);

files(1).filename = ls('*jpg');
names = files(1).filename;

for fr = 95:95%size(names,1)
    fr
    name = names(fr,:);
    img = imread(name);
    I = imfilter(img, H);
    figure 
    imshow(I)
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);

    red = uint8(max(0, min(R-B, R-G)));
    blue = uint8(max(0, min(B-R, B-G)));
    gray = 3*R-.5*B-2*G;
    gray_norm = gray.*(255./max(gray));
    
    bb = im2bw(blue,.15);
    br = im2bw(red,.15);

    rb = red + blue;
    crop = uint8(immultiply(rb,mask));
    figure 
    imshow(crop)
    
%%  MSER
    [r,f] = vl_mser(crop,'MinDiversity',0.7,'MaxVariation',0.2,'Delta',8) ;
    f = vl_ertr(f) ;
    
    M = zeros(size(crop));
    for x=r'
     s = vl_erfill(crop,x);
     M(s) = M(s) + 1;
    end
    
    
    thresh = graythresh(M);
    M = im2bw(M, thresh);
    se = strel('octagon',9);
    M = imdilate(M, se);
    
    regions = regionprops( M, 'BoundingBox');
%% SVM classification    
    figure(2) ;
    clf ; imagesc(img) ; hold on ; axis equal off; colormap gray ;
    for k = 1 : length(regions)
        box = regions(k).BoundingBox;
        aspect_ratio = box(3)/box(4);
        if aspect_ratio < 1.2 && aspect_ratio > 0.7
            sign = imcrop(img, box);

            candidate = im2single(imresize(sign,[64 64]));

            hog_1 = vl_hog(candidate, 4);
            imhog = vl_hog('render', hog_1, 'verbose');
            
            [hog_r, hog_c] = size(hog_1);
            dim = hog_r*hog_c;
            hog_1_trans = permute(hog_1, [2 1 3]);
            hog_test=reshape(hog_1_trans,[1 dim]); 
            testFeatures = hog_test;

            [predictedLabel,score, cost] = predict(classifier, testFeatures);
            label = str2num(predictedLabel);
            im_name = strcat(sign_folder,predictedLabel,'.png');
            im = imread(im_name);
            im = uint8(imresize(im, [box(4) box(4)]));    
            score(1,label)
            if score(1,label)> -0.04
                rectangle('Position', box,'EdgeColor','r','LineWidth',2)
                image([int64(box(1)-box(4)) int64(box(1)-box(4)) ],[int64(box(2)) int64(box(2))],im);
            end
        end

    end
    
    frame = getframe(gca);
    writeVideo(v,frame);
    
    pause(0.001);
    cla
end

cd ..
cd ..
close(v)
