clear all
clc

vid = VideoReader('detectbuoy.avi');
NewVid = VideoWriter('BuoyTest3D','MPEG-4');
open(NewVid);

[u_Red covR u_Green covG u_Yellow covY] = estimate3D();

TestFrame1 = [2:2:100];
TestFrame2 = 100:1:200;
TestFrames = [TestFrame1 TestFrame2];

for n = 1:length(TestFrames)
    index = TestFrames(n);
    frame = read(vid,index);

    [L W asd] = size(frame);
    R = frame(:, :, 1);
    G = frame(:, :, 2);
    B = frame(:, :, 3);
    Re1 = reshape(R,L*W,1);
    Ge1 = reshape(G,L*W,1);
    Be1 = reshape(B,L*W,1);
    DataPoint = [Re1 Ge1 Be1];
    DataPoint = double(DataPoint);

    [row_c col_c] = size(R);
    r_prob = mvnpdf(DataPoint,u_Red,covR);
    Prmax = max(r_prob(:));

    y_prob = mvnpdf(DataPoint,u_Yellow,covY);
    Pymax = max(y_prob(:));

    g_prob = mvnpdf(DataPoint,u_Green,covG);
    Pgmax = max(g_prob(:));

    input_range = Prmax - 0;
    inputY = Pymax-0;
    inputG = Pgmax-0;
    output_range =  255 - 0; 

    norm_Red = r_prob*(output_range/(input_range));
    norm_Yellow = y_prob*(output_range/(inputY));
    norm_Green = g_prob*(output_range/(inputG));

    norm_Red = reshape(norm_Red,L,W);
    norm_Yellow = reshape(norm_Yellow,L,W);
    norm_Green = reshape(norm_Green,L,W);

    R_conv1 = norm_Red;
    indexR = (R_conv1 < 250);
    R_conv1(indexR) = 0;

    se1 = strel('disk', 10);
    R_conv = imdilate(R_conv1,se1);
    imshow(R_conv)

    Y_conv = norm_Yellow;
    indexY = (Y_conv < 240);
    indexYr = (norm_Red > 22);
    Y_conv(indexY) = 0;
    Y_conv(indexYr) = 0;

    se1 = strel('disk', 10);
    Y_conv2 = imdilate(Y_conv,se1);

    G_conv = norm_Green;
    indexG = (G_conv < 240);
    G_conv(indexG) = 0;
    indexGy = (Y_conv > 250);

    se1 = strel('disk', 10);
    G_conv2 = imdilate(G_conv,se1);
    imshow(G_conv)

    R_tick = 0;
    Y_tick = 0;
    G_tick =0;

    R_conv = im2bw(R_conv);
    MidMassR = regionprops(R_conv,'Centroid');
    if (length(MidMassR) > 0)
        rx = MidMassR(1).Centroid(1);
        ry = MidMassR(1).Centroid(2);

        xmin = rx - 75;
        xmax = rx + 75;
        ymin = ry - 75;
        ymax = ry + 75;
        R_major = norm_Red;
        for i = 1:row_c
            for j = 1:col_c
                if (j<xmin || j>xmax || i<ymin || i>ymax)
                    R_major(i,j) = 0;
                end
            end
        end
        R_tick = 1;
    end

    Y_conv = im2bw(Y_conv);
    MidMassY = regionprops(Y_conv,'Centroid');
    if (length(MidMassY) > 0)
    yx = MidMassY(1).Centroid(1);
    yy = MidMassY(1).Centroid(2);

    xmin = yx - 75;
    xmax = yx + 75;
    ymin = yy - 75;
    ymax = yy + 75;
    Y_major = norm_Yellow;
    for i = 1:row_c
        for j = 1:col_c
            if (j<xmin || j>xmax || i<ymin || i>ymax)
                Y_major(i,j) = 0;
            end
        end
    end
    Y_tick = 1;
    end

    G_conv = im2bw(G_conv);
    MidMassG = regionprops(G_conv,'Centroid');
    if (length(MidMassG) > 0)
    gx = MidMassG(1).Centroid(1);
    gy = MidMassG(1).Centroid(2);

    xmin = gx - 75;
    xmax = gx + 75;
    ymin = gy - 75;
    ymax = gy + 75;
    G_major = norm_Green;
    for i = 1:row_c
        for j = 1:col_c
            if (j<xmin || j>xmax || i<ymin || i>ymax)
                G_major(i,j) = 0;
            end
        end
    end
    G_tick = 1;
    end

    imshow(frame)
    hold on
    if (R_tick == 1)
        R_major = im2bw(R_major);
        B = bwboundaries(R_major);
        for  k =1:length(B)
            boundary = B{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end 
    end

    if (Y_tick == 1)
        Y_major = im2bw(Y_major);
        B = bwboundaries(Y_major);
        for  k =1:length(B)
            boundary = B{k};
            plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
        end 
    end
    if (G_tick == 1)
        G_major = im2bw(G_major);
        B = bwboundaries(G_conv2);
        for  k =1:length(B)
            boundary = B{k};
            if (((yy-gy)^2+(yx-gx)^2)^.5 > 70)
                plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
            end
        end 
    end

    binImage = R_major | Y_major | G_major;
    binimg = strcat('binary3D_',num2str(index,'%03i'),'.jpg');
    imwrite(binImage,binimg);

    title(index)
    f = getframe(gca);
    im = frame2im(f);
    segimg = strcat('output3D_',num2str(index,'%03i'),'.jpg');
    imwrite(im,segimg);
    writeVideo(NewVid,im) 
end
close(NewVid);