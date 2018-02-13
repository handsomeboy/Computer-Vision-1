TrainingSet = 1:2:100;

for i = 1:length(TrainingSet)
    index = TrainingSet(i);
    filename = strcat('Images/TrainingSet/Frames/',num2str(index,'%03i'),'.jpg');
    filename2 = strcat(num2str(index,'%03i'),'.jpg');
    I = imread(filename);
    BW = imcrop(I);
    imwrite(BW,filename2);
end