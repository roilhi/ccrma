function xi = TimeStretch(x,r)
% xi = TimeStretch(x,r)
% time stretch a sound vector x by factor r

X = Stft(x,512,4);
t = [1:r:size(X,2)-1];
%t = linspace(1,size(X,2),size(X,2)/r);
hop = 512/4;
Xi = pvinterp(X,t,hop);
xi = IStft(Xi,4);
