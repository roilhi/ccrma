function [XCG,XLM] = chroma(x,fs,Nfft,win,hop);
%[XCG,XLM] = chroma(x,fs,Nfft,win,hop)
% create a chroma representation of the spectral magnitudes of x
% x - input sound
% fs - sampling frequency
% Nfft - fft of spectral analysis
% win  - window size
% hop - analysis hop (in samples)
% XCG - chromagram matrix
% XLM - log spectral magnitude
%
% the chorma bins are tuned according to equal temperament with A3 = 220 Hz
% Displays log magnitude spectrum and chormagram when called without output arguments
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin <2, fs = 11025; end
if nargin <3, Nfft = 2048; end
if nargin <4, win = 512; end
if nargin <5, hop = 128; end

%semitone
st = 2^(1/12);

% chroma scale centered on C4 = 220*st^3 Hz
C4 = 220*st^3;
C = log2(C4*st.^[0:11])-floor(log2(C4*st.^[0:11]));
plot(C,'o');
title('Chroma scale')


[X,F,T] = specgram(x,Nfft,fs,hamming(win),win-hop); %it is important to specify fs
F = F(2:end); %without DC
Fc = log2(F) - floor(log2(F));

%Now we associate each chroma frequency to the chroma scale
for i = 1:length(C),
    DFc(:,i) = abs(Fc - C(i));
end

[m,S] = min(DFc');

XCG = zeros(length(C),size(X,2));
XLM = log(abs(X(2:end,:))); %log magnitude, without DC
for i = 1:size(XCG,1)
    I = find(S == i);
    XCG(i,:) = mean(XLM(I,:));
end

if nargout == 0,
    figure
    imagesc([1:size(XCG,2)],[0:11],XCG); axis xy
    title('Chromagram')

    figure
    imagesc(XLM); axis xy
    title('Spectral Magnitudes')
end


