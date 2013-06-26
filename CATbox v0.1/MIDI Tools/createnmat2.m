function nmat = createnmat2(notes,dur,vel,ch,slur);
% Create notematrix with different durations, velocities and channels
% nmat = createnmat(notes,<dur>,<vel>,<ch>);
% Function creates a notematrix of pitches based on the NOTES vector.
% dur, vel and ch are optional and can be either scalars or vectors.
% If scalar, same value will be applied to all notes.
% If vector, the number of values should be same as number of notes, i.e.
% value per note.
% Input arguments:
%	NOTES = pitch vector (e.g. [ 60 64 67] for C major chord)
%	DUR (optional) = note durations in seconds (default 0.25)
%	VEL (optional) = note velocities (0-127, default 100)
%	CH (optional) = note channel (default 1)
%
% Output:
%	NMAT = notematrix
%
% Remarks: only the NOTES vector is required for the input, other input arguments are
% optional and will be replaced by default values if omitted.
%
% Example: Create major scale going up
%   major = [0 2 4 5 7 9 11 12] + 60;
%   nmat = create_nmat(major,0.2,127,1);
%
% Modified by Shlomo Dubnov from Miditoolbox
% Original Authors: 
%  Date		Time	Prog	Note
% 26.1.2003	18:44	TE	Created under MATLAB 5.3 (PC)
%© Part of the MIDI Toolbox, Copyright © 2004, University of Jyvaskyla, Finland
% See License.txt

if nargin<1, notes=[0 2 4 5 7 9 11 12] + 60; end; % if no arguments at all, create major scale
if nargin<2, dur=0.25;end;
if nargin<3, vel=100;end;
if nargin<4, ch=1; end;
if nargin<5, slur = 0.8; end;

% DEFAULT
if isempty(notes)
    error('Notes needed');
end

if isempty(dur)
    dur=0.25;
    if isempty(vel)
        vel=100;
        if isempty(ch)
            ch=1;
        end; end; end

% Pitches
notenro = size(notes,2);
% Durations
if size(dur,2) == 1,
    dur_t = repmat(dur,notenro,1);
else
    if size(dur,2) ~=notenro,
        error('number of durations is different from number of notes')
    end
    dur_t = dur(:);
end

% Velocities
if size(vel,2) == 1,
    vel_t = repmat(vel,notenro,1);
else
    if  size(vel,2) ~= notenro,
        error('number of velocities is different from number of notes')
    end
    vel_t = vel(:);
end

% Channel
if size(vel,2) == 1,
    ch_t = repmat(ch,notenro,1);
else
    if size(ch,2) ~= notenro,
        error('number of channels is different from number of notes')
    end
    cn_t = ch(:);
end


onset=zeros(1,notenro)';
for i = 2:notenro
    onset(i) = onset(i-1)+dur_t(i-1);
end

notes = notes';

dur_t = dur_t*slur; %stacatto;
onsetb = onset * 1.666666;
dur_tb = dur_t * 1.666666;

% onset(beats)	dur(beats)	ch	pitch	velocity	onset(secs)	dur(secs)

nmat = [onsetb dur_tb ch_t notes vel_t onset dur_t];

