[x,fs] = wavread('clar.wav');
[f,m,n,b,T] = yasa(x,512,2,60,fs);
[F,M,N,B] = maketracks(f,m,n,b,1/1.03,1.03);
[zs,zn] = synthsntrax(F,M,N,fs,512/2,120);
zr = 4*zs + zn;
soundsc(zr,fs)

[x,fs] = wavread('speech.wav');
y = filter(x,[1 -0.95]); %preemphasis
[f,ms,mn,n,b,T] = yasa(y,512,2,60,fs);
[F,Ms,Mn,N,B] = maketracks(f,ms,mn,n,b,1/1.03,1.03);
[zs,zn] = synthsntrax(F,Ms,Mn,N,fs,512/2);
zr = 4*zs+zn;
xr = filter(1,[1 -0.95],zr); %deemphasis
soundsc(xr,fs)
soundsc(x,fs)

%time stretch
[zs,zn] = synthsntrax(F,M,N,fs,512/2,120,10);
%pitch shift
[zs,zn] = synthsntrax(2*F,M,N,fs,512/2,120);

%noise reduction...
% analyze with higher beta in yasa
% reduce Fmin,Fmax and possibly Aratio in maketracks


