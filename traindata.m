snareDirectory = ['/usr/ccrma/courses/mir2012/audio/drum samples/snares/'];
snareFileList = getFileNames(snareDirectory ,'wav')
kickDirectory = ['/usr/ccrma/courses/mir2012/audio/drum samples/kicks/'];
kickFileList = getFileNames(kickDirectory ,'wav')


for i=1:length(snareFileList)
[x,fs]=wavread([snareDirectory snareFileList{i}]);
frameSize = 0.100 * fs; % 100ms
currentFrame = x(1:frameSize);
featuresSnare(i,1) = zcr(currentFrame);
[centroid, bandwidth, skew, kurtosis]=spectralMoments(currentFrame,fs,8192)
featuresSnare(i,2:5) = [centroid, bandwidth, skew, kurtosis];
end

for i=1:length(kickFileList)
[x,fs]=wavread([kickDirectory kickFileList{i}]);
frameSize = 0.100 * fs; % 100ms
currentFrame = x(1:frameSize);
featuresKick(i,1) = zcr(currentFrame);
[centroid, bandwidth, skew, kurtosis]=spectralMoments(currentFrame,fs,8192)
featuresKick(i,2:5) = [centroid, bandwidth, skew, kurtosis];
end

[trainingFeatures,mf,sf]=scale([featuresSnare; featuresKick]);
labels=[[ones(10,1) zeros(10,1)]; [zeros(10,1) ones(10,1) ]];

model_snare = knn(5,2,1,trainingFeatures,labels);




%test the trained model
[y,fs]=wavread('/usr/ccrma/courses/mir2012/audio/drum samples/test snares/2 Rim & snr.wav');
if size(y,2)==2
    y= (y(:,1)+y(:,2) ) ./ max(abs(y(:,1)+y(:,2))) ;
   disp('Making your file mono…');
end
%  
% [onsets, numonsets] = ccrma_onset_detector(y,fs);
% onsets=round(onsets); %round to nearest integer sample
% 
% 
% frameSize = 0.100 * fs; % 100ms
% for i=1:numonsets
% 
% frames{i}= y(onsets(i):onsets(i)+frameSize);
% 
frameSize = 0.100 * fs; % 100ms
currentFrame = y(1:frameSize);

 [centroid, bandwidth, skew, kurtosis]=spectralMoments(currentFrame,fs,8192)
 features = [zcr(currentFrame), centroid, bandwidth, skew, kurtosis];

%rescale the feature vectors


featuresScaled = rescale(features,mf,sf) ;

[voting,model_output]=knnfwd(model_snare , featuresScaled );
output = zeros(size(model_output),2);
output(find(model_output==1),1)=1;
output(find(model_output==2),2)=1;
output


