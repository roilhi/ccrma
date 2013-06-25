function [trn,sfx] = FO(s,a)
% [trn,sfx] = FO(s,a)
% Factor Oracle for sequence s
% input:
% s - string of symbols (numbers in the range [1,a])
% a - size of the alphabet (default: length of s)
% output:
% trm - transition matrix (forward)
% sfx - suffix vector (backwards)
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 1,
    a = max(s);
end

trn = zeros(length(s)+1,a);
sfx = zeros(1,length(s));

for i = 2:length(s)+1,
    symbol = s(i-1);
    if ischar(symbol), %Shlomo 1/16/05
        symbol = str2num(symbol);
    end
    trn(i-1,symbol) = i;
    k = sfx(i-1);
    while k ~= 0 & trn(k,symbol) == 0,
        trn(k,symbol) = i;
        k = sfx(k);
    end
    if k == 0, 
        sfx(i) = 1;
    else
        sfx(i) = trn(k,symbol);
    end
end
