function [L1,SX,SY,VY] = ABDist(x,y,ABType,DistType,fs,numIC,ICAflag,NumOfMixtures,MinimumVariance,NumOfIterations)
% [L1,SX,SY,VY] = ABDist(x,y,ABType,DistType)
% Distance between sounds using Audio Basis
% Input:
% x - query sound
% y - reference sound
% ABtype - type of Audio Basis (AB):
%   'MAG' - Short time FFT magnitudes (default)
%   'ENV' - MPEG-7 AudioSpectrumEnvelope (4 Bands Per Octave)
%   'ERB' - ERB Auditory filter Bank
% DistType- type of distance measure
%   'KL' - Kulback Liebler distance using GMM model
%   'Like' - log probability using GMM
%   'IS' - Itakura Saito Distance
%
% [L1,SX,SY,VY] = ABDist(x,y,ABType,DistType,fs,numIC,ICAflag)
%   fs - sampling frequency
%   numIC - number of AB components (10 default)
%   ICAflag - type of independence transform: 1 = SVD (default), 2 = ICA
%
% Depending on the distance type, specify the distance parameters
%   using 'KL' or 'Like' (using Gaussian Mixture Model)
% [L1,SX,SY,VY] = ABDist(x,y,ABType,DistType,fs,numIC,ICAflag,NumOfMixtures,MinimumVariance,NumOfIterations)
%   using 'IS'
% [L1,SX,SY,VY] = ABDist(x,y,ABType,DistType,fs,numIC,ICAflag,p)
%       p - order of AR model
%
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin < 3,
    ABType  = 'MAG';
end
if nargin < 4,
    DistType = 'KL';
end
if nargin < 5,
    fs = 16000;
end
if nargin < 6,
    numIC= 10;
end
if nargin < 7,
    ICAflag = 1; %1 = SVD, 2 = ICA (Jade)
end
if nargin < 8,
    NumOfMixtures = 3*numIC;
end
if nargin < 9,
    MinimumVariance = 0.01;
end
if nargin < 10,
    NumOfIterations = 20.01;
end


% Build the observation matrix. It can be Magnitude spectra (as casey does) or
% something else.

disp('Observations Matrix Calculation ...')
[X] = makeObservationMatrix(x,fs,ABType );
[Y] = makeObservationMatrix(y,fs,ABType );


% Perform ICA on all observaton matrix and find the ICA basis vectors (V)
[VY,SY] = AudioBasis(Y,numIC,ICAflag);
SX = X * VY; %SX is the coefficients of X estimated using model of Y
%SX = X;
%SY = Y;

disp('Distance Calculation ...')
switch DistType,

    case 'Like',

        %Estimate diagonal mixture of Gaussians model
        [m1,v1,w1]=gaussmix(SY,MinimumVariance,NumOfIterations,NumOfMixtures);

        sigMat1 = sqrt(v1);

        w1T = w1';
        T=size(SX,1); %number of test vectors
        p1=zeros(1,T);
        for t=1:T %computing the prob for signal t
            normSqr1 = sum(abs((repmat(SX(t,:),NumOfMixtures,1) - m1) ./ sigMat1) .^ 2 , 2)';
            p1(t) = sum(w1T.*exp(-normSqr1/2) ./ prod(sigMat1,2)');
        end
        L1 = mean(log(p1));

    case 'KL'

        % we do deterministic intializations of kmeans, so that in case of
        % similar vectors, we would get similar GMM's

        T=size(SY,1); %number of test vectors
        d = size(SY,2); %dimension

        init = linspace(1,T,NumOfMixtures+2);
        init = round(init(2:end-1));
        m0y=SY(init,:);

        T=size(SX,1); %number of test vectors
        init = linspace(1,T,NumOfMixtures+2);
        init = round(init(2:end-1));
        m0x=SX(init,:);

        disp('Computing Gauss Mix 1 ...')
        [m1,v1,w1]=gaussmix(SY,MinimumVariance,NumOfIterations,m0y);
        disp('Computing Gauss Mix 2 ...')
        [m2,v2,w2]=gaussmix(SX,MinimumVariance,NumOfIterations,m0x);

        disp('Calculating KL Distance ...')
        for i=1:NumOfMixtures,
            det1 = prod(v1(i,:));
            det2 = prod(v2(i,:));
            cov1 = diag(v1(i,:));
            cov2inv = diag(1./v2(i,:));

            D(i) = 0.5*(log(det1/det2) + ...
                trace(cov2inv*cov1) + (m1(i,:)-m2(i,:))*cov2inv*(m1(i,:)-m2(i,:))' - d);

            % this is so called matching approximation to KL distance between GMM's
            % Y. Singer and M. K. Warmuth ÒBatch and on-line parameter estimation
            % of Gaussianmixtures based on the joint entropyÓ, Advances in Neural
            % Information processsing Systems (NIPS), pp 578-584, 1998.

        end
        L1 = D*w1;

    case 'IS'

        p = NumOfMixtures;

        for i = 1:size(SY,2),
            D(i) = distis(SX(:,i),SY(:,i),p);
        end
        L1 = sum(D);

 end
