
function cq_mtx = fft2cq_mtx(fs,nfft,hs,fmin,fmax,B);
  
% FUNCTION CQ_MTX = FFT2CQ_MTX(FS,NFFT,HS,FMIN,FMAX,B);
% matrix for converting fft (or spectrogram) to constant-Q transform
% from DE's logfsgram()
% Kyogu Lee (8/15/07)
  
  
  
% Construct mapping matrix

% Ratio between adjacent frequencies in log-f axis
fratio = 2^(1/B);

% How many bins in log-f axis
nbins = floor( log(fmax/fmin) / log(fratio) );

% Freqs corresponding to each bin in FFT
fftfrqs = [0:(nfft/2)]*(fs/nfft);
nfftbins = nfft/2+1;

% Freqs corresponding to each bin in log F output
logffrqs = fmin * exp(log(2)*[0:(nbins-1)]/B);

% Bandwidths of each bin in log F
logfbws = logffrqs * (fratio - 1);

% .. but bandwidth cannot be less than FFT binwidth
logfbws = max(logfbws, fs/nfft);

% Controls how much overlap there is between adjacent bands
ovfctr = 0.5475;   % Adjusted by hand to make sum(mx'*mx) close to 1.0

% Weighting matrix mapping energy in FFT bins to logF bins
% is a set of Gaussian profiles depending on the difference in 
% frequencies, scaled by the bandwidth of that bin
freqdiff = ( repmat(logffrqs',1,nfftbins) - repmat(fftfrqs,nbins,1) )./repmat(ovfctr*logfbws',1,nfftbins);
cq_mtx = exp( -0.5*freqdiff.^2 );
% Normalize rows by sqrt(E), so multiplying by mx' gets approx orig spec back
cq_mtx = cq_mtx ./ repmat(sqrt(2*sum(cq_mtx.^2,2)), 1, nfftbins);
cq_mtx = cq_mtx';
