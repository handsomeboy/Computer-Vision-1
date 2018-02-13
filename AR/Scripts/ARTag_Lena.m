vid = VideoReader('Tag0.mp4');
nFrames = vid.NumberOfFrames();
num=1;
v = VideoWriter('Projected_Lena_Tag1','MPEG-4');
open(v);
ref_tag = imread('ref_marker.png');
lena_img = imread('lena.png');
dimension_lena = size(lena_img);

for frame = 500 : 660
    if frame == 586
        continue
    end
    img = read(vid,frame);
    img = rgb2gray(img);   
    img_dimensions = size(img);
    img2 = read(vid,frame); 
    %% Apply filter
    H = imgaussfilt(img, 2);

    %% Corner detection
    gradients = edge(H,'Roberts');
    se1 = strel('disk', 5);
    se2 = strel('disk', 4);
    gradients = imdilate(gradients,se1);
    gradients = imerode(gradients,se2);

    B = bwboundaries(gradients, 8, 'noholes'); 
    B_size = size(B);
    for i=1:B_size(1)
        BB = B(i);
        BB_size = size(BB);
        for j=1:BB_size(1)
            BB = BB{j};
            ps = dpsimplify(BB,10); 

            ps_size = size(ps);
            if(ps_size(1) == 5) 
                for k=1:ps_size(1)-1
                    for kk=1:2
                        corners(k,kk) = ps(k,kk);
                    end
                end

                maximum_corners=max(corners,[],1);
                minimum_corners=min(corners,[],1);
                p=norm(maximum_corners(1)-minimum_corners(1));
                q=norm(maximum_corners(2)-minimum_corners(2));
                if((p+q)<25)
                    break;
                end

        %% HOMOGRAPHY
                     ref_size = size(ref_tag);
                     ref_points(1,:) = [1, 1];
                     ref_points(2,:) = [200, 1];
                     ref_points(3,:) = [200, 200];
                     ref_points(4,:) = [1, 200];
                     POI = [corners(:,2), corners(:,1)];
                     H = fitgeotrans(ref_points, POI,'projective');
                     invH = inv(H.T');
                     H_1 = projective2d(invH');

                     RA = imref2d([ref_points(3,1) ref_points(3,2)], [1 ref_points(3,1)-1], [1 ref_points(3,1)-1]);
                     [warp,r] = imwarp(img, H_1, 'OutputView', RA);                          
                     th = graythresh(warp);
                     markBin = im2bw(warp, th);

        %% Discretize image
                    discrete_bits = detectBits(markBin, ref_points);
                    flag = isBit(discrete_bits);

                   if flag == 1 
                       orientation1 = 0; orientation2 = 0; orientation3 = 0; orientation4 = 0;
                       if (discrete_bits(6,6) == 1)
                           orientation1 = 1; orientation2 = 0; orientation3 = 0; orientation4 = 0;
                           lena_POI = [POI(1,1),POI(1,2);POI(2,1),POI(2,2);POI(3,1),POI(3,2);POI(4,1),POI(4,2)];
                       end
                       if (discrete_bits(6,3) == 1)
                           orientation1 = 0; orientation2 = 1; orientation3 = 0; orientation4 = 0;
                           lena_POI = [POI(2,1),POI(2,2);POI(3,1),POI(3,2);POI(4,1),POI(4,2);POI(1,1),POI(1,2)];
                       end
                       if (discrete_bits(3,3) == 1)
                           orientation1 = 0; orientation2 = 0; orientation3 = 1; orientation4 = 0;
                           lena_POI = [POI(3,1),POI(3,2);POI(4,1),POI(4,2);POI(1,1),POI(1,2);POI(2,1),POI(2,2)];
                       end
                       if (discrete_bits(3,6) == 1)
                           orientation1 = 0; orientation2 = 0; orientation3 = 0; orientation4 = 1;
                           lena_POI = [POI(4,1),POI(4,2);POI(1,1),POI(1,2);POI(2,1),POI(2,2);POI(3,1),POI(3,2)];
                       end

    %% Warp lena_img onto tag
                   source = [1, 1;dimension_lena(1), 1;dimension_lena(1), dimension_lena(2);1, dimension_lena(1)];
                   H_matrix = fitgeotrans( source, lena_POI,'projective');
                   RA2 = imref2d([img_dimensions(1) img_dimensions(2)], [1 img_dimensions(2)-1], [1 img_dimensions(1)-1]);
                   [warp_lena,r2] = imwarp(lena_img, H_matrix, 'OutputView', RA2);
                   warped_size = size(warp_lena);
    %                figure, imshow(warp_lena)
                   for i_l=1:img_dimensions(1)
                       for j_l=1:img_dimensions(2)
                           for k_l=1:3
                               if(warp_lena(i_l,j_l,k_l)~=0)
                                   img2(i_l,j_l,k_l) = warp_lena(i_l,j_l,k_l);
                               end
                           end
                       end
                   end
                   figure(1), imshow(img2)
                   hold on
                else 
                    break;

               end

            end
        end
    end

    frame = getframe(gca);
    writeVideo(v,frame);

    num = num + 1;
    pause(0.001)
end

close(v);