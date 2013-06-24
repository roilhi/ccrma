
function [data,multfactor, subfactor] = scale(x)   
% [data,multfactor, subfactor] = scale(x)  
% linearly scale data
if size(x,1) ~= 1                   % Make sure that data is matrix and not a vector
    range = max(x)- min(x);         % First, find out the ranges of the data
    multfactor = 2 ./ range  ;      % Scaling to be {-1 to +1}.  This is a range of "2" 
    newMaxval = multfactor .* max(x);
    subfactor = newMaxval - 1   ;   % Center around 0, which means subtract 1
    for i = 1 : size(x,2)
        data(:,i) = x(:,i) .* multfactor(i) - subfactor(i);
    end
else                                 % If data is a vector, just return vector and multiplaction = 1, subtraction = 0;
    data = x; 
    multfactor = 1;
    subfactor  = 0; 
end

