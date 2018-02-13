function [uR, sR, DataR, uY, sY, DataY, uG, sG, DataG] = estimate()

    %%
    [RedBuoyData,YellowBuoyData,GreenBuoyData] = colorSamples();
    DataR = RedBuoyData;
    DataY = (YellowBuoyData(:,1) + YellowBuoyData(:,2))/2;
    DataG = GreenBuoyData;
    
%     %Random distribution represented as gaussian with mean, stnd dev
    uR = mean(DataR(:,1));%mean of Data
    sR = std(double(DataR(:,1)));%variance of Data
    
    uY = mean(DataY);%mean of Data
    sY = std(double(DataY));%variance of Data
    
    uG = mean(DataG(:,2));%mean of Data
    sG = std(double(DataG(:,2)));%variance of Data
   
end


