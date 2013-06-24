function [centroid] = temporalCentroid(signal)
    numerator = 0;
    denominator = 0;
    for i = 1:length(signal)
        numerator = numerator + i*signal(i)*signal(i);
        denominator = denominator + signal(i) * signal(i);
    end
    
    centroid = numerator / denominator;
end