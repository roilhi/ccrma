function S = simm(X,Y)
% M = simm(X,Y)
% Normalized dot product distance

XNorm = sqrt(sum(X.^2));

if nargin == 1,
    YNorm = XNorm;
    Y = X;
else
    YNorm = sqrt(sum(Y.^2));
end

S = (X'*Y)./(XNorm'*YNorm);