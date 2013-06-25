[x,fs] = wavread('../Sounds/battle01.wav');
[y,fs] = wavread('../Sounds/battle02.wav');
[z,fs] = wavread('../Sounds/cheering.02.wav');
[t,fs] = wavread('../Sounds/cheering.05.wav');

% show how it works
L1 = ABDist(x,t,'ENV','KL',fs,10,1)
pause
L1 = ABDist(x,y,'ENV','KL',fs,10,1)
pause
L1 = ABDist(t,z,'ENV','KL',fs,10,1)
pause

% GMM takes into account distribution of coefficients, without considering
% their time correlation (assuming they are independent)
% IS and TG considers correlation (spectral and higher order) properties
% between the coefficients, assuming they are independent

% IS
L1 = ABDist(x,t,'ENV','IS',fs)
pause
L1 = ABDist(x,y,'ENV','IS',fs)
pause
L1 = ABDist(t,z,'ENV','IS',fs)
pause
