function [d,e1,e2] = distis(x,y,p)
% Itakura-Saito distance between vectors x nad y
% [d,e1,e2] = distis(x,y,p);
% x,y = input samples
% p = AR model order
% d = distance measure
% (based on IS distance of AR models)
% e1,e2 = lpc modeling errors
%

PLT = 0;
if nargin == 1,
    p = 8;
end


x = x-mean(x);
y = y-mean(y);

%Pxx = pburg(x,4);
[A1,e1] = lpc(x,p);
[A2,e2] = lpc(y,p);

d = distisar(A1,A2);
d = real(d);

if PLT,
    subplot(211)
    plot(x)
    subplot(212)
    [H1,W,s] = freqz(1,A1);
    [H2] = freqz(1,A2);
    H = [H1 H2];
    s.plot   = 'mag';     % Plot magnitude only
    freqzplot(H,W,s) 
    pause
end
