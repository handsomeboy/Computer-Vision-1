function [muR covR muG covG muY covY] = estimate3D()
    [RedBuoyData YellowBuoyData GreenBuoyData] = colorSamples();
    %% RED BUOY
    muR = mean(RedBuoyData);
    covR = cov(double(RedBuoyData));

    %% GREEN BUOY
    muG = mean(GreenBuoyData);
    covG = cov(double(GreenBuoyData));

    %% YELLOW BUOY
    muY = mean(YellowBuoyData);
    covY = cov(double(YellowBuoyData));
    
end