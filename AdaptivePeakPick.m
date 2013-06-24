function[final_peak_locations] = AdaptivePeakPick(x,threshold,M,W)
% function[final_peak_locations] = Adaptive_PeakPick(d,threshold,hop,W) 
%  
% Median Filter Adapative Peak Picking from 
% Bello et al. "A tutorial on Onset Detection in Musical Signals"
% 
% x = input signal
% threshold = starting value for adapative threshold algorithm
% M = "longest interval around which global dynamics do not evolve"
%
% final_peak_locations = output of Adaptive Peak Picking algorithm
%
% Jay LeBoeuf
% Imagine Research, Inc
% Created on 2/25/08
%
% Copyright Notice
% This program is copyrighted.  The software may not be copied, reproduced,
% translated, or reduced to any electronic medium or machine-readable form without the prior written consent of Imagine Research, expect that you may make one copy of the program disk for back-up purposes.
%
% This is an unpublished work containing Imagine Research's confidential and proprietary information.  Disclosure, use, or reproduction without authorization of Imagine Research is prohibited. 

d_threshold=0;
adaptive_thresh=0;

debug = 0;      %flag controlling debugging displays

% Median Filter Adaptive Threshold
% adaptive_thresh = threshold + median ( abs(x(n-M) ... abs(x+M)  )
    for n = (M+1):(length(x)-M)
        d_threshold(n) = median( abs (  x((n-M):(n+M))  )) ;   
        adaptive_thresh(n) = threshold + d_threshold(n) ;
    end

	if debug 
        figure; plot(d_threshold); title('delta threshold'); 
    end

% set the start ad the end of the adapative threshold to be equal to the
% threshold
    if adaptive_thresh(1:M) < threshold
        adaptive_thresh(1:M)=threshold;
    end
    if length(adaptive_thresh) < length(x)
        adaptive_thresh(length(adaptive_thresh):length(x))=threshold;
    end
    
%  Calculate Peaks
    local_peaks = find(x > adaptive_thresh);
    local_values = x(local_peaks);
        
    final_peak_locations = 0;
    peak_loc_final = 0;
    peak_val_final = 0;
    peak_onsets = zeros(length(x),1);

% Examine local peaks within window (W) and choose only maximum
    peak_onsets(local_peaks) = local_values;
	if debug 
        figure; plot(local_peaks,local_values); title('peak loc and peak val');
        figure; plot(peak_onsets);title('peak onsets')
    end
    
    previous_max_index = 1;
    for i = 1:W/2:(length(x)-W)
        [max_val,max_index] = max(peak_onsets(i:i+W));          % look for maximum within window
        if peak_onsets(i+max_index-1) > peak_onsets(previous_max_index)
            final_peak_locations(previous_max_index) = 0;       % overwrite previous_max_index value with 0
        end
        final_peak_locations(i+max_index-1) = peak_onsets(i+max_index-1);
        if  ((i+max_index-1) - previous_max_index)<W && ( peak_onsets(previous_max_index)>peak_onsets(i+max_index-1) ) 
            final_peak_locations(i+max_index-1)=0;              % if found max is within the window, then set the peak = 0 
                                                                % and keep the previous max
        end   
        previous_max_index = i+max_index-1;
    end

    if debug
        figure; 
        plot(x,'r');
        hold on; 
        plot(adaptive_thresh);
        title('x with adaptive threshold');
        hold off;
    end