function [A, S] = rescaledict(A, S)
% RESCALEDICT  Rescale dictionary.
%
% Author: Steve Tjoa 
% Institution: University of Maryland (Signals and Information Group) 
% Created: July 1, 2009 
% Last modified: July 2, 2009
%
% This code was written during the workshop on Music Information Retrieval
% at the Center for Computer Research in Music and Acoustics (CCRMA) at
% Stanford University.

K = size(A,2);

for k=1:K
    g = norm(A(:,k));
    A(:,k) = A(:,k)./g;
    S(k,:) = S(k,:).*g;
end
