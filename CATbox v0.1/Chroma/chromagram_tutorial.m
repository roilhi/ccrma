close all
clear

%semitone
st = 2^(1/12);

% chroma scale centered on C4 = 220*st^3 Hz
C4 = 220*st^3;
C = log2(C4*st.^[0:11])-floor(log2(C4*st.^[0:11]));

if 0,
%generate a scale
major = [0 2 4 5 7 9 11 12] + 60;
nmat = createnmat(major,0.2,127,1);
x = nmat2snd(nmat,'fm',11025);
I = find(x); %remove silence
x = x(I);

else %actual music
mp3name = '../Sounds/Bach__Prelude_in_G_major_Well_Tempered_Clavier_Book_I.mp3';
%[signal,fs] = mp3read(mp3name);
%signal = shiftdim(signal);
%signal = sum(signal(100000:100000+10*fs,:)');
%x = resample(signal,11025,fs);
    [x,fs] = mp3read(mp3name,[],1,4); %read whole file, 'mono', downsample by 4
end
x = clipsil(x);

fs = 11025;
Nfft = 2048;
win = 512;
hop = 128;
disp('Spectrogram Calculation ...')
[X,F,T] = specgram(x,Nfft,fs,hamming(win),win-hop); %it is important to specify fs
F = F(2:end); %without DC
Fc = log2(F) - floor(log2(F));
figure
plot(Fc,'-x');
hold on
plot(C,'or')
title('FFT bins in terms of chroma and chroma scale')
%Now we associate each chroma frequency to the chroma scale

for i = 1:length(C),
DFc(:,i) = abs(Fc - C(i));
end
%show how the association is done
figure
imagesc(DFc)

[m,S] = min(DFc');
figure
plot(S,'-x')
title('Frequency bins associated with chroma scale')

disp('Chroma Calculation ...')
XCG = zeros(length(C),size(X,2));
XLM = log(abs(X(2:end,:))); %log magnitude, without DC
for i = 1:size(XCG,1)
    I = find(S == i);
    XCG(i,:) = mean(XLM(I,:));
end

figure
imagesc(XLM); axis xy
title('Spectrogram')

figure
imagesc([1:size(XCG,2)],[0:11],XCG); axis xy
title('Chromagram')
