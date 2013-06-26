function logLikelihood = NoteLikelihood(freqVec,sMat,harm,Nsig)
% logLikelihood = NoteLikelihood(freqVec,sMat,harm,Nsig)
% Calculate Likelihood of a certain freqeuncy in a signal
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin < 3,
    harm = 8; %number of harmonics used for likelihood projection
end

res = 1;

Esig = sum(abs(sMat).^2) + 0.0001;           % energy of the signal per each frame aranged in vector
if nargin < 4
    Nsig = min(Esig);
end

Nfreq = length(freqVec);
[frame_len, K] = size(sMat);

if freqVec == 0, %silence
    logLikelihood = -0.5*(2*log(2*pi*Nsig)+1+log(Esig/Nsig));
    %logLikelihood = zeros(size(Esig));
    return
end

c=2*pi*([0:frame_len-1]' * [1:harm]);
AA = zeros(frame_len,2*harm+1,Nfreq);
AAH = zeros(2*harm+1,frame_len,Nfreq);

iFreq = 0;
for freqCur = freqVec,
    iFreq = iFreq + 1;
    A=[ones(frame_len,1) cos(c*freqCur) sin(c*freqCur)];
    AA(:,:,iFreq) = A;
    AAH(:,:,iFreq) = A';
end

% Harmonic Likelihood Projection
Xmat=zeros(2*harm+1,frame_len,Nfreq);

for iFreq = 1:Nfreq,
    AAHcur = AAH(:,:,iFreq);
    AAcur = AA(:,:,iFreq);
    [U,D,V] = svd(AAHcur*AAcur);
    DD = diag(1./sqrt(diag(D)));
    X=(U*DD*U')*AAHcur;
    Xmat(:,:,iFreq)=X;
end

% Calculate Likelihood
logLikelihoodV = zeros(Nfreq,K);

for iFreq = 1:Nfreq,
    X=Xmat(:,:,iFreq)*sMat(:,1:end);
    PAy(iFreq,:)=sum(abs(X).^2);
    %   PAcy(iFreq,:)=Esig-PAy(iFreq,:);
    PAcy(iFreq,:)=1-PAy(iFreq,:)./Esig;
    logLikelihoodV(iFreq,:) = -log(PAcy(iFreq,:));
end

if size(logLikelihoodV,1) == 1,
    logLikelihood = logLikelihoodV;
else
    logLikelihood = mean(logLikelihoodV);
end