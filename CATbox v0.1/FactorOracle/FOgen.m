function [s,kend,ktrace] = FOgen(trn,sfx,n,p,k)
% [s, kend, ktrace] = FOgen(trn,sfx,n,p,k)
% Generate new sequence using a Factor Oracle
% input:
% trn - transition table
% sfx - suffix vector
% n - length of the string to be generated
% p - probability of change (replication vs. recombination)
% k - starting point
% output:
% s - new sequence
% kend - end point (index of the original sequence)
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 3,
    p = 0.5; %0.9
    k = ceil(rand*length(sfx)); %1;
elseif nargin == 4 | (nargin == 5 & isempty(k)),
    k = ceil(rand*length(sfx)); %1;
end

a = size(trn,2); %size of the alphabet
ktrace = 1;

%k = 1;
for i = 1:n,
    if sfx(k) ~= 0,
        if (rand < p) && (k < size(trn,1)), %1/16/05 Shlomo: changed from (k <= size(trn,1))
            if 1,%copy forward next only
                s(i) = find(trn(k,:)==k+1); %copy next symbol
                k = k+1;
                ktrace = [ktrace k];                
            else
                %copy forward any symbol
                I = find(trn(k,:));
                sym = I(ceil(rand*length(I)));
                s(i) = sym;
                k = trn(k,sym);
                ktrace = [ktrace k];                
            end
        else
            k = sfx(k); %go back and copy any of the next symbols
            ktrace = [ktrace k];
            I = find(trn(k,:));
            sym = I(ceil(rand*length(I)));
            s(i) = sym;
            k = trn(k,sym);
            ktrace = [ktrace k];
        end
    else
        s(i) = find(trn(k,:)==k+1); %copy forward next only (even if rand > p) 
        k = k+1;
        ktrace = [ktrace k];
    end
end

kend = k;