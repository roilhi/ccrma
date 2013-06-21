function y = synsig(Y, fs, len_y, hop)
% SYNSIG  Synthesizes a signal in the time domain using overlap and add.
%
% Y: STFT of signal, y.
% len_y: desired length in samples of the output signal, y.
% hop: frame increment in seconds

% Initialize parameters.
hop_samp = round(hop*fs);
[frame_samp, num_frames] = size(Y);
y = zeros(len_y,1);
w = rascos(frame_samp)*2*hop_samp/frame_samp;

% Overlap and add.
i = 1;
for n=1:num_frames
    z = w.*real(ifft(Y(:,n)));
    y(i:i+frame_samp-1) = y(i:i+frame_samp-1) + z;
    i = i + hop_samp;
end
    