function [y, W, H] = sourcesep(x, fs, K)
% SOURCESEP  Separate sources using NMF.
%
% [Y, W, H] = SOURCESEP(X, FS, K) separates a single-channel audio signal X
% at sampling rate FS into K signals. Y is a matrix with K columns, each
% column corresponding to one separated time-domain signal. This function
% performs nonnegative matrix factorization on the magnitude spectrogram of
% X using the Euclidean distance measure with K components. Each separated
% component preserves the phase of the original spectrogram.
%
% W and H are outputs from NMF which tries to minimize the distance between
% X and W*H such that W and H are element-wise nonnegative.
%
% Author: Steve Tjoa
% Institution: Imagine Research, Inc. 
% Created: July 1, 2009 
% Last modified: June 27, 2011
%
% This code was written during the workshop on Music Information Retrieval
% at the Center for Computer Research in Music and Acoustics (CCRMA) at
% Stanford University.

% Initialize parameters.
frame_size = 4096.0/44100;
hop = 0.020;
len_x = length(x);

% Initialize output.
y = zeros(len_x, K);

% Compute STFT.
X = parsesig(x, fs, frame_size, hop);

% Compute magnitude spectrum.
Xmag = abs(X);

% Perform NMF.
[W, H] = nmf(Xmag, K, 'euc');

% Synthesize each separated signal.
for k=1:K
    Y = (W(:,k)*H(k,:)).*exp(j.*angle(X));
    y(:,k) = synsig(Y, fs, len_x, hop);
end

