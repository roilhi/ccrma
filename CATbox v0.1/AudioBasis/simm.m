function S = simm(X,Y)
% M = simm(X,Y)
% Normalized dot product distance

XNorm = sqrt(sum(X.^2));
YNorm = sqrt(sum(Y.^2));

Xkeep = find(XNorm>0);
Ykeep = find(YNorm>0);
X = X(:,Xkeep);
Y = Y(:,Ykeep);
XNorm = XNorm(Xkeep);
YNorm = YNorm(Ykeep);

S = (X'*Y)./(XNorm'*YNorm);