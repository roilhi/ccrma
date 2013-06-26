function [p,q,D] = dtw(S,ins,del)
% [p,q,D] = dtw(S,in,del) 
% S = similarity matrix between two seqeunces
% ins,del = delition and insertion penalties
%
% similarity is the cost of moving on diagonal (advancing together)
% delition and insertions operations are defined for sequence 2, i.e.
% delition is the cost of advancing on the columns index (seq. 2 speeding) 
% and insertion is the const of advancing on rows index (seq. 2 waiting)
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 1,
    ins = 0;
    del = 0;
elseif nargin == 2,
    del = ins;
end

[r,c] = size(S);

% Initialize
D = zeros(r+1, c+1);
trace = zeros(r,c);

for i = 1:r; 
  for j = 1:c;
    [D(i+1,j+1), trace(i,j)] = max([D(i, j) + S(i,j), D(i+1, j) - del*S(i,j), ...
        D(i, j+1) - ins*S(i,j)]);
  end
end

% Traceback
i = r; 
j = c;
p = i;
q = j;
while i > 1 & j > 1
  indx = trace(i,j);
  if (indx == 1)
    i = i-1;
    j = j-1;
  elseif (indx == 2)
    j = j-1;
  elseif (indx == 3)
    i = i-1;
  else    
    error;
  end
  p = [i,p];
  q = [j,q];
end

