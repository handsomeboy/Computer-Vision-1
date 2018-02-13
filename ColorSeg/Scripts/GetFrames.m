TrainingSet = 1:2:100;
TestFrame1 = [2:2:100];
TestFrame2 = 100:1:200;
TestFrames = [TestFrame1 TestFrame2];

vid = VideoReader('detectbuoy.avi');

for i = 1:length(TestFrames)
    index = TestFrames(i);
    frame = read(vid,index);
    filename = strcat(num2str(index,'%03i'),'.jpg');
    imwrite(frame,filename);
end