
% CCRMA MIR Workshop 2009
% Lab3.2: Key estimation
% Kyogu Lee (June 2009)

clear all;
close all;

warning('off');

% input audio filename
infile = '../wav/prelude_cmaj.wav';

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

% compute chromagram average
ch_avg = mean(chroma,2);

% key profiles (from Krumhansl)
Cmaj_key_prof = [6.35;2.23;3.48;2.33;4.38;4.09;2.52;5.19;2.39;3.66;2.29;2.88];
Cmin_key_prof = [6.33;2.68;3.52;5.38;2.60;3.53;2.54;4.75;3.98;2.69;3.34;3.17];
maj_prof = []; % major key profile
min_prof = []; % minor key profile

for i=1:12 % for each key
  maj_prof = [maj_prof,circshift(Cmaj_key_prof,i-1)];
  min_prof = [min_prof,circshift(Cmin_key_prof,i-1)];
end

key_prof = [maj_prof,min_prof]; % 12x24 key profile matrix

% compute correlation
% $$$ cor = corr(ch_avg,key_prof);
% $$$ for k=1:24
% $$$   tmp = corrcoef(ch_avg,key_prof(:,k));
% $$$   cor(k) = tmp(1,2);
% $$$ end
cor = corrcoef([ch_avg,key_prof]);
cor = cor(1,2:end);
key = find(cor==max(cor)); % select maximum correlation profile

% display
key_label = {'C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B',...
             'c','c#','d','eb','e','f','f#','g','ab','a','bb','b'};

plot(cor,'bo-'); hold on; plot(key,cor(key),'rx','MarkerSize',16,...
                               'LineWidth',3); grid;
set(gca,'XTick',1:24);
set(gca,'XTickLabel',key_label);
vline(key,'g');















