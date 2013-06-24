% LAB 1 - Helpful function for calling the MIR Toolbox Onset Detector
%
% July 16, 2008
% Copyright 2008 Jay LeBoeuf / Imagine Research
% Used for teaching purposed at CCRMA Summer 2008


function [onsets,numonsets] = ccrma_onset_detector(x,fs)
    % create a MIR Toolbox object from array "x"    
    a = miraudio(x,fs);                

    % call MIR toolbox onset detector with some reasonably general purpose settings
    o = mironsets(a,'Diff', 'Filterbank', 5, 'Halfwavediff', 'Detect', 'peaks');  %
    
    % convert time-based onsets to sample values 
    onsets = mirgetdata(o) * fs;    
    numonsets = length(onsets);
    