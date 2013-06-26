
% CCRMA MIR Workshop 2009
% Lab3.4: Chord recognition using an HMM
% Kyogu Lee (June 2009)

clear all;
close all;

clear all;
close all;

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

% convert to tonal centroid
ch2tc_mtx = load('tc_mat.mat');
tc = ch2tc_mtx.tc_mat*chroma;

% load HMM parameter
param = load('param_8192_2048_BA_tc_low_trans.mat');

% extract frame-level chord sequence
disp('Extracting chord sequence...');
[chord,loglik] = extract_chord(tc,param);

% display
pitch_class = {'C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'};
chord_label = {'C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B',...
               'c','c#','d','eb','e','f','f#','g','ab','a','bb','b'};

subplot(211); imagesc(ti,1:12,chroma); colormap(1-gray); set(gca,'YDir','normal');
title('chromagram'); ylabel('pitch class'); xlabel('time (s)');
set(gca,'YTick',1:12,'YTickLabel',pitch_class);
subplot(212); plot(ti,chord,'bo-'); xlim([0 ti(end)]); ylim([0 25]);
title('recognized chord'); ylabel('chord name'); xlabel('time (s)'); ...
    grid on;
set(gca,'YTick',1:24,'YTickLabel',chord_label);
























