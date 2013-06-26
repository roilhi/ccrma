mp3name = '../Sounds/Bach__Prelude_in_G_major_Well_Tempered_Clavier_Book_I.mp3';
[x,fs] = mp3read(mp3name,[],1,4); %read whole file, 'mono', downsample by 4
x = clipsil(x);

close all

fs = 11025;
Nfft = 2048;
win = 512;
hop = 128;

[XCG,XLM] = chroma(x,fs,Nfft,win,hop);

imagesc(XLM); axis xy
title('Spectrogram')

figure
imagesc([1:size(XCG,2)],[0:11],XCG); axis xy
title('Chromagram')
