function X = parsesig(x, fs, frame_size, hop)
% PARSESIG  Performs a short-time Fourier transform, essentially.
%
% x: input audio vector, mono
% fs: sampling frequency in Hertz
% frame_size: frame size in seconds
% hop: frame increment in seconds
%
% X: matrix, where each column is the fft of one frame
%
% Author: Steve Tjoa
% Last Modified: June 27, 2011

% Initialize parameters.
len_x = length(x);
frame_samp = round(frame_size*fs);
hop_samp = round(hop*fs);
num_frames = floor((len_x-frame_samp)/hop_samp) + 1;
X = zeros(frame_samp, num_frames);

% Compute the fft of each frame.
i = 1;
for n = 1:num_frames
    xfr = x(i:i+frame_samp-1);
    X(:,n) = fft(xfr);
    i = i + hop_samp;
end

