function [A, S] = nmf(X, K, type)
% NMF  Nonnegative Matrix Factorization.
%
% [A, S] = NMF(X, K, TYPE) performs nonnegative matrix factorization on the
% nonnegative M-by-N matrix X using K components. The M-by-K matrix A and
% the K-by-N matrix S are computed such that a divergence between X and A*S
% is minimized while preserving element-wise nonnegativity of both
% matrices.
%
% [A, S] = NMF(X, K, 'euc') uses the Euclidean distance.
% [A, S] = NMF(X, K, 'kl') uses the Kullback-Leibler divergence.
% [A, S] = NMF(X, K, 'is') uses the Itakura-Saito divergence.
%
% Author: Steve Tjoa 
% Institution: University of Maryland (Signals and Information Group) 
% Created: July 1, 2009 
% Last modified: June 27, 2011
%
% This code was written during the workshop on Music Information Retrieval
% at the Center for Computer Research in Music and Acoustics (CCRMA) at
% Stanford University.

% Initialize parameters.
maxiter = 100;
[M, N] = size(X);
O = ones(M, N);
c = 1;  % safety parameter

% Initialize outputs.
A = rand(M, K);
S = rand(K, N);

if strcmp(type, 'euc')
    for iter=1:maxiter
        % Euclidean distance
        A = A.*(X*S' + c)./(A*(S*S') + c);
        S = S.*(A'*X + c)./((A'*A)*S + c);
        [A, S] = rescaledict(A, S);
    end
    
elseif strcmp(type, 'kl')
    for iter=1:maxiter
        % KL Divergence
        A = A.*((X./(A*S))*S' + c)./(O*S' + c);
        S = S.*(A'*(X./(A*S)) + c)./(A'*O + c);
        [A, S] = rescaledict(A, S);
    end
    
elseif strcmp(type, 'is')
    for iter=1:maxiter
        % IS Divergence
        A = A.*((X./(A*S).^2)*S' + c)./((1./(A*S))*S' + c);
        S = S.*(A'*(X./(A*S).^2) + c)./(A'*(1./(A*S)) + c);
        [A, S] = rescaledict(A, S);
    end
end
