
function ch_mtx = fft2chroma_mtx(fs,nfft,hs,fmin,fmax,B);
  
% FUNCTION CH_MTX = FFT2CHROMA_MTX(FS,NFFT,HS,FMIN,FMAX,B);
% returns a matrix for converting fft (or spectrogram) to B-dim chroma
% Kyogu Lee (8/15/07)
  
  cq_mtx = fft2cq_mtx(fs,nfft,hs,fmin,fmax,B); % nfft x nlogbin
  [nframe,nlogbin] = size(cq_mtx);

  cq2ch_mtx = zeros(nlogbin,B); % nlogbin x B
  L = floor(nlogbin/B);
  
  for b=1:B
    idx_one = b+B*[0:L];
    cq2ch_mtx(idx_one(find(idx_one<=nlogbin)),b)=1;
  end
  
  ch_mtx = cq_mtx*cq2ch_mtx; % nfft x B
  ch_mtx = ch_mtx'; % B x nfft
