
function [chroma,tuning_center] = gen_chroma(infile,kernel,fsd,M,hs);

% FUNCTION [CHROMA,TUNING_CENTER] = GEN_CHROMA(INFILE,KERNEL,FSD,M,HS);
% generate 12-d chromagram using fft-to-chroma kernel matrix
% Kyogu Lee (8/16/07)

[x,fs] = wavread(infile);
if size(x,1)>size(x,2)
  xm = mean(x,2); % mono
else
  xm = mean(x,1);
end

if fs == fsd
  xd = xm;
else
  ds_factor = floor(fs/fsd); % downsample factor
  fcn = 1/ds_factor; % normalized cutoff frequency
  b = fir1(16,fcn); % lowpass coefficients
  xlpf = filter(b,1,xm); % lowpass filtering
  xd = downsample(xlpf,ds_factor);
end

% compute spectrogram
sp = specgram(xd,M,fs,hamming(M),M-hs);
nfft = min(size(kernel,2),size(sp,1));
ch36 = kernel(:,1:nfft)*abs(sp(1:nfft,:)); % 36-d chromagram
tuning_center = find_tuning_center(ch36);
ch12 = tune_hpcp(ch36,tuning_center);
ch12 = circshift(ch12,-5); % transpose so that dim1 = C
chn = normalise(ch12,1); % each chroma vector sum to 1

chroma = chn;
