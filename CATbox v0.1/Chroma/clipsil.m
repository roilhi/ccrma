function x1 = clipsil(x,win,overlap,snr)
% silclip(x,win,overlap)
%remove silence from both ends
% win - window size in samples
% overlap - overlap in samples
% snr - clipping criteria signal to noise ratio

if nargin < 2,
    win = 1024; end
if nargin < 3,
    overlap = 512; end
if nargin < 4,
    snr = 60; end

xmat = buffer(x,win,overlap);
xrms = std(xmat);
abovesnr = find(xrms > 10^(-snr/20));
from = (min(abovesnr)-1)*512 + 1;
to = min(max(abovesnr)*512,length(x));
x1 = x(from:to);
