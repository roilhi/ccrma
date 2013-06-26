
% CCRMA MIR Workshop 2009
% Lab3.1: Chroma analysis
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
fi = [0:fs/M:fs-fs/M];

% chroma analysis parameters
B = 36; % # of bins per octave
fmin = 48;
fmax = fs/2;

% compute fft-to-chroma kernel matrix: one-time calculation
kernel = fft2chroma_mtx(fs,M,hs,fmin,fmax,B);
figure;
imagesc(fi,1:36,kernel); colormap(1-gray);
set(gca,'ydir','normal');
xlabel('frequency (Hz)');
ylabel('chroma bin');

% compute chromagram
disp('Extracting chroma features...');
[chroma,tuning_center] = gen_chroma(infile,kernel,fs,M,hs);
tuning_center

% time index in seconds
T = length(chroma);
ti = hs*[0:T-1]/fs;

% display
figure;
pitch_class = {'C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'};
imagesc(ti,1:12,chroma); colormap(1-gray); set(gca,'YDir','normal');
title('chromagram'); ylabel('pitch class'); xlabel('time (s)');
set(gca,'YTick',1:12,'YTickLabel',pitch_class);


























