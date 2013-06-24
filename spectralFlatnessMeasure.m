function [ sfm ] = spectralFlatnessMeasure(x,fs,fftSize)
%  [ sfm ] = spectralFlatnessMeasure(x,fs,fftSize)
% Original implementation Kyogu Lee (2009)
% Updated by Jay LeBoeuf (2010)
% SpectralFeatures
% [ sfm ] = spectralFlatnessMeasure(x,fs,fftSize)
%  sfm = spectral flatness measure
% 

% analysis window size
M = fftSize; 

% first compute spectrogram
[spec,fi,ti] = specgram(x,M,fs,hann(M),M/2);
nframe = length(ti);

% compute spectral flatness (SF)
% SF is a subband-based feature (SF_b where b is a band)
% first compute filterbank frequencies using bark band (critical band)
bf = [0, 100, 200, 300, 400, 510, 630, 770, 920, 1080, 1270, 1480, 1720, 2000, 2320, 2700, 3150, ...
      3700, 4400, 5300, 6400, 7700, 9500, 12000, 15500, 20000]; % bark band frequencies
nband = length(bf)-1; % # of subbands

for b=1:nband
    bf_idx(b) = find(abs(bf(b+1)-fi)==min(abs(bf(b+1)-fi)));
end

for b=1:nband-1
    n_b(b) = bf_idx(b+1)-bf_idx(b)+1;
end
n_b = [bf_idx(1),n_b];

for b=1:nband
    if b==1, ff{b} = 1:bf_idx(b);
    else ff{b} = bf_idx(b-1)+1:bf_idx(b);
    end
end

% now calculate SF for each band
for i=1:nframe
    X = spec(:,i); % for each frame
    for b=1:nband
        sf(b,i) = (prod(abs(X(ff{b})).^2))^(1/n_b(b))/(sum(abs(X(ff{b})+0.00001).^2)/n_b(b)); % (geometric mean)/(arithmetic mean)
    end
end

% JayL 6-21-09 - handle case where sf = inf
sf(find(isinf(sf)==1)) = 0;
% JayL 6-21-09 - handle case where sf = NaN
sf(find(isnan(sf)==1)) = 0;

sfm = mean(sf,1); % mean SF