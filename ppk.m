function [kpp,cost] = ppk(m1, m2, rho)
% K = PPK(m1, m2)
%   Jebara's Product Probability Kernel for GMMs.
%
% m1 and m2 are netlab-style GMMs.

if nargin < 3
 rho = .5;
end

N1 = m1.ncentres;
N2 = m2.ncentres;
if (N1 ~= N2)
 %disp('Warning: number of mixtures not equal');
end

covfloor = .00001;

% precompute some stuff to speed up the ppk computations
for i = 1:N1
 mu1 = m1.centres(i,:);
 sig1 = m1.covars(i,:);
 % scaffold:
 sig1(find(sig1 < covfloor)) = covfloor;
 siginv1(i,:) = 1./sig1;
 det1(i) = prod(sig1)^(-rho/2);
 musigmu1(i) = sum((mu1.^2).*siginv1(i,:));
 musig1(i,:) = mu1.*siginv1(i,:);
end

for i = 1:N2
 mu2 = m2.centres(i,:);
 sig2 = m2.covars(i,:);
 sig2(find(sig2 < covfloor)) = covfloor;
 siginv2(i,:) = 1./sig2;
 det2(i) = prod(sig2)^(-rho/2);
 musigmu2(i) = sum((mu2.^2).*siginv2(i,:));
 musig2(i,:) = mu2.*siginv2(i,:);
end

cost = zeros(N1,N2);
D = m1.nin;
C = (2*pi)^((1-2*rho)*D/2) * rho^(-D/2);

for i = 1:N1
 for j = 1:N2

   % i used to have this as a function call but it was 60% slower!
   mucross = musig1(i,:) + musig2(j,:);
   sigcross = 1./(siginv1(i,:) + siginv2(j,:));
   cost(i,j) = ...
     C * det1(i) * det2(j) * prod(sigcross)^(1/2) * ...
     exp(-rho/2 * (musigmu1(i) + musigmu2(j) - sum(mucross.^2 .* sigcross)));
 end
end

if rho == 1
 kpp = m1.priors * cost * m2.priors';
else
 kpp = (m1.priors.^rho) * cost * (m2.priors.^rho)';
end