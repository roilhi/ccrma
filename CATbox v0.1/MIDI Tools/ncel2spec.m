function [sp,F,T] = ncel2spec(nc,nfft,fs,hop)
% sp = ncel2spec(nc)
% sp = spectral matrix
% nc = note cell matrix
% 
% Approximate specgram from note cell matrix. It does not take into account
% sidelobes. 
% Next version should account for more analysis parameters, such as
% possibly window type, number of partials and some spectral
% characteristic, may be spectral rolloff.
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 1,
    nfft = 512,
    fs = 11025;
    hop = nfft/2;
elseif nargin == 2,
    fs = 11025;
    hop = nfft/2;
elseif nargin == 3,
    hop = nfft/2;
end

if mod(nfft,2),
    error('ncel2spec: works with even nfft only')
end

dur = cell2mat(nc(:,3));
totdur = sum(dur);
%time = [1; cumsum(dur)];
time = [1; cumsum(dur)+1];
sp = zeros(nfft/2,totdur);
for i = 1:length(nc)
    for j = 1:length(nc{i}),
        note = nc{i,1}(j);
        freq = midi2hz(abs(note));
        bin = round(freq/fs*nfft);
        vel = nc{i,2}(j);
        non = note > 0;
        if non,
            sp(bin,time(i):time(i+1)-1) = vel; %note on during object duration
        else
            sp(bin,time(i):time(i+1)-1) = sp(bin,time(i)-1); %continue with previos velocity of same note
        end
    end
end

F = [1:nfft/2]*fs/nfft;
T = [1:totdur]*hop/fs;
if nargout == 0,
    imagesc(T,F,sp); axis xy
end
    