function x = ola(xmat,hop,win);
% x = ola(xmat,hop,win);
%overlap add with extra smoothing
% xmat - input matrix containing signal frames
% hop - analysis hop size in samples
% win - posterior windowing function (window samples). Default hanning.
% This window is used for extra smoothing.
% (c) Shlomo Dubnov sdubnov@ucsd.edu

[framelen,nframes] = size(xmat);

if nargin < 3,
    win = hanning(framelen,'periodic');
end

wsum = zeros((nframes-1)*hop + framelen,1);

x = zeros((nframes-1)*hop + framelen,1);
win_pos = [1:hop:length(x)];

for i = 1:size(xmat,2),
    x(win_pos(i):win_pos(i)+framelen-1) = x(win_pos(i):win_pos(i)+framelen-1) + xmat(:,i).*win;
    wsum(win_pos(i):win_pos(i)+framelen-1) = wsum(win_pos(i):win_pos(i)+framelen-1) + win; 
end    
    
x(hop:end-hop) = x(hop:end-hop)./wsum(hop:end-hop);
