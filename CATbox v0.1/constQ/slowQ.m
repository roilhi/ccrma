function cq = slowQ(x, minFreq, maxFreq, bins, fs)
% cq = slowQ(x, minFreq, maxFreq, bins, fs)
% x - input sound
% minFreq, maxFreq, bins - the range of frequencies [minFreq maxFreq] is
% divided into "bins" number of bins per octave
%
% Slow implementation of constant Q transfrom from Benjamin Blankertz 

if nargin < 2, minFreq = 27.5; end %midi note 21 - lowest A on the keyboard
if nargin < 3, maxFreq = 11025/2; end
if nargin < 4, bins = 12; end
if nargin < 5, fs = 11025; end

Q= 1/(2^(1/bins)-1); 
for k=1:ceil(bins*log2(maxFreq/minFreq)); 
   N= round(Q*fs/(minFreq*2^((k-1)/bins)));
   cq(k)= zpad(x,N) * (hamming(N) .* exp( -2*pi*i*Q*(0:N-1)'/N)) / N; 
end


function y=zpad(x,n)
% trim or zero pad x to length M

y = zeros(1,n);
m = min(length(x),n);
y(1:m) = x(1:m);
