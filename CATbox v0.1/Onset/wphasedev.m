function [wpd, nwpd dif, a, T, F] = wphasedev(x,fs,Nfft,hopfac)
% [wpd, nwpd, dif, T, F] = wphasedev(x,fs,Nfft,hopfac)
% weighted phase difference of signal x.
% Input: 
% x - input sound file
% fs - sampling frequency
% Nfft - size of fft analysis 
% hopfac - fft hop factor
% Output:
% wpd - weighted phase deviation
% nwpd - normalized weighted phase deviation
% dif - second derivative of the phase (difference in instananeous
% frequency)
% T,F - time and frequency axes. Good for ploting.
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin < 2,
    fs = 2;
end
if nargin < 3,
    Nfft = 512; end
if nargin < 4,
    hopfac = 4; end

%tic
[a,ifr,T] = instf(x,fs,Nfft,hopfac);
%toc
F = [0:Nfft/2-1]/Nfft*fs;

dif = diff(ifr')'/fs*2*pi;
T = T(1:end-1);
a = a(:,1:end-1);

wpd = mean(a.*abs(dif));
nwpd = wpd./mean(a);

if nargout == 0,

    imagesc(T,F,log(a.*abs(dif)))
    axis xy
    xlabel('time')
    ylabel('frequency')
end
