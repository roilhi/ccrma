
function [featureVector_scaled] = rescale(featureVector,mf,sf)   
% [featureVector_scaled] = rescale(featureVector,mf, sf)
% 
% featureVector = the unscaled feature vector
% mf = the multiplication factor used for linear scaling 
% sf = the subtraction factor used for linear scaling
%
%
    for i = 1:size(featureVector,2)  % linear scale
            featureVector_scaled(:,i) = featureVector(:,i) * mf(i) - sf(i);
    end

