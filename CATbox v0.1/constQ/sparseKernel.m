function sparKernel= sparseKernel(minFreq, maxFreq, bins, fs, thresh)

if nargin<1, minFreq = 8.1758; end
if nargin<2, maxFreq = 11025/2; end
if nargin<3, bins = 12; end
if nargin<4, fs = 11025; end
if nargin<5, thresh= 0.0054; end    % for Hamming window


Q= 1/(2^(1/bins)-1);                                                     
K= ceil( bins * log2(maxFreq/minFreq) );                                 
fftLen= 2^nextpow2( ceil(Q*fs/minFreq) ); 
tempKernel= zeros(fftLen, 1); 
sparKernel= []; 
for k= K:-1:1; 
   len= ceil( Q * fs / (minFreq*2^((k-1)/bins)) );                       
   tempKernel(1:len)= hamming(len)/len .* exp(2*pi*i*Q*(0:len-1)'/len);  
   specKernel= fft(tempKernel);                                          
   specKernel(find(abs(specKernel)<=thresh))= 0; 
   sparKernel= sparse([specKernel sparKernel]); 
end 
sparKernel= conj(sparKernel) / fftLen;                                   
 

