
function y = find_tuning_center(chromagram);
  
% FUNCTION Y = FIND_TUNING_CENTER(CHROMAGRAM,FS,NFFT);
% returns tuning center between 1 and 3
% only when there are 3 bins in a semitone
% chromagram is a 36-d chromagram
% fs is a sampling rate
% nfft is a fft size
  
  nframe = size(chromagram,2);
  peaks = cell(1,nframe);
  freqss = cell(1,nframe);
  K = 100; % step size in histogram
  n = zeros(K+1,nframe);
  edges = [0:3/K:3];
  
  for i=1:nframe
    [peaks{i},freqss{i}] = findpeaks_all(20*log10(chromagram(:,i)),1);
    %[peaks{i},freqss{i}] = findpeaks(chromagram(:,i),1,20);
    freqss{i} = freqss{i}-0.5;
    freqs_in_st{i} = mod(freqss{i},3); % peak frequencies in one semitone
    n(:,i) = histc(freqs_in_st{i},edges);
    
% $$$     if sum(hpcp(i)) > eps
% $$$       hpcp(:,i) = hpcp(:,i)/sum(hpcp(:,i)); % normalize (sum to 1)
% $$$     end
  end
  
  ns = sum(n,2); % histogram
  y = edges(find(ns==max(ns))); % find tuning center (where maximum # of
                                % peaks occur)
  
  y = mean(y); % in case there are more than one peak
  
  
