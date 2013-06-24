
function [centroid, bandwidth, skew, kurtosis] = spectralFeatures(x,fs,fftSize)
%[centroid, bandwidth, skew, kurtosis] = spectralMoments(x,fs, fftSize)
%
% Spectral Moments - returned for one FRAME of audio
% 
% Based on "Signal processing methods for music transcription" pg 136
% For equations see: http://www.imagine-research.com/temp/spectal_moments.pdf
% fftSize = 8192 (default); 
% 
% Original implementation - Jay LeBoeuf 2008
w = hamming(length(x));
X = abs(fft(x.*w,fftSize));
X = X(1:end/2);

centroid = 0;
for k = 1:length(X)
    Xhat = abs(X(k)) / sum(abs(X)); 
    centroid  = centroid + k*Xhat;
end

bandwidth = 0;
for k = 1:length(X)
    Xhat = abs(X(k)) / sum(abs(X)); 
    bandwidth  = bandwidth + ((k-centroid)^2)*Xhat;
end
bandwidth = sqrt(bandwidth);

skew = 0;
for k = 1:length(X)
    Xhat = abs(X(k)) / sum(abs(X)); 
    skew = skew + ((k-centroid)^3)*Xhat;
end
skew = skew / bandwidth^3;

kurtosis = 0;
for k = 1:length(X)
    Xhat = abs(X(k)) / sum(abs(X)); 
    kurtosis = kurtosis + ((k-centroid)^4)*Xhat;
end
kurtosis = kurtosis / bandwidth^4;


