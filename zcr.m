function [z] = zcr(x)
% Calculate Zero Crossing Rate
% [z] = zcr(x)
% July 16, 2008
% Copyright 2008 Jay LeBoeuf / Imagine Research
% Used for teaching purposed at CCRMA Summer 2008

z = 0;
x = x + 0.00000001; % add a small offset to signal to prevent signal = 0;
for i = 2:length(x)
    if sign(x(i)) ~= sign(x(i-1))
        z=z+1;
    end
end
