%nm=readmidi('../Sounds/wtcii01a.mid');

nm=readmidi('../Sounds/donna.mid');
%nm = getmidich(nm,3);
nm = dropmidich(nm,10);

q = 1/16;
nc = nmat2ncel(nm,q);
pr = ncel2prol(nc);
%imagesc(pr)

ncx = ncel2ncros(nc,2); % 2 is for duration
sx = cell2mat(ncx(:,4));

% Generate new sequence
% ---------------------
[t,s] = FO(sx);
xo = FOgen(t,s,1000,0.9,1);
nco = xseq2ncel(xo,ncx);

pro = ncel2prol(nco);
nmo = prol2nmat(pro,q);
playmidi(nmo)
%writemidi(nmo,'out2.mid')