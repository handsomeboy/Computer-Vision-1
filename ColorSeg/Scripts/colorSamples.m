function [RedBouyData YellowBuoyData GreenBuoyData] = colorSamples()
    X = 1:2:100;

    %Red Buoy
    RedData = [];
    GreenData = [];
    BlueData = [];
    for i = 1:length(X)
        index = X(i);
        full_name = strcat('Images/TrainingSet/CroppedBuoys/R_',num2str(index,'%03i'),'.jpg');    
        frame = imread(full_name);  


        redChannel = frame(:, :, 1);
        greenChannel = frame(:, :, 2);
        blueChannel = frame(:, :, 3);


        [a b] = size(redChannel);
        pixelR = [];
        pixelG = [];
        pixelB = [];
        for i = 1:a
            for j = 1:b
                pixelR = [pixelR redChannel(i,j)];
                pixelG = [pixelG greenChannel(i,j)];
                pixelB = [pixelB blueChannel(i,j)];
            end
        end
        pixelR = pixelR';
        pixelG = pixelG';
        pixelB = pixelB';

        RedData = [RedData ; pixelR];
        GreenData = [GreenData; pixelG];
        BlueData = [BlueData ; pixelB];

        RedBouyData = [RedData GreenData BlueData];

    end
     
%     figure
%     scatter3(RedData,GreenData,BlueData,5,'r');
%     title('Red Buoy Color Distribution')
%     xlabel('Red')
%     ylabel('Green')
%     zlabel('Blue')
% 
% 
%     f = getframe(gcf);
%     im = frame2im(f);

    %%
    %Yellow Buoy
    RedData = [];
    GreenData = [];
    BlueData = [];
    for i = 1:2:100
        full_name = strcat('Images/TrainingSet/CroppedBuoys/Y_',num2str(i,'%03i'),'.jpg');     
        frame = imread(full_name);  


        redChannel = frame(:, :, 1);
        greenChannel = frame(:, :, 2);
        blueChannel = frame(:, :, 3);


        [a b] = size(redChannel);
        pixelR = [];
        pixelG = [];
        pixelB = [];
        for i = 1:a
            for j = 1:b
                pixelR = [pixelR redChannel(i,j)];
                pixelG = [pixelG greenChannel(i,j)];
                pixelB = [pixelB blueChannel(i,j)];
            end
        end
        pixelR = pixelR';
        pixelG = pixelG';
        pixelB = pixelB';

        RedData = [RedData ; pixelR];
        GreenData = [GreenData; pixelG];
        BlueData = [BlueData ; pixelB];

        YellowBuoyData = [RedData GreenData BlueData];

    end
    
%     figure
%     scatter3(RedData,GreenData,BlueData,5,'y')
%     title('Yellow Buoy Color Distribution')
%     xlabel('Red')
%     ylabel('Green')
%     zlabel('Blue')
%     f = getframe(gcf);
%     im = frame2im(f);


    %%
    %Green Buoy
    RedData = [];
    GreenData = [];
    BlueData = [];
    for i = 1:2:44
        full_name = strcat('Images/TrainingSet/CroppedBuoys/Y_',num2str(i,'%03i'),'.jpg');     
        frame = imread(full_name);  


        redChannel = frame(:, :, 1);
        greenChannel = frame(:, :, 2);
        blueChannel = frame(:, :, 3);


        [a b] = size(redChannel);
        pixelR = [];
        pixelG = [];
        pixelB = [];
        for i = 1:a
            for j = 1:b
                pixelR = [pixelR redChannel(i,j)];
                pixelG = [pixelG greenChannel(i,j)];
                pixelB = [pixelB blueChannel(i,j)];
            end
        end
        pixelR = pixelR';
        pixelG = pixelG';
        pixelB = pixelB';

        RedData = [RedData ; pixelR];
        GreenData = [GreenData; pixelG];
        BlueData = [BlueData ; pixelB];

        GreenBuoyData = [RedData GreenData BlueData];

    end
    
    
    
%     figure
%     scatter3(RedData,GreenData,BlueData,5,'g')
%     title('Green Buoy Color Distribution')
%     xlabel('Red')
%     ylabel('Green')
%     zlabel('Blue')
%     f = getframe(gcf);
%     im = frame2im(f);

end




        
