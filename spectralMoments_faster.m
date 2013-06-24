
function [centroid_out, bandwidth_out, skew_out, kurtosis_out] = spectralFeatures(x,fs,fftSize)
%[centroid, bandwidth, skew, kurtosis] = spectralMoments(x,fs, fftSize)
%
% Spectral Moments - returned for one FRAME of audio
% 
% Based on "Signal processing methods for music transcription" pg 136
% For equations see: http://www.imagine-research.com/temp/spectal_moments.pdf
% fftSize = 8192 (default); 
% 
% Original implementation - Jay LeBoeuf 2008
% Vectorized by Roy Fejgin (CCRMA), Summer 2010

% Set this to 1 to verify that both implementations below give the same results.
debug_spec_moments = 0;

% Window, FFT, and keep positive frequencies only.
w = hamming(length(x));
X = abs(fft(x.*w,fftSize));
X = X(1:end/2);

% Make sure the input is a one-dimensional vector - not tested with higher
% dimensions.
assert((ndims(x) == 2) && min(size(x)) == 1, 'spectralMoments.m: Error: Input signal must be a vector.');

% Normalize
Xhat_vec = X ./ sum(X);
% Make index vector
indices = (1:length(X))';

%% Centroid
centroid_vec = Xhat_vec.*indices;
centroid_out = sum(centroid_vec);

%% Build some vectors we'll need later.
% Reuse the results of lower powers to build the higher powers.
ind_cent_diff = indices - centroid_out;
id_diff = indices - centroid_out;
id_diff_pow2 = id_diff.*id_diff;
id_diff_pow3 = id_diff_pow2.*id_diff;
id_diff_pow4 = id_diff_pow3.*id_diff;


%% Bandwidth
bandwidth_out = sqrt(sum((id_diff_pow2).* Xhat_vec ));

%% Skew
skew_out = (sum((id_diff_pow3).* Xhat_vec))  / (bandwidth_out^3);

%% Kurtosis
kurtosis_out = sum((id_diff_pow4).* Xhat_vec) / (bandwidth_out^4);
toc

%% (Original implementation starts here)
if debug_spec_moments == 1
    tic
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
    toc


    err_margin = 10*eps;
    assert(abs(centroid - centroid_out) < err_margin);
    assert(abs(bandwidth - bandwidth_out) < err_margin);
    assert(abs(skew - skew_out) < err_margin);
    assert(abs(kurtosis - kurtosis_out) < err_margin);
end

