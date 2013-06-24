function E = spectralEnergy_weighted(X,startFreq,endFreq,fftSize,fs)
% E = spectralEnergy(X,startFreq,endFreq,fs)
% Calculate the Spectral Energy in a particular bin 
%
% Bin number = fftSize * f(hz)
%                        ----
%                         fs

startBin = round(fftSize * startFreq / fs);
if startBin == 0 
    startBin = 1; % can't have a bin set to 0
end    
endBin = round(fftSize * endFreq / fs);

E = sum( X(startBin :endBin).*[startBin :endBin]' );

return
