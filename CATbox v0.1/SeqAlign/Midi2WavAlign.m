% Midi2WavAlign:
% Aligns a midi file to a corresponding recording.
% (c) Shlomo Dubnov sdubnov@ucsd.edu

close all
clear

%mp3name = '../Sounds/Bach Prelude in G Magor WTC Book I (gould).mp3';
mp3name = '../Sounds/Bach__Prelude_in_G_major_Well_Tempered_Clavier_Book_I.mp3';
[sig,fs] = mp3read(mp3name,[],1,4); %whole file, 'mono', downsample by 4
%[sig,fs] = wavread('/Users/sdubnov/Music/Sounds/Music/wtc1151.wav'); %,[100000 200000]);

midiname = '../Sounds/wtc1151.mid';

nmat = readmidi(midiname);
snr=30;
s = sig + randn(size(sig)) * std(sig) / (10^(snr/20));

% Set up representation / analysis parameters
% estimate tempo
sig_len = length(s)/fs;
beat = nmat(end,1)-nmat(1,1)+nmat(end,2);
bpm_est = 60/sig_len*beat;

% set up signal frame parameters
frame_len=1024;
hop = 256;
overlap = frame_len-hop;

% find corresponding quantization value
sa = hop/fs;
qnt = sa/60*bpm_est/4;

% create note cell matrix and signal frames matrix
ncel = nmat2ncel(nmat,qnt);
%ncel(end+1,:) = {[],[],[2]}; %add silence 
smat = buffer(s,frame_len,overlap);

disp('Similarity Processing ....')
% Harmonic Likelihood Proj
SM = NoteSigSimm(ncel,smat,fs);

disp('Rescaling ...')
% taking care that S in the range [0 1]
SM = SM - min(min(SM));
SM = SM/max(max(SM));

disp('Alignment Processing ....')
% Dynamic time warping
[p,q,D] = align(SM,'DTW');
figure
imagesc(SM)
hold on; plot(q,p,'w'); hold off

disp('Midi Processing ....')
% Find the frames in smat that are indicated to match each event ncel
qm = zeros(size(p));
empty = [];
for i = 1:length(p),
    if ~isempty(q(min(find(p >= i)))),
        qm(i) = q(min(find(p >= i)));
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
qa = qnt*4*60/tempo;
sa = hop/fs;

ncout = ncel;

for i = 1:length(ncout),
    ncout{i,3} = round(dd(i)*sa/qa*8);
end

nmout = ncel2nmat(ncout,qnt/8);
tempo = gettempo(nmat);
playmidi(nmout,tempo)

