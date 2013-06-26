
% CCRMA MIR Workshop 2009
% Lab3.3: Chord recognition using template matching
% Kyogu Lee (June 2009)

clear all;
%close all;

warning('off');

% input audio filename
%infile = '../wav/prelude_cmaj.wav';
infile = '../wav/01_no_reply.wav';

% FFT analysis parameters
M = 8192;
hs = 2048;
fs = 11025;

% chroma analysis parameters
B = 36; % # of bins per octave
fmin = 48;
fmax = fs/2;

% compute fft-to-chroma kernel matrix: one-time calculation
kernel = fft2chroma_mtx(fs,M,hs,fmin,fmax,B);

% compute chromagram
disp('Extracting chroma features...');
[chroma,tuning_center] = gen_chroma(infile,kernel,fs,M,hs);
tuning_center

% time index in seconds
T = length(chroma);
ti = hs*[0:T-1]/fs;

% chord templates
Cmaj_temp = [1;0;0;0;1;0;0;1;0;0;0;0];
Cmin_temp = [1;0;0;1;0;0;0;1;0;0;0;0];
maj_temp = []; % major chord template
min_temp = []; % minor chord template

for i=1:12 % for each chord (maj/min)
  maj_temp = [maj_temp,circshift(Cmaj_temp,i-1)];
  min_temp = [min_temp,circshift(Cmin_temp,i-1)];
end

chord_temp = [maj_temp,min_temp]; % 12x24 chord template matrix

% chord recognition by computing correlation per frame
for i=1:T % for each frame
  cor = corrcoef([chroma(:,i),chord_temp]);
  cor(find(isnan(cor))) = 0;
  maxcor = find(cor(1,2:end)==max(cor(1,2:end)));
  chord(i) = maxcor(1);
% $$$   for c=1:24 % for each chord
% $$$     tmp = corrcoef(ch_e(:,i),chord_temp(:,c));
% $$$     cor(c) = tmp(1,2);
% $$$   end
% $$$   chord(i) = find(cor==max(cor));
end

% smoothing
chord_sm = medfilt1(chord,9);

% display
pitch_class = {'C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'};
chord_label = {'C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B',...
               'c','c#','d','eb','e','f','f#','g','ab','a','bb','b'};

figure;
subplot(211); imagesc(ti,1:12,chroma); colormap(1-gray); set(gca,'YDir','normal');
title('chromagram'); ylabel('pitch class'); xlabel('time (s)');
set(gca,'YTick',1:12,'YTickLabel',pitch_class);
subplot(212); plot(ti,chord,'bo-'); hold on; plot(ti,chord_sm,'rx-'); xlim([0 ti(end)]); ylim([0 25]);
title('recognized chord'); ylabel('chord name'); xlabel('time (s)'); ...
    grid on;
set(gca,'YTick',1:24,'YTickLabel',chord_label);





























