% An example how to create a Talk Box using LPC
% by Shlomo Dubnov 

[x,fs] = wavread('speech');

win = 320;
hopfactor = 2;
p = 16;
[S,Res,A,E,t] = LPCAna(x,win,hopfactor,p,win); %320 is 40 msec at 8KHz

close all

% figure
% specgram(x)
% title('original')
% figure
% imagesc(log(abs(S))); axis xy
% title('lpc envelope')
% figure
% if hopfactor == 1
%   res = Res(:);
% else
%   res = ola(Res,hop);
% end
% specgram(res)
% title('lpc residual')

r = 0.5; %time stretch

if 0,
    nsamp = size(Res,2)*hop + win;
    f0 = 200;
    ex = buzz(f0,nsamp/r,fs);
    %ex = randn(1,nsamp/r); %noise
else
    %Sax excitation
    [ex,fs2] = wavread('Sax2.wav');
    ex = resample(ex,fs,fs2);
    %fs = 8000;
end

hop = win/hopfactor;
ymat = LPCfilter(E,A,ex,win,hopfactor);
y = ola(ymat,hop);
soundsc(y,fs)


% same filtering can be done using Stft of ex and spectral envelope S.
% It is left as an excersize for the reader.