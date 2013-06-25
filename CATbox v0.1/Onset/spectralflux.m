function [sf,T] = spectralflux(x,fs,Nfft,overlap)
% sf = spectralflux(x,fs,Nfft,overlap)
% spectral flux of a sound
% x - input sound
% Nfft - size of fft analysis
% overlap - overlap of fft frames
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin < 2, fs = 2; end
if nargin < 3, Nfft = 512; end
if nargin < 4, overlap = Nfft/2; end

hop = Nfft - overlap;

X = stft(x,Nfft,overlap);
dX = diff(abs(X)');
HdX = H(dX);
sf = sum(HdX');
T = [1:size(X,2)-1]*hop/fs;


function y = H(x)
%half wave ractifier

y = (abs(x) + x)/2;