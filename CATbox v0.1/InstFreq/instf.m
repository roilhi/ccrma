function [a,f,t,p] = instf(x,fs,Nfft,hopfac)
% [a,f,t,p] = instf(x,fs,Nfft,hopfac)
% Instanteneous Frequency using hanning window and hop 1 method
% input:
% x - input sound
% fs - sampling frequency
% Nfft - fft size, equal to window size (default 512)
% hopfac - hop factor (2 means 50% overlap, 4 means 75% overlap, default 4)
% output:
% a - amplitude
% f - instanteneous frequency
% t - time
% p - phasor (fft with unit magnitude)
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin < 2,
    fs = 1;
end
if nargin < 3,
    % fft length
    Nfft = 256;
end
if nargin < 4,
    hopfac = 2;
end
x = x(:);

overlap = Nfft*(1-1/hopfac);
win = ones(Nfft,1);
% Rectangular window STFT analysis. 
% X is of size (k*t) where k is the number of FFT bins and t is number of frames
X = stft(x,win,overlap);


%% Take only positive frequencies
%X = X(1:Nfft/2+1,:);

% FFT bins
k = [0:Nfft/2]';
%k = k-(Nfft/2);
f = zeros(size(X));

for i=1:size(X,2),
   
    % one instance of the spectrum
    Xk = X(:,i);
    Xkplus1 = [Xk(2:end);eps];
    Xkminus1 = [eps;Xk(1:end-1)];
    
    % frequency estimation (hop one trick)
    f(:,i) = fs*(k./Nfft - imag((j/Nfft).*((Xkplus1-Xkminus1)./(2*Xk-Xkplus1-Xkminus1+2*eps))));
    % current time
    t(i) = i*((Nfft/hopfac)/fs);
    
end

win = hanning(Nfft,'periodic');
X1 = stft(x,win,hopfac);
a = abs(X1);
p = X1./a;

if nargout == 0,
    plot(t,f','.k');
end

