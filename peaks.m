% -*- octave -*-
function peaks = peaks(signal,minimum)
  signalPlus = circshift(signal, [1, 1]);
  signalMinus = circshift(signal, [1, -1]);
  if nargin < 2
    peaks = signal > signalPlus & signal > signalMinus;
  else
    peaks = signal < signalPlus & signal < signalMinus;
  end
end
