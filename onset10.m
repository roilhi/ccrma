function [numonsets,final_onsets_rescaled_and_pruned,final_amplitudes] = onset10(x,fs)
%
% Usage: 
%  [numOnsets, onsets, amplitudes] = onset10(x,fs)
%
% Input:
% --------------------------------------------------------
% x                     Input signal (floating point array of audio waveform data)
% fs                    Sample Rate of input signal (e.g., 44100)
%
% Output:
% --------------------------------------------------------
% numonsets     = number of detected onsets
% final_onsets  = list of onset times detected (listed in samples offset from beginning of signal x)
% final_amplitudes = list of approx. loudness, velocity, or amplitude of
%                   detected onset segment
%
%
% Jay LeBoeuf
% Imagine Research, Inc
% 2008
% 
% References: Signal Processing Methods for Music Transcription, pg. 109

%% Parameters and Constants
fftSize = 1024; 
numBins = 10; 
frameSize = 0.020 * fs;         % default = 20 ms
overlap =  0.5;                 % overlap between frames (default: 0.5 = 50%)
hopSize = frameSize * overlap; 
binSize = round(fs/fftSize);    % frequency range of each bin (Hz)
onsetCorrectionValue = 800;     % observed # of samples to delay reported onsets. (corresponds with observed onset "offset" issue) 

% Low-frequency average time (Remove Low-energy peaks if less than TWO
% times local N-second average of Ej(n))
averagingTime = 0.5 ;           %default = 1.5 seconds

% Smooth (low-pass filter / average to smooth out the peakedness of the
% detection function
smoothing_Window = 3;           %amount of smoothing; % default = 3 "frames"

% Adaptive Peak Peaking
threshold = 0.01;                   %starter threshold for adaptive peak peaking
waveform_stability = 8;             %default: 8 frames; This is the duration for which the waveform dynamics do not evolve
minimum_spacing_between_peaks = 6;  %default 6 frames; Only the largest peak will be taken within this duration 

% Long Decaying Notes - Heuristic
long_decay_minimum_spacing = 9000;  %default: 9000 samples; If a new Onset is within this range, we'll examine it with the Long Decay Heuristic
long_decay_window_size = 2210;      %default 2210 samples; this is the window that we examine looking for a decaying signal

% Loudness detection
loundness_window_size = 0.050;      % milliseconds; we examine this window of the waveform amplitude to determine loudness of onset

% Enable debugging plots and messages
debug = 0; 

%%
x = x./max(x);  % Normalize everything -1 : 1
if length(x) < 10000
    x=[x zeros(10000-length(x),1)'];
    disp('zero padding your signal - it is really short!')
end

%%
k=1; clear X E ;        % X = FFT(x);  E = Energy of X;
for i = 1: hopSize :length(x)-frameSize 
    X = abs(fft(x(i:i+frameSize),fftSize));     % FFT of frame
    X = X(1:end/2).^2;                          % magnitude square

    % Spectral Energy within bins
    % Klapuri low-energy filters
    E(1,k)=spectralEnergy_weighted(X,44,88,fftSize,fs);   % octave # 1
    E(2,k)=spectralEnergy_weighted(X,88,176,fftSize,fs);  % octave # 2
    E(3,k)=spectralEnergy_weighted(X,176,352,fftSize,fs); % octave # 3
    val = 352;
    for p = 4:19
        val = val*2^(4/12);                                %create third octave bins for rest of frequency range
        E(p,k)=spectralEnergy_weighted(X,val,val*2^(4/12),fftSize,fs); 
    end
    k=k+1;
end


%% Detection Functions (3-point linear regression) for each Energy band! 
% Linear regression aims to detect the start of the transient rather than
% when the signal reaches peak power.

clear D Dtotal;
for j = 1:size(E,1)                                      % number of bands
    for i = 2:size(E,2)-1                                % number of frames
        D(j,i) = (E(j,i+1) - E(j,i-1)) / 3;
    end
end

% Half-Wave Rectify and then summing to get Dtotal
D(find(D<0)) = 0 ;                                      % half-wave rectify all bands

%% Remove Low-energy peaks if less than TWO times local 1.5-second average of Ej(n)
% low bands = 1, 2, 3, 4, and 5

if length(x) >= 1.5*fs    % if there is > 1.5 seconds of audio material in the audio clip to average...
    clear D_oneSecondAverage;
    averageConstant = (averagingTime*fs)/(frameSize/2);         % converst from time to samples to "frames" 

    for i = averageConstant+1 :length(D) - averageConstant
        for j = 1:5
            D_oneSecondAverage(j,i) =  2* mean(D(j,i-averageConstant:i + averageConstant ));
        end
    end

    % WHAT DO I DO FOR THE FIRST and LAST X seconds????
    % My safe guess is to set them at the average thus far...
    for i = 1 : averageConstant 
        for j=1:5
            D_oneSecondAverage(j,i) = D_oneSecondAverage(j, averageConstant );
        end
    end
    for i = length(D) - averageConstant : length(D) 
        for j=1:5
            D_oneSecondAverage(j,i) = D_oneSecondAverage(j,length(D) - averageConstant );
        end
    end

    if debug
        disp('eliminating low frequency peaks');
    end

    % Test and eliminate peaks  % JAYL - I can replace this with a FIND at a
    % later time for better performance.
    for i = 1:length(D)
        for j = 1:5
           if D(j,i) < D_oneSecondAverage(j,i)
               D(j,i) = 0;
           end
        end
    end
end

%%
Dtotal = sum (D); % sum all bands per frame

%% Plot Data
% Scale detection function and x to be same size; 
if debug
    try
        k=1; clear Drescaled;
        for i=(hopSize+1):hopSize :(length(x)-frameSize) % create vector of Onsets
            Drescaled(i) = Dtotal(k); 
            k=k+1;
        end
        if debug
            h=figure (3); plot(x,'c'); hold on; 
            set(h,'Name','Ddetection function');   
            plot(Drescaled/max(Drescaled),'r');
            hold off;
        end
    catch
        disp('plots are not same length - sorry')
    end
end

%% Scaling and Normalize Detection Function 

Dtotal = Dtotal /max(Dtotal);  

%% Smoothing (Low Pass)
%  Observed effect of smoothing - less double-hits, but occasionally looses
%  a weak transient

for i = 1:(length(Dtotal)-smoothing_Window)
    Dtotal_smooth(i) = sum(Dtotal(i:i+smoothing_Window));
end
Dtotal_smooth = [Dtotal_smooth zeros(1,smoothing_Window)]; % zero pad to correct length

%% Adpative Peak Picking
%                                      
[final_onsets]=AdaptivePeakPick(Dtotal_smooth,threshold,waveform_stability,minimum_spacing_between_peaks);  

%%

    k=1; clear final_onsets_rescaled;
    final_onsets = [final_onsets zeros(1,length(Dtotal)-length(final_onsets))];  % zero pad to make same length vector
    
    for i=(hopSize+1):hopSize :(length(x)-frameSize)                            % create vector of Onsets
        final_onsets_rescaled(i) = final_onsets(k); 
        k=k+1;
    end



%% Try to detect long-decaying notes and adjust onsets accordingly

clear candidates 
candidate_to_remove = [];
candidates = find(final_onsets_rescaled~=0); 
for i = 1:length(candidates)-1
    if candidates(i+1)-candidates(i) < long_decay_minimum_spacing 
        if length(x)>candidates(i+1)+long_decay_window_size 
            if debug [candidates(i+1)/1000 mean(abs(x(candidates(i+1)-long_decay_window_size :candidates(i+1)))) mean(abs(x(candidates(i+1):candidates(i+1)+long_decay_window_size ))) ]; end; 
            % look at 50 ms average before that point
            % If earlier window is > than the future window then the signal
            % is obviously decaying and we should throw it out.
            if mean(abs(x(candidates(i+1)-long_decay_window_size :candidates(i+1)))) ...
                    > mean(abs(x(candidates(i+1):candidates(i+1)+long_decay_window_size )))    % samples
                candidate_to_remove = [candidate_to_remove candidates(i+1)];
                if debug disp('removing candidate onset'); end
            end
        else   % if the last transient is near the end of the file - we need to handle it differently
            if debug [candidates(i+1)/1000 mean(abs(x(candidates(i+1)-long_decay_window_size :candidates(i+1)))) mean(abs(x(candidates(i+1):length(x)))) ]; end; 
            % look at 50 ms average before that point
            % If earlier window is > than the future window then the signal
            % is obviously decaying and we should throw it out.
            if mean(abs(x(candidates(i+1)-long_decay_window_size :candidates(i+1)))) ...
                    > mean(abs(x(candidates(i+1):length(x))))    % samples
                candidate_to_remove = [candidate_to_remove candidates(i+1)];
                if debug disp('removing candidate onset'); end
            end
        end            
    end
end

if debug
    if ~isempty(candidate_to_remove)    
        plot(candidate_to_remove,0.8,'k*','MarkerSize',10)
        hold off
    end
end


final_onsets_rescaled_and_pruned = setdiff(candidates,candidate_to_remove);
final_onsets_rescaled_and_pruned = final_onsets_rescaled_and_pruned + onsetCorrectionValue;  % add in a fixed number of samples to correct onset detector being early or late

numonsets = length(final_onsets_rescaled_and_pruned);                       % Set the final # of onsets detected

%% Loudness = log of Amplitude

loudness_window = loundness_window_size * fs;   % window to observe loudness in secs

clear final_amplitudes_dB final_amplitudes
final_amplitudes_dB = 0;                        % prevents error if there are actually no onsets detected
x = x + 0.00001; % insert noise into signal to prevent signal == 0 - that freaks out the log 
for i=1:length(final_onsets_rescaled_and_pruned)
    if final_onsets_rescaled_and_pruned(i)+loudness_window > length(x)  % handle case for last onset
        loudness_window=length(x)-final_onsets_rescaled_and_pruned(i);
    end
    final_amplitudes_dB(i) = mean(log( abs(x(final_onsets_rescaled_and_pruned(i):final_onsets_rescaled_and_pruned(i)+loudness_window))));
end

final_amplitudes = 10.^(final_amplitudes_dB / 20);  % convert dB to scalar values

%% Final Error Checking
if isempty(final_onsets_rescaled_and_pruned)    % if no onsets are found
    final_onsets_rescaled_and_pruned=-1;
    disp('No onsets found.')
end



%% Re-synth onsets
%  [clave] = wavread('C:\Documents and Settings\Jay\My Documents\MATLAB\izotope\clave11.WAV');
%  clear y;
%  y = zeros(length(x),1);
%  for j=1:length(final_onsets_rescaled_and_pruned)
%      y(final_onsets_rescaled_and_pruned(j): (final_onsets_rescaled_and_pruned(j)+length(clave)-1)) = final_amplitudes(j)*clave;
%  end
% 
%  
%     try
%       sound((0.4*x(1:length(y))+y)/max(0.4*x(1:length(y))+y),fs)
%     catch
%       sound((0.4*x+y(1:length(x)))/max(0.4*x+y(1:length(x))),fs)
%     end    
 
%% Output
    if debug
        disp('Found onsets: ');
        final_onsets_rescaled_and_pruned
        final_amplitudes;
    end

    
 