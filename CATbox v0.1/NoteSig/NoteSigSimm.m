function LL = NoteSigSimm(nCel,sMat,fs,w)
% LL = NoteSigSimm(nCel,sMat,fs,w)
% Creates similarity matrix between notes cell matrix and signal frame or sequence of
% signal frames arranged columnwise in a matrix.
% ncel = note cell matrix
% smat = signal frames matrix
% fs = sampling frequency
% w = factor of increasing onsets likelihood (point of high energy difference)
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 2,
    fs = 11025;
    w = 0;
elseif nargin == 3;
    w = 0;
end

nsize = length(nCel);
dur = cell2mat(nCel(:,3));
ndur = sum(dur);
nframe = size(sMat,2);
LL = zeros(ndur,nframe);

if w>0,
    dlogenrgy = [diff(log(std(sMat)+0.001)) 0];
else
    dlogenrgy = 0;
end

non = 1;
for i = 1:nsize,
    if ~isnan(nCel{i,1}), %not silence
        freqD = midi2hz(abs(nCel{i,1}));
    else
        freqD = 0;
    end
    freqVec = freqD / fs; %this is "reduced frequency" in the range [0 1]
    Like = NoteLikelihood(freqVec,sMat) + w*dlogenrgy;
    LL(non:non + dur(i)-1,:) = repmat(Like,dur(i),1);
    non = non+dur(i);
    progressbar(i/nsize);
end
