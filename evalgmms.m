function [loglikelihood,meanOutput , time] = evalgmms(DATA, M0,M1)
% [loglikelihood,meanOutput , time] = evalgmms(DATA, M0,M1)
%     Evaluate test data against Gaussian mixture models and evaluate their accuracy 
% Based on 2003-06-30 dpwe@ee.columbia.edu muscontent practical
% Jay LeBoeuf 2010 - CCRMA MIR Workshop

% Start execution timer
tic;

% if nargin < 3
%   NGAUSS = 5;
% end


% Data likelihood for 0-labelled frames
% LR0 = log(gmmprob(M1, DATA)./gmmprob(M0, DATA));
a=gmmprob(M0, DATA)  ; %handle the case where 0s or Infs are detected.  This prevents NaNs from occuring
a(find(a==0))=1;
b=gmmprob(M1, DATA)  ; 
b(find(b==0))=1;
loglikelihood = log (a./b);
meanOutput = mean(loglikelihood)

% How long did it take?
time = toc;
disp(['Elapsed time = ', num2str(time),' secs']);

