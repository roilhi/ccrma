function [peaks,frqs]=findpeaks(Xwdb,binsize,m)

%function [peaks,freqs,snr]=findpeaks(Xwdb,m,binsize,win)
% Find the peaks(up to m peaks) of the spectrum Xwdb
% peaks = a vector containing the peak magnitude estimates (dB) using
% parabolic interpolation in order from largest to smallest peak.
% freqs = a vector containing the frequency estimates (Hz) corresponding
% to the peaks defined above
% Xwdb = DFT vector of a windowed signal in dB
% m = the number of peaks we are looking for
% binsize = the size of each DFT bin = f_s/N_fft
% win = the window used to obtain Xwdb (for unbiased amplitude estimate)

Xwdb=Xwdb(:)';

%peaks=zeros(maxPeaks,1);    %initialize value of peaks output
%freqs=zeros(maxPeaks,1);    %initialize frequency locations of peaks
%plot(fgrid,MagXw);hold on;

%Find peaks and their locations by comparing with adjacent neighbours
allPeaks=[];
peaks = [];
frqs=[];
for i=2:length(Xwdb)-1
    if Xwdb(i)>Xwdb(i-1) & Xwdb(i)>Xwdb(i+1)
        allPeaks(length(allPeaks)+1)= Xwdb(i);
    end
end

%Then choose 'm' of them
allPeaks = flipud(sort(allPeaks'));
if length(allPeaks) >= m
  peaks = allPeaks(1:m);
else
  peaks = allPeaks;
end


%find associated frequencies(Hz) of those peaks
for i=1:length(peaks)
  idx=find(Xwdb==peaks(i));
  N = Xwdb;
  N(idx)=-60;
  idx=idx(1);
  %parabolic interpolation
  a=Xwdb(idx-1);
  b=Xwdb(idx);
  c=Xwdb(idx+1);
  df=0.5*(a-c)/(a-2*b+c);
  frqs(i)=(idx-1+df)*binsize;
  
  peaks(i)=b-0.25*(a-c)*df;
  %if don't want parabolic interpolation, comment in below instead
  %freqs(i)=(idx-1)*binsize;	
end 
% Get rid of a biasing window in the amplitude
%peaks = peaks-20*log10(sum(win));
if ~length(frqs) % no peak
  frqs = 36*rand;
else
  frqs = frqs(:);
end
%Nave = mean(N);
%snr = -Nave;

% Linear amplitude (if required)
%peaks=(10.^(peaks/20));
