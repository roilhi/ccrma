function sig = makemelody(notes,durs,legato,fs,snr)
% sig = makemelody(notes,durs,chan,legato,fs,snr)
% make a melody using provided notes, durations.
% legato specifies if there will be a gap between notes (legato < 1)
% outputs a sound vector at sampling rate fs
% the program adds comfort noise at snr dB 
%
%Example:
% sig = makemelody([67 64 64 65 62 62 60 62 64 65 67 67 67],[3 1 4 3 1 4 3 1 3 1 2 2 4]/4,11025,60);
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin < 3,
legato = 0.8;
end
if nargin < 4,
fs = 11025;
end
if nargin < 5,
snr = 60;
end

nm2 = createnmat2(notes,dur,100,1,legato);

sig = nmat2snd(nm2,'fm',fs);
s = sig + randn(size(sig)) * std(sig) / (10^(snr/20));
