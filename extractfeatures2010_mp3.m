% Compute all features for popular songs.

% snareDirectory = ['C:\Users\Jay\Documents\Presentations\CCRMA MIR 2010\code\'];
snareFileList = getFileNames(snareDirectory,'mp3')
% 
% kickDirectory = ['C:\Users\Jay\Documents\Presentations\CCRMA MIR 2009\audio\drum samples\kicks\'];
% kickFileList = getFileNames(kickDirectory ,'wav');
% snareFileList=kickFileList; snareDirectory = kickDirectory;

currentFrameIndex = 1;

for fileNumber=1:length(snareFileList)

    fileNumber
    
    disp(['reading mp3 file: ' snareFileList{fileNumber} ] )
    [x,fs]=mp3read([snareDirectory snareFileList{fileNumber}]);
%     [x,fs]=wavread([snareDirectory snareFileList{fileNumber}]);

    
    frameSize = 0.100 * fs; % 100ms

    x=x(:,1); % mono 
    disp('extracting features...')
    currentFrameIndex = 1;

    features.frames = zeros(size(1:frameSize/2:(length(x)-frameSize-1),2),57);   %consider preallocating for speed
    for i=1:frameSize/2:(length(x)-frameSize-1) %length(x)-frameSize
        currentFrame = x(i:i+frameSize)+eps;
        [centroid, bandwidth, skew, kurtosis]= spectralMoments(currentFrame,fs,8192); % 1st value is spectral centroid, 2nd value is spectral spread, 3rd value is spectral flatness measure
        features.frames (currentFrameIndex,1) = zcr(currentFrame);
        features.frames (currentFrameIndex,2:5) =  [centroid, bandwidth, skew, kurtosis];
        % The code generates MFCC coefficients for the audio signal given in the current frame.
		[mfceps] = mfcc(currentFrame ,fs)' ;   %note the transpose operator!
        delta_mfceps = mfceps - [zeros(1,size(mfceps,2)); mfceps(1:end-1,:)]; %first delta
		    
		% Calculate the mean and std of the MFCCs, MFCC-deltas.
        MFCC_mean = mean(mfceps) ;
		MFCC_std= std(mfceps);
        MFCC_delta_mean = mean(delta_mfceps);
		MFCC_delta_std= std(delta_mfceps);
		        
        features.frames (currentFrameIndex,6:18) = MFCC_mean;
        features.frames (currentFrameIndex,19:31) = MFCC_std;
        features.frames (currentFrameIndex,32:44) = MFCC_delta_mean;
        features.frames (currentFrameIndex,45:57) = MFCC_delta_std;
        
        currentFrameIndex=currentFrameIndex+1;
        
        if ~mod(currentFrameIndex,50)
            disp(currentFrameIndex);
        end        
    end
    
    % Store entire-file summary
    features.mean = mean(features.frames)
    features.std = std(features.frames)

    disp(['storing features for file: ' snareFileList{fileNumber} ] )
    save([snareDirectory snareFileList{fileNumber} '.mat'],'features') 
end
