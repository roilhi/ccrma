function [gamma2,gamma2G,ro,roG,Jx,Jy,sigma2,eta2,AR] = gsfm(y,p);
% [gamma2,gamma2G,ro,roG,Jx,Jy,sigma2,eta2,AR] = gsfm(y,p);
% Generalized Spectral Flatness Measure (1 is random, 0 is deterministic).
% x = input samples
% gamma2 = Generalized SFM (GSFM)
% gamma2G = Gaussain SFM
% ro = Marginal Informatino Redundancy (MIR)
% roG = Gaussain MIR
% Jx = Negetropy of the residual
% Jy = Negetropy of the signal
% sigma2 = integral of the psd = proportional to exp(marginal entropy)
% eta2 = integral of ln(psd) = proportional to exp(entropy rate)
%
% (c) Shlomo Dubnov sdubnov@ucsd.edu

DBG = 0;

if nargin == 1,
   error('Missing input argument: order of Burg estimator')
end

% General Note:
% The procedure can be tested for Gaussian signals by comparing the results to 
% theory. For AR(1) with AR = [1 -b1] the theoretical result if gamma^2 = 1 - b1^2;
% For instance, taking b1 = 2/3 gives gamma^2 = 0.55
% For AR(2), a = [1 -b1 -b2], gamma^2 = (1+b1)(1-b1-b2)(1+b1-b2)/(1-b2)
% Taking b1 = 1, b2 = -0.5 give gamma^2 = 0.417 
% See Jayant, pp.64-67

%%%%%%%% Gaussian SFM using Burg method %%%%%%%%%%%

%AR = lpc(y,p); %Why is it different?

y = (y-mean(y))/std(y);

[AR,E] = arburg(y,p);
num = sqrt(E); %./sqrt(pi); %/sqrt(2*pi)
%num = 1;
x = filter(AR,num,y);
x = x(10*p:end); %Important: Need to get rid of the inverse filtering transient!
y = y(10*p:end);

%p
%subplot(211); plot(x)
%subplot(212); plot(y)
%pause

if DBG,
    subplot(211); plot(y)
    title('Signal')
    subplot(212); plot(x)
    title('Excitation residual')
    pause
end

Pyy = freqz(num,AR,512);
nfft = length(Pyy);
sel = 2:nfft-1;
Pyy = [Pyy(1); 2*Pyy(sel); Pyy(nfft)];
Pyy = abs(Pyy).^2;   

if 0, %ploting and testing other psd estimators
clf
plot(Pyy)
pause
hold on

Pyy = psd(y,1024);
plot(Pyy,'r');
pause
Pyy1 = Pyy;

Pyy = pwelch(y,1024)*pi;
plot(Pyy,'c');
pause
Pyy = 2*pburg(y,6,1024); %it seems that pburg divides by Fs which is 2.
plot(Pyy,'g');
hold off

Pyy = Pyy1;
end %if


%SFM
N = length(Pyy);
sigma2 = sum(Pyy)/N;
eta2 = exp(1/N*sum(log(Pyy)));
%%%% Notice!
%eta2 = sqrt(eta2); %this is a correction factor for entropy rate. 
%We did not use it, in order to keep 0<gamma2<1
gamma2G = eta2/sigma2;

%Gaussain IR
roG = -0.5*log(gamma2G);

Jx = NegEnt(x);
Jy = NegEnt(y);

ro = Jx - Jy + roG;

gamma2 = exp(-2*ro); %27.11 : there was a bug in previous results where we used gamma2 = exp(-ro)

%0<gamma<1 and for white x we have Pxx = const and gamma2 = 1;

function J = NegEnt(x)

%This approximation assumes zero mean and unit variance x
x = x-mean(x);
x = x/std(x);

K = kurt(x);
J = 1/12*mean(x.^3)^2 + 1/48*K^2; %Standard Edgeworth

k1 = 36/(8*sqrt(3)-9);
k2a = 1/(2-6/pi);
k2b = 24/(16*sqrt(3)-27);

%J = k1*(mean(x.*exp(-x.^2/2)))^2 + k2a*(mean(abs(x))-sqrt(2/pi))^2;
%J = k1*(mean(x.*exp(-x.^2/2)))^2 + k2b*(mean(-x.^2/2)-sqrt(1/2))^2;

function K = kurt(x)

K = mean(x.^4) - 3*mean(x.^2)^2; %x is zero mean


%