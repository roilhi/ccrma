function [CQX, F, T] = cqgram(x, winlen, overlap, minFreq, maxFreq, bins, fs, thresh)
% [CQX, F, T] = cqgram(x, winlen, overlap, minFreq, maxFreq, bins, fs, thresh)
% Makes a running constant Q analysis of a sound
% winlen - size of signal frames submited to analysis in samples
% overlap - size of overlap between frames in samples
% minFreq, maxFreq, bins - constant Q analysis parameters: the range of frequencies
% [minFreq maxFreq] is divided into "bins" number of bins per octave
% fs - sampling frequency
% thresh - threshold for Kernel calculation. 
% slowQ, constQ, sparseKernel by Benjamin Blankertz (slight modifications by Shlomo Dubnov). 
% See also Benjamin Blankertz paper.
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin<2, winlen = 512; end
if nargin<3, overlap = 256; end
if nargin<4, minFreq = 27.5; end %midi note 21 - lowest A on keyboard
if nargin<5, maxFreq = 11025/2; end
if nargin<6, bins = 12; end
if nargin<7, fs = 11025; end
if nargin<8, thresh= 0.0054; end    % for Hamming window

xmat = buffer(x,winlen,overlap);
disp('Kernel calculation ...')
sparKernel= sparseKernel(minFreq, maxFreq, bins, fs, thresh);

N = size(xmat,2);
disp('Signal processing ...')
for i = 1:N
%    CQX(i,:) = slowQ(xmat(i,:), minFreq, maxFreq, bins, fs);
    CQX(i,:) = constQ(xmat(:,i)', sparKernel);
    progressbar(i/N);
end

Q= 1/(2^(1/bins)-1); 
k=1:ceil(bins*log2(maxFreq/minFreq));
F = minFreq*2.^((k-1)/bins);
hop = winlen - overlap;
T = [1:size(xmat,2)]*hop/fs;

if nargout == 0,
    imagesc(T,[],abs(CQX)'), axis xy
    YTL = str2num(get(gca,'YTickLabel'));
    set(gca,'YTickLabel',round(F(YTL)));
    xlabel('Time (sec.)')
    ylabel('Frequency (Hz)')
end
