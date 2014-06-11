function [gamma2,eta2,sigma2] = sfm(x,Nfft);
%Spectra Flatness Measure (see Jain p.55-57; Akansu&Haddad p.34)
% [gamma2,eta2,sigma2] = sfm(x,Nfft);
% x = input samples
% Nfft = spectral modeling resolution
% (c) Shlomo Dubnov sdubnov@ucsd.edu

PLT = 0;
if nargin == 1,
   Nfft = [];
end

x = x-mean(x);
%Pxx = psd(x,Nfft);
Pxx = abs(fft(x,Nfft)); %Calculating Power spectrum via FFT
Pxx = Pxx(2:Nfft/2); %Taking one part of the spectrum and avoiding the dc component
N = length(Pxx);

if PLT,
    subplot(211)
    plot(x)
    subplot(212)
    plot(Pxx)
end

sigma2 = sum(Pxx)/N;
eta2 = exp(1/N*sum(log(Pxx)));

gamma2 = eta2/sigma2;

%0<gamma<1 and for white x we have Pxx = const and gamma2 = 1;
