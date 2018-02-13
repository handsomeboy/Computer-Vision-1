vid = VideoReader('Tag2.mp4');
nFrames = vid.NumberOfFrames();
index=1;
v = VideoWriter('VirtualCube_Tag2','MPEG-4');
v.FrameRate = 30;
open(v);

ref_tag = imread('ref_marker.png');

% K matrix
K =[1406.08415449821,0,0;2.20679787308599, 1417.99930662800,0;1014.13643417416,566.347754321696,1]';

for frame = 150 : 270

    frame
    img = read(vid,frame);
    img = rgb2gray(img);   
    img_size = size(img);

    %% Apply filter to image
    H = imgaussfilt(img, 2);

    %% Detect corners

    gradients = edge(H,'Roberts');
    se1 = strel('disk', 5);
    se2 = strel('disk', 4);
    gradients = imdilate(gradients,se1);
    gradients = imerode(gradients,se2);


    figure('Visible','off')
    figure(1), imshow(img)
    hold on

    B = bwboundaries(gradients, 8, 'noholes'); 
    B_size = size(B);
    for i=1:B_size(1)
        BB = B(i);
        BB_size = size(BB);
        for j=1:BB_size(1)
            BB = BB{j};
            agg = dpsimplify(BB,10); 

            ps_size = size(agg);
            if(ps_size(1) == 5) 
                for k=1:ps_size(1)-1
                    for kk=1:2
                        corners(k,kk) = agg(k,kk); 
                    end
                end

                maximum=max(corners,[],1);
                minimum=min(corners,[],1);
                p=norm(maximum(1)-minimum(1));
                q=norm(maximum(2)-minimum(2));
                if((p+q)<25)
                    break;
                end

 

    %% Homography
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

    %% Discretize Tag
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
                   
                   b = [0 0 0 0];

                   if (orientation1 == 1)
                       figure(1), plot(POI(1,1),POI(1,2),'r.','markersize',20)
                       figure(1), plot(POI(2,1),POI(2,2),'g.','markersize',20)
                       figure(1), plot(POI(3,1),POI(3,2),'b.','markersize',20)
                       figure(1), plot(POI(4,1),POI(4,2),'y.','markersize',20)

                       b(1)=discrete_bits(4,4);
                       b(2)=discrete_bits(4,5);
                       b(3)=discrete_bits(5,5);
                       b(4)=discrete_bits(5,4);
                       ID=binaryVectorToDecimal(b,'LSBFirst');
                       text_str = ['ID: ' num2str(ID)];
                       tag_name = text(POI(1,1)+100,POI(1,2),text_str,'Color','b','FontSize',10);

                   elseif (orientation2 == 1)
                       figure(1), plot(POI(2,1),POI(2,2),'r.','markersize',20)
                       figure(1), plot(POI(3,1),POI(3,2),'g.','markersize',20)
                       figure(1), plot(POI(4,1),POI(4,2),'b.','markersize',20)
                       figure(1), plot(POI(1,1),POI(1,2),'y.','markersize',20)

                       b(1)=discrete_bits(4,5);
                       b(2)=discrete_bits(5,5);
                       b(3)=discrete_bits(5,4);
                       b(4)=discrete_bits(4,4);
                       ID=binaryVectorToDecimal(b,'LSBFirst');
                       text_str = ['ID: ' num2str(ID)];
                       tag_name = text(POI(1,1)+100,POI(1,2),text_str, 'Color','b','FontSize',10);

                   elseif (orientation3 == 1)
                       figure(1), plot(POI(3,1),POI(3,2),'r.','markersize',20)
                       figure(1), plot(POI(4,1),POI(4,2),'g.','markersize',20)
                       figure(1), plot(POI(1,1),POI(1,2),'b.','markersize',20)
                       figure(1), plot(POI(2,1),POI(2,2),'y.','markersize',20)

                       b(1)=discrete_bits(5,5);
                       b(2)=discrete_bits(5,4);
                       b(3)=discrete_bits(4,4);
                       b(4)=discrete_bits(4,5);
                       ID=binaryVectorToDecimal(b,'LSBFirst');
                       text_str = ['ID: ' num2str(ID)];
                       tag_name = text(POI(1,1)+100,POI(1,2),text_str,'Color','b','FontSize',10);

                   elseif (orientation4 == 1)
                       figure(1), plot(POI(4,1),POI(4,2),'r.','markersize',20)
                       figure(1), plot(POI(1,1),POI(1,2),'g.','markersize',20)
                       figure(1), plot(POI(2,1),POI(2,2),'b.','markersize',20)
                       figure(1), plot(POI(3,1),POI(3,2),'y.','markersize',20)

                       b(1)=discrete_bits(5,4); 
                       b(2)=discrete_bits(4,4);
                       b(3)=discrete_bits(4,5);
                       b(4)=discrete_bits(5,5);
                       ID=binaryVectorToDecimal(b,'LSBFirst');
                       text_str = ['ID: ' num2str(ID)];
                       tag_name = text(POI(1,1)+100,POI(1,2),text_str,'Color','b','FontSize',10);
                   end
                   %ID

    %% Find projection and orientation of camera wrt tag
                if (orientation1 == 1 || orientation2 == 1 || orientation3 == 1 || orientation4 == 1)
                  
                    m_size=1;
                    ref_points1(:,1) = [0; 0; 1];
                    ref_points1(:,2) = [m_size; 0; 1];
                    ref_points1(:,3) = [m_size; m_size; 1];
                    ref_points1(:,4) = [0; m_size; 1];
                    lena_POI = lena_POI';
                    row_size = size(lena_POI, 2);
                    ones_row = ones(1, row_size);
                    lena_POI = [lena_POI; ones_row];
                    Hom2 = homography2d(ref_points1, lena_POI);
                    H2 = Hom2/Hom2(3,3);

                    RT = inv(K)*H2;
                    Rt(:,1) = RT(:,1);
                    Rt(:,2) = RT(:,2);
                    Rt(:,3) = cross(Rt(:,1),Rt(:,2));
                    Rt(:,4) = RT(:,3);
                    P = K * Rt;

                    x_c1 = P * [0;0;-5;1];
                    x_c1 = x_c1/x_c1(3);
                    line_x1=[x_c1(1) lena_POI(1,1) ];
                    line_y1=[x_c1(2) lena_POI(2,1) ];
                    figure(1), line(line_x1,line_y1,'Color','b','LineWidth',2)

                    x_c2 = P * [m_size;0;-5;1];
                    x_c2 = x_c2/x_c2(3);
                    line_x2=[x_c2(1) lena_POI(1,2) ];
                    line_y2=[x_c2(2) lena_POI(2,2) ];
                    figure(1), line(line_x2,line_y2,'Color','b','LineWidth',2)

                    x_c3 = P * [m_size;m_size;-5;1];
                    x_c3 = x_c3/x_c3(3);
                    line_x3=[x_c3(1) lena_POI(1,3) ];
                    line_y3=[x_c3(2) lena_POI(2,3) ];
                    figure(1), line(line_x3,line_y3,'Color','b','LineWidth',2)

                    x_c4 = P * [0;m_size;-5;1];
                    x_c4 = x_c4/x_c4(3);
                    line_x4=[x_c4(1) lena_POI(1,4) ];
                    line_y4=[x_c4(2) lena_POI(2,4) ];
                    figure(1), plot(line_x4,line_y4,'Color','b','LineWidth',2)

                    line_x5=[x_c1(1) x_c4(1) ];
                    line_y5=[x_c1(2) x_c4(2) ];
                    figure(1), plot(line_x5,line_y5,'Color','b','LineWidth',2)

                    line_x6=[x_c1(1) x_c2(1) ];
                    line_y6=[x_c1(2) x_c2(2) ];
                    figure(1), plot(line_x6,line_y6,'Color','b','LineWidth',2)

                    line_x7=[x_c2(1) x_c3(1) ];
                    line_y7=[x_c2(2) x_c3(2) ];
                    figure(1), plot(line_x7,line_y7,'Color','b','LineWidth',2)

                    line_x8=[x_c3(1) x_c4(1) ];
                    line_y8=[x_c3(2) x_c4(2) ];
                    figure(1), plot(line_x8,line_y8,'Color','b','LineWidth',2)
                end




                else 
                    break;

               end

            end 
        end
    end

    frame = getframe(gca);
    writeVideo(v,frame);

    index = index + 1;
end

%% Create video
close(v);





