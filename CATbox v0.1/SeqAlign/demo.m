close all
clear 

nm2 = createnmat2([67 64 64 65 62 62 60 62 64 65 67 67 67],[3 1 4 3 1 4 3 1 3 1 2 2 4]/4,100,1,0.8);
fs = 11025;
sig = nmat2snd(nm2,'fm',fs);
snr=60;
s = sig + randn(size(sig)) * std(sig) / (10^(snr/20));

nmat = createnmat2([67 64 64 65 62 62 60 62 64 65 67 67 67],8/13); %DTW

method = 'DTW';

%GSA global sequence alignment
%LSA local sequence alignment
%LCS longest common subsequence
%ASM approximate sequence matching
%OLM overlap match
%DTW dynamic time warping
%TWCLS time warped longest common subsequence 

% Set up representation / analysis parameters
% estimate tempo

%if matching to signal s, 
%beat_dur = length(s)/fs;

%if matching a subsequence, use its duration
beat_dur = nmat(end,6)-nmat(1,6)+nmat(end,7);
beat = nmat(end,1)-nmat(1,1)+nmat(end,2);
bpm_est = 60/beat_dur*beat;

% set up signal frame parameters
frame_len=512;
hop = frame_len/2;
overlap = frame_len-hop; %1024-64; %frame_len*7/8 %frame_len/2; %*3/4;

% find corresponding quantization value
sa = hop/fs;
qnt = sa/60*bpm_est/4;

% create note cell matrix and signal frames matrix
ncel = nmat2ncel(nmat,qnt);
%ncel(end+1,:) = {[],[],[2]}; %add silence 
smat = buffer(s,frame_len,overlap);

% display purporse only
%specgram(s,512,fs)
%soundsc(s,11025)
%pause

disp('Similarity processing ...')
% Harmonic Likelihood Proj
SM = NoteSigSimm(ncel,smat,fs);
 
% taking care that S in the range [0 1]
SM = SM - min(min(SM));
SM = SM/max(max(SM));

disp('Alignment Processing ....')
%
% Dynamic time warping
%
[p,q,D] = align(SM,method);


figure
imagesc(SM)
hold on; plot(q,p,'w-x'); hold off

disp('Midi output ....')
% Find the frames in smat that are indicated to match each event ncel
qm = zeros(size(p));
empty = [];
indp = p(1):p(1)+length(p)-1;
for i = 1:length(p),
    if ~isempty(q(min(find(p >= indp(i))))),
        qm(i) = q(min(find(p >= indp(i))));
    else
        empty = [empty i];
    end 
end
qm(empty) = [];

% original duration of ncel events
ndur = cell2mat(ncel(:,3));
dqm = diff(qm);

ind = 1;
for i = 1:length(ndur),
    from = ind;
    to = min(ind+ndur(i)-1,length(dqm));
    dd(i) = sum(dqm(from:to));
    ind = ind+ndur(i);
end

tempo = gettempo(nmat);
qa = qnt*60/tempo*4;

ncout = ncel;

for i = 1:length(ncout),
    ncout{i,3} = round(dd(i)*sa/qa*8);
end

nmout = ncel2nmat(ncout,qnt/8);
playmidi(nmout,tempo)
