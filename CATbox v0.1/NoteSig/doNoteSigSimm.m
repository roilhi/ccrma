mp3name = '../Sounds/Bach Prelude in G Magor WTC Book I (gould).mp3';
%mp3name = '/Users/sdubnov/Sounds/Music/Bach__Prelude_in_G_major_Well_Tempered_Clavier_Book_I.mp3';
midiname = '../Sounds/Midi/wtc1151.mid';

nmat = readmidi(midiname);
[s,fs] = mp3read(mp3name,[],1,4); %whole file, 'mono', downsample by 4

%[s,fs] = wavread('/Users/sdubnov/Sounds/Music/wtc1151.wav'); %,[100000 200000]);

frame_len=512;
overlap = frame_len/2;
smat = buffer(s,frame_len,overlap);

nmat = readmidi('../Sounds/wtc1151.mid');

% in case of using octave, or if you do not have signal processing toolbox, use
% framing.m instead of buffer. Note that framing uses overalp in precent.
%overlap1=overlap*100/frame_len;
%[sMat,K]=framing(s,frame_len,overlap1);

sMat = sMat(:,60:end);

q = 1/32;

LL = NoteSigSimm(nmat,smat,q)

imagesc(LL)

