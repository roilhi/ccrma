function [M0,LR0] = traingmm(DATA, NGAUSS)
% [M0, LR0] = traingmm(DATA, NGAUSS)
%     Train one Gaussian mixture model.  
%  Input:
%     DATA is rows of training feature vectors 
%     NGAUSS components
%  Output 
%     M0 - the model GMM model created
%     LR0 - data likelihood computed with training data
% Return total elapsed time in time.
% 2003-06-30 dpwe@ee.columbia.edu muscontent practical
% 2010 - Slightly update to support only 1 GMM training at a time by Jay
% LeBoeuf

% Start execution timer
tic;

% if nargin < 3
%   NGAUSS = 5;
% end

% DATA = DATA(LABELS == 1,:);
% dd1 = DATA(LABELS == 1,:);

ndim = size(DATA, 2);

M0 = gmm(ndim, NGAUSS, 'diag');
% M1 = gmm(ndim, NGAUSS, 'diag');

options = foptions;
options(14) = 5;  % 5 iterations of k-means
M0 = gmminit(M0, DATA, options);
% M1 = gmminit(M1, dd1, options);

options = zeros(1,18);
options(14) = 20;  % 20 iterations of EM
M0 = gmmem(M0, DATA, options);
% M1 = gmmem(M1, dd1, options);

% Data likelihood for 0-labelled frames
LR0 = log(gmmprob(M0, DATA)); %./gmmprob(M0, DATA));
mean(LR0)
% Data likelihood for 1-labelled frames
% LR1 = log(gmmprob(M1, dd1)./gmmprob(M0, dd1));

% Overall classification accuracy on training data
% acc = mean((LR0' < 0));
% disp(['Accuracy on training data = ',num2str(round(1000*acc)/10), '%']);

% How long did it take?
time = toc;
disp(['Elapsed time = ', num2str(time),' secs']);

