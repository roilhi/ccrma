%% -*- octave -*-
function sinetone = sinetone(frequency, sampleRate, duration, amplitude, phase)
% frequency in Hz, bipolar normalized amplitude, duration in seconds.
  if(nargin < 4)
    sampleRate = 44100;
  endif
  if(nargin < 5)
    phase = 0; % radians
  endif
  radianFreq = ([0 : 1 / sampleRate : duration - 1/sampleRate] .* 2 .* pi * frequency);
  sinetone = amplitude * sin(radianFreq + phase); 
end

