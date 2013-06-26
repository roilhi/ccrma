
function [seq,loglik] = extract_chord(tc,param);
  
% FUNCTION SEQ = EXTRACT_CHORD(TC,PARAM);
  
  Pi = param.Pi;
  transMat = param.transMat;
  mu = param.mu;
  covMat = param.covMat;
  % convert mu and sigma to matrices
  mu = cell2mat(mu);
  [ndim N] = size(mu);
  
  sigma = zeros(ndim,ndim,N);
  
  N = 24;
  for c=1:N
    sigma(:,:,c) = diag(diag(covMat{c}));
  end
  
  Pi = Pi(1:N);
  mu = mu(:,1:N);
  sigma = sigma(:,:,1:N);
  transMat = transMat(1:N,1:N);
  Pi = Pi/sum(Pi);
  transMat = normalise(transMat,2);
  
  sign = tc;
  
  T = size(sign,2); % number of frames
  B = zeros(N,T); % observation probability matrix

  nfeat = ndim;
  B = mixgauss_prob(sign(1:nfeat,:),mu(1:nfeat,:),sigma(1:nfeat,1:nfeat,:),ones(N,1)); % much faster
  [seq,loglik] = viterbi_path(Pi,transMat,B);



